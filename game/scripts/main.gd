extends Node

const SPEED := 4.5
const STALE_INPUT_MS := 250
const SPLIT_DISTANCE := 32.0
const MERGE_DISTANCE := 25.0
const CAMERA_OFFSET := Vector3(38, 46, 38)
const DEMO_DURATION := 300.0
const FIELD_GATE_POSITION := Vector3(27.0, 0.0, -9.0)
const FIELD_CHECKPOINTS := [Vector3(36.0, 0.0, -23.0), Vector3(49.0, 0.0, -38.0)]
const SCREEN_RIGHT := Vector3(0.70710678, 0, -0.70710678)
const SCREEN_DOWN := Vector3(0.70710678, 0, 0.70710678)
const WorldLayout := preload("res://scripts/world_layout.gd")
const MACHINERY_SHED_REVIEW := preload("res://scenes/review/machinery_shed_review.tscn")
const STORYBOOK_ASSET_REVIEW := preload("res://scenes/review/storybook_asset_review.tscn")
const BOUNDARY_KIT_REVIEW := preload("res://scenes/review/boundary_kit_review.tscn")
const GRAIN_STORE_REVIEW := preload("res://scenes/review/grain_store_review.tscn")
const SECONDARY_BUILDINGS_REVIEW := preload("res://scenes/review/secondary_buildings_review.tscn")
const CHARACTER_REVIEW := preload("res://scenes/review/character_review.tscn")
var socket := WebSocketPeer.new()
var discovery := PacketPeerUDP.new()
var relay_url := "ws://127.0.0.1:8787/ws"
var room := "------"
var connected := false
var inputs := {1: neutral_input(), 2: neutral_input()}
var last_acked := {1: -1, 2: -1}
var players: Dictionary = {}
var room_label: Label
var status_label: Label
var roster_label: Label
var latency_label: Label
var qr_request: HTTPRequest
var qr_rect: TextureRect
var qr_status: Label
var lobby_panel: ColorRect
var world_root: Node3D
var left_container: SubViewportContainer
var right_container: SubViewportContainer
var left_viewport: SubViewport
var right_viewport: SubViewport
var left_camera: Camera3D
var right_camera: Camera3D
var split_divider: ColorRect
var split_screen := false
var debug_overview := false
var asset_preview := ""
var machinery_shed_review: Node3D
var asset_review_label: Label
var storybook_asset_review: Node3D
var storybook_review_label: Label
var boundary_kit_review: Node3D
var boundary_kit_review_label: Label
var grain_store_review: Node3D
var grain_store_review_label: Label
var secondary_buildings_review: Node3D
var secondary_buildings_review_label: Label
var character_review: Node3D
var character_review_label: Label
var player_modes := {1: "foot", 2: "foot"}
var previous_actions := {1: false, 2: false}
var tractor_driver := 0
var admitted_players := 0
var demo_stage := "lobby"
var demo_time_left := DEMO_DURATION
var briefing_left := 8.0
var checkpoint_index := 0
var gate_holder := 0
var objective_panel: ColorRect
var phase_label: Label
var objective_label: Label
var timer_label: Label
var progress_bar: ProgressBar
var feedback_label: Label
var gate_marker: Node3D
var checkpoint_markers: Array[Node3D] = []
var tick := 0

static func neutral_input() -> Dictionary:
	return {"seq": -1, "x": 0.0, "y": 0.0, "action": false, "seen": 0}

func _ready() -> void:
	relay_url = _relay_from_environment()
	_build_world()
	_build_render_views()
	_build_ui()
	if relay_url.is_empty():
		var error := discovery.bind(41234)
		status_label.text = "Looking for the farm relay on this network…"
		if error != OK: status_label.text = "Relay discovery failed: %s" % error_string(error)
	else:
		_begin_connection(relay_url)

func _relay_from_environment() -> String:
	var configured := OS.get_environment("FARM_RELAY_URL")
	if not configured.is_empty(): return configured
	if OS.has_feature("web"):
		var url = JavaScriptBridge.eval("location.protocol.replace('http','ws')+'//'+location.host+'/ws'")
		if url != null: return str(url)
	return ""

func _begin_connection(url: String) -> void:
	relay_url = url
	socket = WebSocketPeer.new()
	var error := socket.connect_to_url(relay_url)
	status_label.text = "Connecting to %s" % relay_url
	if error != OK: status_label.text = "Relay connection failed: %s" % error_string(error)

func _process(_delta: float) -> void:
	while relay_url.is_empty() and discovery.get_available_packet_count() > 0:
		var announcement = JSON.parse_string(discovery.get_packet().get_string_from_utf8())
		if announcement is Dictionary and announcement.get("type") == "farm_relay" and int(announcement.get("version", 0)) == 1:
			var discovered_url := str(announcement.get("url", ""))
			if discovered_url.begins_with("ws://") or discovered_url.begins_with("wss://"):
				discovery.close()
				_begin_connection(discovered_url)
	if relay_url.is_empty(): return
	socket.poll()
	var state := socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			connected = true
			_send({"type":"create", "version":1})
		while socket.get_available_packet_count() > 0:
			_handle(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSED:
		status_label.text = "Relay disconnected. Restart this host to create a new room."

func _physics_process(delta: float) -> void:
	tick += 1
	var now := Time.get_ticks_msec()
	for id in [1, 2]:
		var input: Dictionary = inputs[id]
		if now - int(input.seen) > STALE_INPUT_MS:
			input.x = 0.0; input.y = 0.0; input.action = false
		var body: CharacterBody3D = players[id]
		# Phone input is expressed in screen directions. Convert it through the
		# fixed isometric camera axes so down on the stick always looks down on TV.
		var movement := SCREEN_RIGHT * float(input.x) + SCREEN_DOWN * float(input.y)
		var action_pressed := bool(input.action) and not bool(previous_actions[id])
		if player_modes[id] == "tractor":
			_drive_tractor(id, movement, action_pressed, delta)
		else:
			body.velocity = movement.limit_length(1.0) * SPEED
			body.move_and_slide()
			body.position.x = clampf(body.position.x, -82.0, 82.0)
			body.position.z = clampf(body.position.z, -57.0, 57.0)
			if action_pressed:
				_try_context_action(id)
		previous_actions[id] = bool(input.action)
		if connected and int(input.seq) > int(last_acked[id]):
			_send({"type":"frame_ack", "playerId":id, "seq":input.seq, "phase":"simulated", "position":[body.position.x,body.position.z]})
			last_acked[id] = input.seq
	_update_camera(delta)
	_update_demo_session(delta)

func _try_context_action(id: int) -> void:
	var body: CharacterBody3D = players[id]
	var tractor := world_root.get_node_or_null("BrackenTractor") as CharacterBody3D
	if tractor and tractor_driver == 0 and body.position.distance_to(tractor.position) <= 6.5:
		tractor_driver = id
		player_modes[id] = "tractor"
		body.visible = false
		body.position = tractor.position
		_send({"type":"mode", "playerId":id, "title":"TRACTOR", "actionLabel":"EXIT", "hint":"Steer with the movement pad"})
		_send({"type":"private", "playerId":id, "text":"Fuel: one field trip. Hitch is currently free."})

func _drive_tractor(id: int, movement: Vector3, action_pressed: bool, delta: float) -> void:
	var body: CharacterBody3D = players[id]
	var tractor := world_root.get_node_or_null("BrackenTractor") as CharacterBody3D
	if not tractor:
		return
	var drive := movement.limit_length(1.0)
	tractor.velocity = drive * SPEED * 1.65
	tractor.move_and_slide()
	tractor.position.x = clampf(tractor.position.x, -82.0, 82.0)
	tractor.position.z = clampf(tractor.position.z, -57.0, 57.0)
	if drive.length() > 0.08:
		var target_heading := atan2(drive.x, drive.z)
		tractor.rotation.y = lerp_angle(tractor.rotation.y, target_heading, minf(1.0, delta * 5.0))
	tractor.set_vehicle_motion(drive.length() * SPEED, drive.x)
	body.position = tractor.position
	if action_pressed:
		tractor_driver = 0
		player_modes[id] = "foot"
		body.visible = true
		body.position = tractor.position + Vector3(3.2, 0.0, 0.0)
		tractor.set_vehicle_motion(0.0, 0.0)
		_send({"type":"mode", "playerId":id, "title":"GROWER" if id == 1 else "MECHANIC", "actionLabel":"INTERACT", "hint":"Walk close to equipment to use it"})

func _start_demo_session() -> void:
	demo_stage = "briefing"
	demo_time_left = DEMO_DURATION
	briefing_left = 8.0
	checkpoint_index = 0
	objective_panel.visible = true
	phase_label.text = "FRIDAY · RAIN BEFORE BARLEY"
	objective_label.text = "Share the private facts on your phones. Decide who drives and who holds the east field gate."
	feedback_label.text = "Nobody has the whole plan. Talk first."
	progress_bar.value = 0
	world_root.call("set_crop_state", "mature")
	_send({"type":"private", "playerId":1, "text":"WEATHER: Heavy rain reaches the barley in five minutes. The crop can be protected only before the first downpour."})
	_send({"type":"private", "playerId":2, "text":"EQUIPMENT: The tractor has fuel for one field trip. Use the EAST field gate and keep to the paired tramlines."})
	_set_demo_markers(false, false)

func _update_demo_session(delta: float) -> void:
	if demo_stage in ["lobby", "success", "failed"]:
		return
	if admitted_players < 2 and OS.get_environment("FARM_DEMO_ALLOW_SOLO") != "1":
		timer_label.text = "PAUSED"
		feedback_label.text = "Waiting for the second farmhand to reconnect"
		return
	demo_time_left = maxf(0.0, demo_time_left - delta)
	var minutes := floori(demo_time_left / 60.0)
	var seconds := int(demo_time_left) % 60
	timer_label.text = "%d:%02d" % [minutes, seconds]
	if demo_time_left <= 0.0:
		_fail_demo_session()
		return
	if demo_stage == "briefing":
		briefing_left -= delta
		if briefing_left <= 0.0:
			demo_stage = "gate"
			objective_label.text = "One player: hold ACTION at the glowing east gate. Other player: enter the tractor and drive through."
			feedback_label.text = "The gate closes when its holder lets go."
			_set_demo_markers(true, false)
	elif demo_stage == "gate":
		gate_holder = 0
		for id in [1, 2]:
			if player_modes[id] == "foot" and players[id].position.distance_to(FIELD_GATE_POSITION) < 5.0 and bool(inputs[id].action):
				gate_holder = id
				break
		feedback_label.text = "Player %d is holding the gate open" % gate_holder if gate_holder > 0 else "Stand at the glowing gate and hold ACTION"
		progress_bar.value = 20 if gate_holder > 0 else 8
		var tractor := world_root.get_node_or_null("BrackenTractor") as Node3D
		if gate_holder > 0 and tractor_driver > 0 and tractor_driver != gate_holder and tractor and tractor.position.distance_to(FIELD_GATE_POSITION) < 7.0:
			demo_stage = "field"
			objective_label.text = "Driver: follow both glowing tramline markers. Gate holder: call out the route from your private clue."
			feedback_label.text = "Gate cleared. Keep the one-trip tractor on the tramlines."
			progress_bar.value = 35
			_set_demo_markers(false, true)
	elif demo_stage == "field":
		var tractor := world_root.get_node_or_null("BrackenTractor") as Node3D
		if tractor_driver > 0 and tractor and checkpoint_index < FIELD_CHECKPOINTS.size():
			if tractor.position.distance_to(FIELD_CHECKPOINTS[checkpoint_index]) < 7.0:
				checkpoint_markers[checkpoint_index].visible = false
				checkpoint_index += 1
				progress_bar.value = 35 + checkpoint_index * 30
				feedback_label.text = "Drainage pass %d of %d complete" % [checkpoint_index, FIELD_CHECKPOINTS.size()]
				if checkpoint_index >= FIELD_CHECKPOINTS.size():
					_complete_demo_session()

func _complete_demo_session() -> void:
	demo_stage = "success"
	world_root.call("set_crop_state", "protected")
	phase_label.text = "FIELD SAVED"
	objective_label.text = "You combined two private facts, held the gate together and protected the barley before the rain."
	feedback_label.text = "Co-op consequence: crop quality preserved · fuel spent"
	progress_bar.value = 100
	_set_demo_markers(false, false)
	_send({"type":"private", "playerId":1, "text":"RESULT: Barley protected before the storm. Quality remains high."})
	_send({"type":"private", "playerId":2, "text":"RESULT: The tractor completed its single safe trip. Fuel reserve is now empty."})

func _fail_demo_session() -> void:
	demo_stage = "failed"
	world_root.call("set_crop_state", "damaged")
	world_root.call("set_storm", true)
	phase_label.text = "THE RAIN ARRIVED"
	objective_label.text = "The barley was damaged, but the farm continues. Try again and combine the phone clues sooner."
	feedback_label.text = "Recovery remains possible · no player is eliminated"
	progress_bar.value = 100
	_set_demo_markers(false, false)

func _set_demo_markers(show_gate: bool, show_checkpoints: bool) -> void:
	if gate_marker:
		gate_marker.visible = show_gate
	for index in range(checkpoint_markers.size()):
		checkpoint_markers[index].visible = show_checkpoints and index >= checkpoint_index

func _handle(message) -> void:
	if not message is Dictionary: return
	match message.get("type", ""):
		"created":
			room = str(message.room)
			room_label.text = room
			status_label.text = "Scan the QR code or enter this room code"
			_load_room_qr()
			print("PROBE_ROOM=%s" % room)
		"roster":
			var lines: Array[String] = []
			var has_admitted_player := false
			admitted_players = 0
			for p in message.players:
				lines.append("Player %d · %s · %s" % [p.id, "online" if p.connected else "offline", p.admission])
				if p.admission == "admitted" and p.connected:
					has_admitted_player = true
					admitted_players += 1
			roster_label.text = "\n".join(lines) if not lines.is_empty() else "Waiting for two phones"
			lobby_panel.visible = not has_admitted_player
			roster_label.visible = not has_admitted_player
			latency_label.visible = not has_admitted_player
			if OS.get_environment("FARM_AUTO_ADMIT") == "1":
				for p in message.players:
					if p.connected and p.admission == "pending": _admit(int(p.id))
			if admitted_players >= 2 and demo_stage == "lobby":
				_start_demo_session()
		"input":
			var id := int(message.get("playerId", 0))
			if not inputs.has(id): return
			var current: Dictionary = inputs[id]
			if int(message.seq) <= int(current.seq): return
			inputs[id] = {"seq":int(message.seq), "x":float(message.x), "y":float(message.y), "action":bool(message.action), "seen":Time.get_ticks_msec()}
		"reset_input":
			var reset_id := int(message.playerId)
			inputs[reset_id] = neutral_input()
			last_acked[reset_id] = -1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for id in [1,2]: _admit(id)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_1 and asset_preview.is_empty(): _admit(1)
		if event.keycode == KEY_2 and asset_preview.is_empty(): _admit(2)
		if event.keycode == KEY_M: debug_overview = not debug_overview
		if event.keycode == KEY_L and world_root.has_method("toggle_weather_preview"):
			world_root.toggle_weather_preview()
		if event.keycode == KEY_C and world_root.has_method("cycle_crop_state"):
			var crop_state: String = world_root.cycle_crop_state()
			status_label.text = "Barley field: %s" % crop_state.capitalize()
		if event.keycode == KEY_D and demo_stage == "lobby":
			lobby_panel.visible = false
			roster_label.visible = false
			latency_label.visible = false
			admitted_players = 2
			_start_demo_session()
		if event.keycode == KEY_V:
			asset_preview = "storybook_gallery"
			storybook_asset_review.show_asset(1)
			storybook_review_label.text = storybook_asset_review.get_review_label()
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_B:
			asset_preview = "storybook_gallery"
			storybook_asset_review.show_asset(0)
			storybook_review_label.text = storybook_asset_review.get_review_label()
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_F:
			asset_preview = "" if asset_preview == "farmyard" else "farmyard"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_H:
			asset_preview = "" if asset_preview == "shed" else "shed"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_J:
			asset_preview = "" if asset_preview == "storybook_gallery" else "storybook_gallery"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_K:
			asset_preview = "" if asset_preview == "boundary_kit" else "boundary_kit"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_G:
			asset_preview = "" if asset_preview == "grain_store" else "grain_store"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_U:
			asset_preview = "" if asset_preview == "secondary_buildings" else "secondary_buildings"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if event.keycode == KEY_P:
			asset_preview = "" if asset_preview == "characters" else "characters"
			if not asset_preview.is_empty():
				lobby_panel.visible = false
				roster_label.visible = false
				latency_label.visible = false
		if asset_preview == "storybook_gallery" and event.keycode >= KEY_1 and event.keycode <= KEY_5:
			storybook_asset_review.show_asset(event.keycode - KEY_1)
			storybook_review_label.text = storybook_asset_review.get_review_label()
		if asset_preview == "boundary_kit" and event.keycode >= KEY_1 and event.keycode <= KEY_3:
			boundary_kit_review.show_kit(event.keycode - KEY_1)
			boundary_kit_review_label.text = boundary_kit_review.get_review_label()
		if asset_preview == "secondary_buildings" and event.keycode >= KEY_1 and event.keycode <= KEY_2:
			secondary_buildings_review.show_asset(event.keycode - KEY_1)
			secondary_buildings_review_label.text = secondary_buildings_review.get_review_label()
		machinery_shed_review.visible = asset_preview == "shed"
		asset_review_label.visible = asset_preview == "shed"
		storybook_asset_review.visible = asset_preview == "storybook_gallery"
		storybook_review_label.visible = asset_preview == "storybook_gallery"
		boundary_kit_review.visible = asset_preview == "boundary_kit"
		boundary_kit_review_label.visible = asset_preview == "boundary_kit"
		grain_store_review.visible = asset_preview == "grain_store"
		grain_store_review_label.visible = asset_preview == "grain_store"
		secondary_buildings_review.visible = asset_preview == "secondary_buildings"
		secondary_buildings_review_label.visible = asset_preview == "secondary_buildings"
		character_review.visible = asset_preview == "characters"
		character_review_label.visible = asset_preview == "characters"
		if event.keycode == KEY_T:
			players[1].position = Vector3(-12, 0.7, 7)
			players[2].position = Vector3(48, 0.7, -30)

func _admit(id: int) -> void:
	_send({"type":"admit", "playerId":id})
	_send({"type":"private", "playerId":id, "text":"Storm in 70 seconds" if id == 1 else "Tractor fuel: one trip"})

func _send(message: Dictionary) -> void:
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify(message))

func _load_room_qr() -> void:
	var http_url := relay_url.trim_suffix("/ws").replace("ws://", "http://").replace("wss://", "https://")
	var error := qr_request.request("%s/qr?room=%s" % [http_url, room])
	if error != OK: qr_status.text = "QR unavailable · use room code"

func _on_qr_loaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		qr_status.text = "QR unavailable · use room code"
		return
	var image := Image.new()
	if image.load_png_from_buffer(body) != OK:
		qr_status.text = "QR unavailable · use room code"
		return
	qr_rect.texture = ImageTexture.create_from_image(image)
	qr_status.text = "SCAN TO JOIN"

func _build_world() -> void:
	var world := WorldLayout.new(); world.name = "BrackenridgeFarm"; add_child(world); world_root = world
	machinery_shed_review = MACHINERY_SHED_REVIEW.instantiate()
	machinery_shed_review.name = "IsolatedMachineryShedReview"
	machinery_shed_review.position = Vector3(0, 0, 160)
	machinery_shed_review.visible = false
	add_child(machinery_shed_review)
	storybook_asset_review = STORYBOOK_ASSET_REVIEW.instantiate()
	storybook_asset_review.name = "IsolatedStorybookAssetReview"
	storybook_asset_review.position = Vector3(0, 0, 220)
	storybook_asset_review.visible = false
	add_child(storybook_asset_review)
	boundary_kit_review = BOUNDARY_KIT_REVIEW.instantiate()
	boundary_kit_review.name = "IsolatedBoundaryKitReview"
	boundary_kit_review.position = Vector3(0, 0, 285)
	boundary_kit_review.visible = false
	add_child(boundary_kit_review)
	grain_store_review = GRAIN_STORE_REVIEW.instantiate()
	grain_store_review.name = "IsolatedGrainStoreReview"
	grain_store_review.position = Vector3(0, 0, 350)
	grain_store_review.visible = false
	add_child(grain_store_review)
	secondary_buildings_review = SECONDARY_BUILDINGS_REVIEW.instantiate()
	secondary_buildings_review.name = "IsolatedSecondaryBuildingsReview"
	secondary_buildings_review.position = Vector3(0, 0, 420)
	secondary_buildings_review.visible = false
	add_child(secondary_buildings_review)
	character_review = CHARACTER_REVIEW.instantiate()
	character_review.name = "IsolatedCharacterReview"
	character_review.position = Vector3(0, 0, 490)
	character_review.visible = false
	add_child(character_review)
	for id in [1,2]:
		var body := CharacterBody3D.new(); body.name="Player%d"%id; body.position=Vector3(-2 if id==1 else 2,.7,7)
		# Players share a camera and often work shoulder-to-shoulder. Keep world
		# collision while allowing farmhands to pass without blocking each other.
		body.collision_layer = 2
		body.collision_mask = 1
		var shape := CollisionShape3D.new(); var capsule_shape:=CapsuleShape3D.new(); capsule_shape.height=1.4; capsule_shape.radius=.42; shape.shape=capsule_shape; body.add_child(shape)
		_add_player_placeholder(body, id)
		world.add_child(body); players[id]=body
	_build_demo_markers()

func _add_player_placeholder(body: CharacterBody3D, id: int) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#d95847") if id == 1 else Color("#3f86c7")
	var torso := MeshInstance3D.new()
	var torso_mesh := CapsuleMesh.new()
	torso_mesh.height = 1.15
	torso_mesh.radius = 0.38
	torso.mesh = torso_mesh
	torso.material_override = material
	body.add_child(torso)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.31
	head_mesh.height = 0.62
	head.mesh = head_mesh
	head.position.y = 0.77
	head.material_override = material
	body.add_child(head)

func _build_demo_markers() -> void:
	gate_marker = _make_world_marker("EastGateTask", FIELD_GATE_POSITION + Vector3(0, 0.24, 0), Color("#f5b83b"), "HOLD GATE")
	world_root.add_child(gate_marker)
	gate_marker.visible = false
	for index in range(FIELD_CHECKPOINTS.size()):
		var marker := _make_world_marker("TramlinePass%d" % (index + 1), FIELD_CHECKPOINTS[index] + Vector3(0, 0.22, 0), Color("#64c9df"), "PASS %d" % (index + 1))
		world_root.add_child(marker)
		marker.visible = false
		checkpoint_markers.append(marker)

func _make_world_marker(marker_name: String, marker_position: Vector3, color: Color, text: String) -> Node3D:
	var root := Node3D.new()
	root.name = marker_name
	root.position = marker_position
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 2.5
	torus.outer_radius = 3.0
	torus.rings = 24
	torus.ring_segments = 8
	ring.mesh = torus
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 1.5
	ring.material_override = material
	root.add_child(ring)
	var marker_label := Label3D.new()
	marker_label.text = text
	marker_label.position = Vector3(0, 2.0, 0)
	marker_label.font_size = 34
	marker_label.outline_size = 8
	marker_label.modulate = Color.WHITE
	marker_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	marker_label.no_depth_test = true
	root.add_child(marker_label)
	return root

func _build_render_views() -> void:
	var layer := CanvasLayer.new(); layer.layer = -5; add_child(layer)
	left_container = SubViewportContainer.new(); left_container.name = "SharedOrPlayerOneView"; left_container.stretch = true; left_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(left_container)
	right_container = SubViewportContainer.new(); right_container.name = "PlayerTwoView"; right_container.stretch = true; right_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(right_container)
	left_viewport = _create_world_view(left_container, "SharedCameraViewport")
	right_viewport = _create_world_view(right_container, "PlayerTwoCameraViewport")
	left_camera = left_viewport.get_child(0) as Camera3D
	right_camera = right_viewport.get_child(0) as Camera3D
	split_divider = ColorRect.new(); split_divider.color = Color("#493725"); split_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(split_divider)
	_decorate_split_divider()
	_apply_view_layout()

func _decorate_split_divider() -> void:
	# A small post-and-hedge motif makes the split feel part of the farm.
	for index in range(18):
		var leaf := ColorRect.new()
		leaf.color = Color("#4e7e48") if index % 2 == 0 else Color("#6a9655")
		leaf.size = Vector2(10, 10)
		leaf.position = Vector2(-1 if index % 2 == 0 else 7, 14 + index * 40)
		leaf.rotation = deg_to_rad(45)
		leaf.mouse_filter = Control.MOUSE_FILTER_IGNORE
		split_divider.add_child(leaf)
	for index in range(8):
		var rail := ColorRect.new()
		rail.color = Color("#806143")
		rail.position = Vector2(-4, 37 + index * 88)
		rail.size = Vector2(24, 4)
		rail.mouse_filter = Control.MOUSE_FILTER_IGNORE
		split_divider.add_child(rail)

func _create_world_view(container: SubViewportContainer, view_name: String) -> SubViewport:
	var viewport := SubViewport.new(); viewport.name = view_name; viewport.world_3d = get_viewport().world_3d; viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS; viewport.handle_input_locally = false; container.add_child(viewport)
	var view_camera := Camera3D.new(); view_camera.projection = Camera3D.PROJECTION_ORTHOGONAL; view_camera.size = 34; view_camera.position = CAMERA_OFFSET; viewport.add_child(view_camera); view_camera.look_at(Vector3.ZERO); view_camera.current = true
	return viewport

func _apply_view_layout() -> void:
	var screen_size := Vector2i(get_viewport().get_visible_rect().size)
	left_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if split_screen:
		left_container.anchor_right = 0.5; left_container.offset_right = -8
		right_container.anchor_left = 0.5; right_container.anchor_right = 1.0; right_container.anchor_bottom = 1.0; right_container.offset_left = 8; right_container.offset_right = 0; right_container.offset_bottom = 0
		right_container.visible = true
		split_divider.position = Vector2(float(screen_size.x) * 0.5 - 8, 0); split_divider.size = Vector2(16, screen_size.y); split_divider.visible = true
	else:
		right_container.visible = false; split_divider.visible = false

func _update_camera(delta: float) -> void:
	var player_one: Vector3 = players[1].position
	var player_two: Vector3 = players[2].position
	if not asset_preview.is_empty():
		if split_screen: split_screen = false; _apply_view_layout()
		if asset_preview == "tractor":
			var tractor := world_root.get_node_or_null("BrackenTractor") as Node3D
			if tractor: _move_camera(left_camera, tractor.global_position + Vector3(0, 0, -0.2), 5.0, delta)
		elif asset_preview == "barn":
			var barn := world_root.get_node_or_null("BrackenStoneBarn") as Node3D
			if barn: _move_camera(left_camera, barn.global_position + Vector3(0, 0, -0.4), 13.0, delta)
		elif asset_preview == "shed":
			_move_camera_with_offset(left_camera, machinery_shed_review.global_position + Vector3(0, 0, -0.8), 22.5, Vector3(34, 24, 44), delta)
		elif asset_preview == "storybook_gallery":
			var review_target: Vector3 = storybook_asset_review.global_position + storybook_asset_review.get_camera_target()
			_move_camera_with_offset(left_camera, review_target, storybook_asset_review.get_camera_size(), Vector3(28, 18, 34), delta)
		elif asset_preview == "boundary_kit":
			var boundary_target: Vector3 = boundary_kit_review.global_position + boundary_kit_review.get_camera_target()
			_move_camera_with_offset(left_camera, boundary_target, boundary_kit_review.get_camera_size(), Vector3(34, 25, 38), delta)
		elif asset_preview == "grain_store":
			_move_camera_with_offset(left_camera, grain_store_review.global_position + Vector3(0, 2.5, 0), 29.0, Vector3(4, 24, 44), delta)
		elif asset_preview == "secondary_buildings":
			var secondary_target: Vector3 = secondary_buildings_review.global_position + secondary_buildings_review.get_camera_target()
			_move_camera_with_offset(left_camera, secondary_target, secondary_buildings_review.get_camera_size(), Vector3(28, 19, 34), delta)
		elif asset_preview == "characters":
			var character_target: Vector3 = character_review.global_position + character_review.get_camera_target()
			_move_camera_with_offset(left_camera, character_target, character_review.get_camera_size(), Vector3(5, 4, 8), delta)
		else:
			_move_camera(left_camera, Vector3(0, 0, 3), 34.0, delta)
		return
	if debug_overview:
		if split_screen: split_screen = false; _apply_view_layout()
		_move_camera(left_camera, Vector3.ZERO, 118.0, delta)
		return
	var separation := Vector2(player_one.x, player_one.z).distance_to(Vector2(player_two.x, player_two.z))
	var should_split := separation > (MERGE_DISTANCE if split_screen else SPLIT_DISTANCE)
	if should_split != split_screen:
		split_screen = should_split; _apply_view_layout()
	if split_screen:
		_move_camera(left_camera, player_one, 31.0, delta)
		_move_camera(right_camera, player_two, 31.0, delta)
	else:
		var midpoint := (player_one + player_two) * 0.5
		var shared_size := clampf(30.0 + separation * 0.42, 30.0, 43.0)
		_move_camera(left_camera, midpoint, shared_size, delta)

func _move_camera(view_camera: Camera3D, target: Vector3, desired_size: float, delta: float) -> void:
	_move_camera_with_offset(view_camera, target, desired_size, CAMERA_OFFSET, delta)

func _move_camera_with_offset(view_camera: Camera3D, target: Vector3, desired_size: float, offset: Vector3, delta: float) -> void:
	var desired_position := target + offset
	var blend := minf(1.0, delta * 4.0)
	view_camera.position = view_camera.position.lerp(desired_position, blend)
	view_camera.size = lerpf(view_camera.size, desired_size, blend)
	view_camera.look_at(target)

func _build_ui() -> void:
	var layer:=CanvasLayer.new(); layer.layer = 5; add_child(layer)
	lobby_panel=ColorRect.new(); var panel:=lobby_panel; panel.color=Color(0.035,0.075,0.06,.91); panel.position=Vector2(32,28); panel.size=Vector2(650,230); layer.add_child(panel)
	var box:=VBoxContainer.new(); box.position=Vector2(24,18); box.size=Vector2(390,190); panel.add_child(box)
	var title:=Label.new(); title.text="BRACKENRIDGE FARM · CO-OP DEMO"; title.add_theme_font_size_override("font_size",18); box.add_child(title)
	room_label=Label.new(); room_label.text=room; room_label.add_theme_font_size_override("font_size",48); box.add_child(room_label)
	status_label=Label.new(); status_label.add_theme_font_size_override("font_size",17); box.add_child(status_label)
	var qr_back:=ColorRect.new(); qr_back.color=Color.WHITE; qr_back.position=Vector2(438,16); qr_back.size=Vector2(190,190); panel.add_child(qr_back)
	qr_rect=TextureRect.new(); qr_rect.position=Vector2(8,8); qr_rect.size=Vector2(174,174); qr_rect.expand_mode=TextureRect.EXPAND_IGNORE_SIZE; qr_rect.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED; qr_back.add_child(qr_rect)
	qr_status=Label.new(); qr_status.text="CREATING QR…"; qr_status.position=Vector2(438,207); qr_status.size=Vector2(190,20); qr_status.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; qr_status.add_theme_font_size_override("font_size",13); panel.add_child(qr_status)
	qr_request=HTTPRequest.new(); qr_request.request_completed.connect(_on_qr_loaded); add_child(qr_request)
	roster_label=Label.new(); roster_label.text="Waiting for two phones"; roster_label.position=Vector2(32,238); roster_label.add_theme_font_size_override("font_size",20); layer.add_child(roster_label)
	latency_label=Label.new(); latency_label.text="SELECT/Enter · admit    D · demo    M · overview    P · players    C · crop    G · grain    U · buildings    H · shed    J · assets    K · boundaries"; latency_label.position=Vector2(32,660); latency_label.add_theme_font_size_override("font_size",18); layer.add_child(latency_label)
	asset_review_label=Label.new(); asset_review_label.text="MACHINERY SHED · ASSET REVIEW · IN PLAYABLE MAP"; asset_review_label.position=Vector2(0,22); asset_review_label.size=Vector2(1280,38); asset_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; asset_review_label.add_theme_font_size_override("font_size",22); asset_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); asset_review_label.visible=false; layer.add_child(asset_review_label)
	storybook_review_label=Label.new(); storybook_review_label.text=storybook_asset_review.get_review_label(); storybook_review_label.position=Vector2(0,22); storybook_review_label.size=Vector2(1280,38); storybook_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; storybook_review_label.add_theme_font_size_override("font_size",19); storybook_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); storybook_review_label.visible=false; layer.add_child(storybook_review_label)
	boundary_kit_review_label=Label.new(); boundary_kit_review_label.text=boundary_kit_review.get_review_label(); boundary_kit_review_label.position=Vector2(0,22); boundary_kit_review_label.size=Vector2(1280,38); boundary_kit_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; boundary_kit_review_label.add_theme_font_size_override("font_size",19); boundary_kit_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); boundary_kit_review_label.visible=false; layer.add_child(boundary_kit_review_label)
	grain_store_review_label=Label.new(); grain_store_review_label.text="GRAIN STORE + DRIVE-OVER INTAKE · ASSET REVIEW · IN PLAYABLE MAP"; grain_store_review_label.position=Vector2(0,22); grain_store_review_label.size=Vector2(1280,38); grain_store_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; grain_store_review_label.add_theme_font_size_override("font_size",19); grain_store_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); grain_store_review_label.visible=false; layer.add_child(grain_store_review_label)
	secondary_buildings_review_label=Label.new(); secondary_buildings_review_label.text=secondary_buildings_review.get_review_label(); secondary_buildings_review_label.position=Vector2(0,22); secondary_buildings_review_label.size=Vector2(1280,38); secondary_buildings_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; secondary_buildings_review_label.add_theme_font_size_override("font_size",19); secondary_buildings_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); secondary_buildings_review_label.visible=false; layer.add_child(secondary_buildings_review_label)
	character_review_label=Label.new(); character_review_label.text=character_review.get_review_label(); character_review_label.position=Vector2(0,22); character_review_label.size=Vector2(1280,38); character_review_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; character_review_label.add_theme_font_size_override("font_size",19); character_review_label.add_theme_color_override("font_color",Color("#f3e5bd")); character_review_label.visible=false; layer.add_child(character_review_label)
	_build_objective_ui(layer)

func _build_objective_ui(layer: CanvasLayer) -> void:
	objective_panel = ColorRect.new()
	objective_panel.name = "CoopObjectivePanel"
	objective_panel.color = Color(0.055, 0.12, 0.09, 0.94)
	objective_panel.position = Vector2(728, 28)
	objective_panel.size = Vector2(520, 184)
	layer.add_child(objective_panel)
	var content := VBoxContainer.new()
	content.position = Vector2(20, 14)
	content.size = Vector2(480, 154)
	objective_panel.add_child(content)
	var heading_row := HBoxContainer.new()
	content.add_child(heading_row)
	phase_label = Label.new()
	phase_label.text = "FRIDAY"
	phase_label.add_theme_font_size_override("font_size", 18)
	phase_label.add_theme_color_override("font_color", Color("#f2d477"))
	phase_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading_row.add_child(phase_label)
	timer_label = Label.new()
	timer_label.text = "5:00"
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.add_theme_color_override("font_color", Color.WHITE)
	heading_row.add_child(timer_label)
	objective_label = Label.new()
	objective_label.text = "Waiting for both players"
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.custom_minimum_size = Vector2(480, 54)
	objective_label.add_theme_font_size_override("font_size", 17)
	content.add_child(objective_label)
	progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = 100
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(480, 12)
	content.add_child(progress_bar)
	feedback_label = Label.new()
	feedback_label.text = "Share what only you can see."
	feedback_label.add_theme_font_size_override("font_size", 14)
	feedback_label.add_theme_color_override("font_color", Color("#b9d5c0"))
	feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(feedback_label)
	objective_panel.visible = false
