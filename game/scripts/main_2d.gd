extends Node

const PROTOCOL := 1
const STALE_INPUT_MS := 250
const SPEED := 7.0
const SPLIT_DISTANCE := 38.0
const MERGE_DISTANCE := 31.0
const MAP_CENTER := Vector2(850, 600)
const PIXELS_PER_METRE := 10.0
const MAP_MIN := Vector2(-82, -57)
const MAP_MAX := Vector2(82, 57)
const TRACTOR_START := Vector2(5, 0)

const GROWER_WALK := preload("res://assets/2d/prototype/grower_walk.png")
const MECHANIC_WALK := preload("res://assets/2d/prototype/mechanic_walk.png")
const TRACTOR := preload("res://assets/2d/prototype/tractor.png")
const CONTACT_SHADOW := preload("res://assets/2d/production/contact_shadow.png")
const ProductionWorldScript := preload("res://scripts/production_world_2d.gd")
const AnimalIncidentScript := preload("res://scripts/animal_incident_2d.gd")
const WALK_FRAME_SIZE := 256

var socket := WebSocketPeer.new()
var discovery := PacketPeerUDP.new()
var relay_url := "ws://127.0.0.1:8787/ws"
var room := "------"
var connected := false
var inputs := {1: neutral_input(), 2: neutral_input()}
var last_acked := {1: -1, 2: -1}
var logical_positions := {1: Vector2(-2, 7), 2: Vector2(10, 9)}
var players: Dictionary = {}
var player_sprites: Dictionary = {}
var player_facings := {1: "down", 2: "down"}
var previous_actions := {1: false, 2: false}
var pending_actions := {1:false,2:false}
var player_modes := {1: "foot", 2: "foot"}
# Directional art integrated under the September 30 finish-game instruction; visual acceptance remains the user’s.
var tractor_directional_approved := true
var tractor_driver := 0
var tractor_motion_clock := 0.0
var tractor_facing := "down"
var wheel_front: Sprite2D
var wheel_rear: Sprite2D
var tractor_directions := {
 "down": preload("res://assets/2d/production/tractor_down.png"),
 "up": preload("res://assets/2d/production/tractor_up.png"),
 "left": preload("res://assets/2d/production/tractor_left.png"),
 "right": preload("res://assets/2d/production/tractor_right.png")
}
var tractor_body: CharacterBody2D
var tractor_sprite: Sprite2D
var world_root: Node2D
var left_container: SubViewportContainer
var right_container: SubViewportContainer
var left_camera: Camera2D
var right_camera: Camera2D
var split_divider: ColorRect
var split_screen := false
var debug_overview := false
var room_label: Label
var status_label: Label
var roster_label: Label
var latency_label: Label
var lobby_panel: PanelContainer
var lobby_backdrop: ColorRect
var qr_request: HTTPRequest
var qr_rect: TextureRect
var qr_status: Label
var admitted_players := 0
var cooperative_clues_sent := false
var latest_clues := {}
var latest_modes := {}
var disconnected_pause := false
var disconnected_was_paused := false
var animal_incident: AnimalIncident2D
var repair_incident: RepairIncident2D
var event_transition := 0.0
var weekend: WeekendSession2D
var tick := 0
var minimap: Control
var guidance: Control

static func neutral_input() -> Dictionary:
	return {"seq": -1, "x": 0.0, "y": 0.0, "action": false, "seen": 0}

func _ready() -> void:
	relay_url = _relay_from_environment()
	_build_world()
	_build_render_views()
	_build_ui()
	weekend=preload("res://scripts/weekend_session_2d.gd").new();add_child(weekend);weekend.setup(self)
	var map_layer:=CanvasLayer.new();map_layer.layer=9;add_child(map_layer)
	minimap=preload("res://scripts/farm_minimap.gd").new();map_layer.add_child(minimap);minimap.setup(self)
	guidance=preload("res://scripts/farm_guidance.gd").new();map_layer.add_child(guidance);guidance.setup(self)
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
	status_label.text = "Connecting to the farm…"
	if error != OK: status_label.text = "Relay connection failed: %s" % error_string(error)

func _process(_delta: float) -> void:
	while relay_url.is_empty() and discovery.get_available_packet_count() > 0:
		var announcement = JSON.parse_string(discovery.get_packet().get_string_from_utf8())
		if announcement is Dictionary and announcement.get("type") == "farm_relay" and int(announcement.get("version", 0)) == 1:
			var discovered_url := str(announcement.get("url", ""))
			if discovered_url.begins_with("ws://") or discovered_url.begins_with("wss://"):
				discovery.close(); _begin_connection(discovered_url)
	if relay_url.is_empty(): return
	socket.poll()
	var state := socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		if not connected:
			connected = true; _send({"type":"create", "version":PROTOCOL})
		while socket.get_available_packet_count() > 0:
			_handle(JSON.parse_string(socket.get_packet().get_string_from_utf8()))
	elif state == WebSocketPeer.STATE_CLOSED:
		status_label.text = "Relay disconnected. Restart this host to create a new room."

func _physics_process(delta: float) -> void:
	if weekend and (weekend.paused or weekend.phase=="results"): return
	tick += 1
	var now := Time.get_ticks_msec()
	for id in [1, 2]:
		var packet: Dictionary = inputs[id]
		if now - int(packet.seen) > STALE_INPUT_MS:
			packet.x = 0.0; packet.y = 0.0; packet.action = false
		var movement := Vector2(float(packet.x), float(packet.y)).limit_length(1.0)
		var keyboard_movement := _keyboard_vector(id)
		if keyboard_movement.length() > 0.0: movement = keyboard_movement
		var keyboard_action := Input.is_key_pressed(KEY_E) if id==1 else Input.is_key_pressed(KEY_SLASH)
		packet.action = bool(packet.action) or keyboard_action or bool(pending_actions[id])
		pending_actions[id]=false
		var action_pressed := bool(packet.action) and not bool(previous_actions[id])
		if player_modes[id] == "tractor":
			_drive_tractor(id, movement, action_pressed, delta)
		else:
			_move_player(id, movement, delta)
			if action_pressed: _try_context_action(id)
		previous_actions[id] = bool(packet.action)
		if connected and int(packet.seq) > int(last_acked[id]):
			var logical: Vector2 = logical_positions[id]
			_send({"type":"frame_ack", "playerId":id, "seq":packet.seq, "phase":"simulated", "position":[logical.x, logical.y]})
			last_acked[id] = packet.seq
	if weekend: weekend.update(delta,logical_positions,inputs)
	_update_camera(delta)

func _move_player(id: int, movement: Vector2, delta: float) -> void:
	var body: CharacterBody2D = players[id]
	body.velocity = movement * SPEED * PIXELS_PER_METRE
	body.move_and_slide()
	body.position.x = clampf(body.position.x, _logical_to_pixel(MAP_MIN).x, _logical_to_pixel(MAP_MAX).x)
	body.position.y = clampf(body.position.y, _logical_to_pixel(MAP_MIN).y, _logical_to_pixel(MAP_MAX).y)
	logical_positions[id] = (body.position - MAP_CENTER) / PIXELS_PER_METRE
	_update_walk_animation(id, movement)

func _try_context_action(id: int) -> void:
	# Result messages are a transition, not an invitation to board nearby gear.
	# Otherwise a new hold after storing grain can enter the parked tractor while
	# the mission ignores input, and the next job's first ACTION becomes EXIT.
	if weekend and weekend.next_phase != "": return
	if weekend and weekend.handle_action(id,logical_positions[id]): return
	if repair_incident and repair_incident.handle_action(id,logical_positions[id]): return
	if animal_incident and animal_incident.handles_context_action(id,players[id].position): return
	if tractor_driver == 0 and logical_positions[id].distance_to(_tractor_logical()) <= 11.0:
		tractor_driver = id
		player_modes[id] = "tractor"
		players[id].visible = false
		players[id].collision_layer=0
		logical_positions[id] = _tractor_logical()
		_send({"type":"mode", "playerId":id, "title":"TRACTOR", "actionLabel":"EXIT", "hint":"Drive through gold plots; engage the tool before sowing or harvesting"})
		if weekend and weekend.phase=="weather" and id==1: weekend._update_weather_guidance(true)
		else: _send({"type":"private", "playerId":id, "text":"FIELD WORK: Drive through gold plot markers. Engage field tool before sowing or harvesting. EXIT returns on foot."})
		return
	var destination: Dictionary = world_root.call("nearest_destination", players[id].position, 8.0)
	if not destination.is_empty():
		var message := "%s: %s" % [str(destination.label).to_upper(), str(destination.purpose)]
		status_label.text = message
		_send({"type":"private", "playerId":id, "text":message})

func _drive_tractor(id: int, movement: Vector2, action_pressed: bool, delta: float) -> void:
	tractor_body.velocity = movement * SPEED * 1.65 * PIXELS_PER_METRE
	tractor_body.move_and_slide()
	tractor_body.position.x = clampf(tractor_body.position.x, _logical_to_pixel(MAP_MIN).x, _logical_to_pixel(MAP_MAX).x)
	tractor_body.position.y = clampf(tractor_body.position.y, _logical_to_pixel(MAP_MIN).y, _logical_to_pixel(MAP_MAX).y)
	var logical := _tractor_logical()
	logical_positions[id] = logical
	var moving := tractor_body.get_real_velocity().length() > 2.0
	tractor_sprite.rotation = 0.0
	if movement.length() > 0.08:
		if tractor_directional_approved:
			var facing := "right" if movement.x > 0 else "left"
			if absf(movement.y) > absf(movement.x): facing = "down" if movement.y > 0 else "up"
			tractor_facing=facing
			tractor_sprite.texture = tractor_directions[facing]
			tractor_sprite.flip_h = false
		else:
			if absf(movement.x) > .08: tractor_sprite.flip_h = movement.x < 0
	wheel_front.visible=tractor_facing in ["left","right"];wheel_rear.visible=wheel_front.visible
	wheel_front.position=Vector2(-71,68) if tractor_facing=="left" else Vector2(72,68)
	wheel_rear.position=Vector2(50,51) if tractor_facing=="left" else Vector2(-50,51)
	if moving:
		wheel_front.rotation+=delta*tractor_body.get_real_velocity().length()*.1*(1 if tractor_facing=="right" else -1)
		wheel_rear.rotation+=delta*tractor_body.get_real_velocity().length()*.06*(1 if tractor_facing=="right" else -1)
		tractor_motion_clock += delta * tractor_body.get_real_velocity().length() * .10
		tractor_sprite.position.y = -30.0 + sin(tractor_motion_clock) * .6 if tractor_directional_approved else -18.0 + sin(tractor_motion_clock)*.6
		world_root.call("apply_tractor_work", tractor_body.position)
	else:
		tractor_sprite.position.y = -30.0 if tractor_directional_approved else -18.0
	if action_pressed:
		tractor_driver = 0; player_modes[id] = "foot"; players[id].visible = true
		var exit_spot := _safe_tractor_exit(id)
		if exit_spot==Vector2.INF:
			tractor_driver=id;player_modes[id]="tractor";players[id].hide();return
		logical_positions[id] = exit_spot; players[id].position = _logical_to_pixel(exit_spot);players[id].collision_layer=2
		_send({"type":"mode", "playerId":id, "title":"GROWER" if id == 1 else "MECHANIC", "actionLabel":"INTERACT", "hint":"Walk close to equipment to use it"})
		_send({"type":"private","playerId":id,"text":latest_clues.get(id,"Back on foot. Walk close to equipment to interact.")})

func _safe_tractor_exit(id: int) -> Vector2:
	var space=world_root.get_world_2d().direct_space_state
	for offset in [Vector2(4,0),Vector2(-4,0),Vector2(0,4),Vector2(0,-4),Vector2(5,5),Vector2(-5,5)]:
		var spot:Vector2=_tractor_logical()+offset
		var query:=PhysicsShapeQueryParameters2D.new();var shape:=CircleShape2D.new();shape.radius=8
		query.shape=shape;query.transform=Transform2D(0,_logical_to_pixel(spot));query.collision_mask=1;query.exclude=[players[id].get_rid(),tractor_body.get_rid()]
		if space.intersect_shape(query).is_empty(): return spot
	return Vector2.INF

func _tractor_logical() -> Vector2:
	return (tractor_body.position - MAP_CENTER) / PIXELS_PER_METRE

func _logical_to_pixel(value: Vector2) -> Vector2:
	return MAP_CENTER + value * PIXELS_PER_METRE

func _build_world() -> void:
	world_root = ProductionWorldScript.new(); add_child(world_root); world_root.call("build")
	var crop = world_root.get_node_or_null("BarleyField")
	if crop: crop.stage_changed.connect(_on_crop_stage_changed)
	tractor_body = CharacterBody2D.new(); tractor_body.name = "IllustratedTractor"; tractor_body.position = _logical_to_pixel(TRACTOR_START); tractor_body.collision_layer = 4; tractor_body.collision_mask = 1; world_root.add_child(tractor_body)
	var tractor_shadow := Sprite2D.new(); tractor_shadow.name = "ContactShadow"; tractor_shadow.texture = CONTACT_SHADOW; tractor_shadow.scale = Vector2(0.18, 0.09); tractor_shadow.position = Vector2(3, -3); tractor_shadow.z_index = -1; tractor_body.add_child(tractor_shadow)
	tractor_sprite = Sprite2D.new(); tractor_sprite.texture = tractor_directions["down"] if tractor_directional_approved else TRACTOR; tractor_sprite.scale = Vector2(0.30, 0.30); tractor_sprite.position = Vector2(0, -30 if tractor_directional_approved else -18); tractor_body.add_child(tractor_sprite)
	wheel_front=Sprite2D.new();wheel_front.texture=preload("res://assets/2d/production/tractor_wheel_front.png");wheel_front.hide();tractor_sprite.add_child(wheel_front)
	wheel_rear=Sprite2D.new();wheel_rear.texture=preload("res://assets/2d/production/tractor_wheel_rear.png");wheel_rear.hide();tractor_sprite.add_child(wheel_rear)
	_add_circle_collision(tractor_body, 15.0, Vector2(0, -6))
	for id in [1, 2]:
		var body := CharacterBody2D.new(); body.name = "Player%d" % id; body.position = _logical_to_pixel(logical_positions[id]); body.collision_layer = 2; body.collision_mask = 1; world_root.add_child(body); players[id] = body
		var foot_shadow := Sprite2D.new(); foot_shadow.texture = CONTACT_SHADOW; foot_shadow.scale = Vector2(.085,.055); foot_shadow.position = Vector2(1,0); foot_shadow.modulate = Color(.55,.62,.60,1.5); foot_shadow.z_index = -1; body.add_child(foot_shadow)
		_add_circle_collision(body, 5.5, Vector2(0, -3))
		var sprite := AnimatedSprite2D.new(); sprite.name = "WalkSprite"; sprite.sprite_frames = _make_walk_frames(GROWER_WALK if id == 1 else MECHANIC_WALK); sprite.position = Vector2(0, -17); sprite.scale = Vector2(0.14, 0.14); sprite.animation = "walk_down"; sprite.frame = 0; body.add_child(sprite); player_sprites[id] = sprite
		var identity := Line2D.new(); identity.name = "PlayerMarker"; identity.width = 3.0; identity.default_color = Color("#e65b45") if id == 1 else Color("#3aa6c9"); identity.z_index = -1
		if id == 1:
			for marker_index in range(17):
				var marker_angle := TAU * marker_index / 16.0
				identity.add_point(Vector2(cos(marker_angle) * 7.0, sin(marker_angle) * 3.2 - 1.0))
		else:
			identity.points = PackedVector2Array([Vector2(0,-6),Vector2(7,-1),Vector2(0,4),Vector2(-7,-1),Vector2(0,-6)])
		body.add_child(identity)
	animal_incident = AnimalIncidentScript.new(); animal_incident.name = "AnimalIncident2D"; add_child(animal_incident); animal_incident.setup(world_root,players)
	animal_incident.private_message.connect(_on_incident_private_message)
	animal_incident.controller_mode.connect(_on_incident_controller_mode)
	repair_incident = preload("res://scripts/repair_incident_2d.gd").new(); add_child(repair_incident)
	repair_incident.setup(world_root,animal_incident)
	repair_incident.private_message.connect(_on_incident_private_message)
	repair_incident.controller_mode.connect(_on_incident_controller_mode)

var mission_facts := {}
func _on_incident_private_message(player_id: int, text_value: String) -> void:
	for prefix in ["WELCOME:","FLOCK:","GATE:","TEAM CHOICE:","DIAGNOSIS:","STORES:","FORECAST:","STORAGE CREW:","STORE REPORT:","BUYER:","SOLO ","DELIVERY BRIEFING:","WEEKEND COMPLETE:"]:
		if text_value.begins_with(prefix):mission_facts[player_id]=text_value;break
	latest_clues[player_id] = text_value
	_send({"type":"private","playerId":player_id,"text":text_value,"clue":mission_facts.get(player_id,text_value)})

func _on_incident_controller_mode(player_id: int, title_value: String, action_label: String, hint_value: String) -> void:
	latest_modes[player_id]={"type":"mode","playerId":player_id,"title":title_value,"actionLabel":action_label,"hint":hint_value}
	if player_modes.get(player_id,"foot") == "tractor": return
	_send({"type":"mode","playerId":player_id,"title":title_value,"actionLabel":action_label,"hint":hint_value})

func _on_crop_stage_changed(stage_name: String) -> void:
	status_label.text = "Barley field: %s" % stage_name.to_lower()
	if tractor_driver > 0: _send({"type":"private", "playerId":tractor_driver, "text":"FIELD UPDATE: barley is now %s." % stage_name.to_lower()})

func _make_walk_frames(sheet: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var names := ["walk_down", "walk_left", "walk_right", "walk_up"]
	for row in range(4):
		var animation_name: String = names[row]
		frames.add_animation(animation_name)
		frames.set_animation_loop(animation_name, true)
		frames.set_animation_speed(animation_name, 8.0)
		for column in range(4):
			var frame := AtlasTexture.new()
			frame.atlas = sheet
			frame.region = Rect2(column * WALK_FRAME_SIZE, row * WALK_FRAME_SIZE, WALK_FRAME_SIZE, WALK_FRAME_SIZE)
			frames.add_frame(animation_name, frame)
	return frames

func _update_walk_animation(id: int, movement: Vector2) -> void:
	var sprite: AnimatedSprite2D = player_sprites[id]
	# Breathing is presentation only and never moves the collision or foot anchor.
	var breath := sin(float(Time.get_ticks_msec())*.0024+float(id)*2.1)
	sprite.scale = Vector2(.14,.14)
	var boots := [[252,252,252,253],[255,255,255,255],[255,255,255,255],[230,230,230,230]] if id == 1 else [[249,248,248,248],[242,241,242,240],[255,255,255,255],[238,243,242,238]]
	var row := ["down","left","right","up"].find(str(player_facings[id]))
	var foot_y := float(boots[maxi(0,row)][sprite.frame])
	sprite.position.y = -(foot_y-128.0)*.14
	if movement.length() <= 0.08:
		sprite.scale.y = .14*(1.0+breath*.009)
		sprite.position.y -= breath*.15
		sprite.pause()
		sprite.frame = 0
		sprite.position.y = -(float(boots[maxi(0,row)][0])-128.0)*.14-breath*.15
		return
	var facing := "down"
	if absf(movement.x) > absf(movement.y): facing = "right" if movement.x > 0.0 else "left"
	else: facing = "down" if movement.y > 0.0 else "up"
	player_facings[id] = facing
	sprite.speed_scale = clampf(movement.length(),.45,1.0)
	var animation_name := "walk_%s" % facing
	if sprite.animation != animation_name or not sprite.is_playing(): sprite.play(animation_name)
	row=["down","left","right","up"].find(facing)
	sprite.position.y=-(float(boots[row][sprite.frame])-128.0)*.14

func _keyboard_vector(id: int) -> Vector2:
	var result := Vector2.ZERO
	if id == 1:
		result.x = float(Input.is_key_pressed(KEY_D)) - float(Input.is_key_pressed(KEY_A))
		result.y = float(Input.is_key_pressed(KEY_S)) - float(Input.is_key_pressed(KEY_W))
	else:
		result.x = float(Input.is_key_pressed(KEY_RIGHT)) - float(Input.is_key_pressed(KEY_LEFT))
		result.y = float(Input.is_key_pressed(KEY_DOWN)) - float(Input.is_key_pressed(KEY_UP))
	return result.normalized() if result.length() > 0.0 else result

func _add_circle_collision(body: CollisionObject2D, radius: float, offset: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new(); shape.radius = radius
	collision.shape = shape; collision.position = offset; body.add_child(collision)

func _build_render_views() -> void:
	# Keep the shared/split SubViewport composition above the root World2D.
	# A Node2D renders in the root viewport even without a Camera2D, so a
	# negative layer would let that full-map image hide the adaptive cameras.
	var layer := CanvasLayer.new(); layer.layer = 1; add_child(layer)
	left_container = SubViewportContainer.new(); left_container.stretch = true; left_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(left_container)
	right_container = SubViewportContainer.new(); right_container.stretch = true; right_container.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(right_container)
	left_camera = _create_world_view(left_container, "SharedCameraViewport")
	right_camera = _create_world_view(right_container, "PlayerTwoCameraViewport")
	split_divider = ColorRect.new(); split_divider.color = Color("#3a2418"); split_divider.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(split_divider)
	_decorate_split_divider(); _apply_view_layout()

func _create_world_view(container: SubViewportContainer, view_name: String) -> Camera2D:
	var viewport := SubViewport.new(); viewport.name = view_name; viewport.world_2d = get_viewport().world_2d; viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS; viewport.handle_input_locally = false; viewport.transparent_bg = false; container.add_child(viewport)
	var camera := Camera2D.new(); camera.position = MAP_CENTER; camera.zoom = Vector2(1.34, 1.34); viewport.add_child(camera); camera.enabled = true
	return camera

func _decorate_split_divider() -> void:
	split_divider.clip_contents = true
	var timber := TextureRect.new()
	timber.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	timber.texture = preload("res://assets/2d/production/interior_timber.png")
	timber.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	timber.stretch_mode = TextureRect.STRETCH_TILE
	timber.modulate = Color(.48,.42,.32)
	timber.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	timber.mouse_filter = Control.MOUSE_FILTER_IGNORE
	split_divider.add_child(timber)
	for side in [0,1]:
		var trim := ColorRect.new()
		trim.color = Color("#c7b68a")
		trim.anchor_left = float(side); trim.anchor_right = float(side)
		trim.anchor_bottom = 1.0
		trim.offset_left = -2 if side else 0; trim.offset_right = 0 if side else 2
		trim.mouse_filter = Control.MOUSE_FILTER_IGNORE
		split_divider.add_child(trim)

func _apply_view_layout() -> void:
	var screen := get_viewport().get_visible_rect().size
	left_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if split_screen:
		left_container.anchor_right = 0.5; left_container.offset_right = -5
		right_container.anchor_left = 0.5; right_container.anchor_right = 1.0; right_container.anchor_bottom = 1.0; right_container.offset_left = 5; right_container.visible = true
		split_divider.position = Vector2(screen.x * 0.5 - 5, 0); split_divider.size = Vector2(10, screen.y); split_divider.visible = true
	else:
		right_container.visible = false; split_divider.visible = false

func _update_camera(delta: float) -> void:
	var one: Vector2 = logical_positions[1]
	var two: Vector2 = one if weekend and weekend.solo else logical_positions[2]
	var separation := one.distance_to(two)
	if debug_overview:
		if split_screen: split_screen = false; _apply_view_layout()
		_move_camera(left_camera, MAP_CENTER, 0.56, delta); return
	var should_split := separation > (MERGE_DISTANCE if split_screen else SPLIT_DISTANCE)
	if should_split != split_screen: split_screen = should_split; _apply_view_layout()
	if split_screen:
		_move_camera(left_camera, _logical_to_pixel(one), 1.42, delta)
		_move_camera(right_camera, _logical_to_pixel(two), 1.42, delta)
	else:
		var zoom := clampf(1.48 - separation * 0.012, 1.05, 1.42)
		_move_camera(left_camera, _logical_to_pixel((one + two) * 0.5), zoom, delta)

func _move_camera(camera: Camera2D, target: Vector2, zoom_value: float, delta: float) -> void:
	var blend := minf(1.0, delta * 4.5)
	var visible_size := camera.get_viewport_rect().size / zoom_value
	var half_visible := visible_size * 0.5
	var minimum := half_visible
	var maximum := Vector2(1700,1200) - half_visible
	var clamped_target := target
	clamped_target.x = 850.0 if minimum.x > maximum.x else clampf(target.x, minimum.x, maximum.x)
	clamped_target.y = 600.0 if minimum.y > maximum.y else clampf(target.y, minimum.y, maximum.y)
	camera.position = camera.position.lerp(clamped_target, blend)
	camera.zoom = camera.zoom.lerp(Vector2(zoom_value, zoom_value), blend)

func _handle(message) -> void:
	if not message is Dictionary: return
	match message.get("type", ""):
		"created":
			room = str(message.room); room_label.text = room; status_label.text = "Scan the QR code or enter this room code"; _load_room_qr(); print("PROBE_ROOM=%s" % room)
		"roster":
			admitted_players = 0
			var pending_count := 0
			for player in message.players:
				if player.admission == "admitted" and player.connected: admitted_players += 1
				elif player.admission == "pending" and player.connected: pending_count += 1
			if weekend and weekend.phase not in ["waiting","results"]:
				var required_players:=1 if weekend.solo else 2
				if admitted_players<required_players:
					if not disconnected_pause: disconnected_was_paused=weekend.paused
					weekend.paused=true;disconnected_pause=true;world_root.crop_field.set_process(false);weekend.phase_banner.text="PAUSED · reconnect missing farmer"
				elif disconnected_pause:
					weekend.paused=disconnected_was_paused;disconnected_pause=false
					world_root.crop_field.set_process(not weekend.paused)
					weekend.phase_banner.text="PAUSED · resume from phone or P" if weekend.paused else "SOLO TEST WEEKEND" if weekend.solo else "BRACKENRIDGE WEEKEND"
			if weekend and weekend.phase=="arrival" and admitted_players>=2: weekend.solo=false;players[2].show()
			roster_label.text = "%d phone(s) ready · Enter/Select admits" % pending_count if pending_count > 0 else "%d of 2 farmers joined" % admitted_players
			# One admitted phone is enough for a full assisted solo test weekend.
			# The second phone can still join with the room code it already scanned.
			_set_lobby_visible(admitted_players == 0)
			if OS.get_environment("FARM_AUTO_ADMIT") == "1":
				for player in message.players:
					if player.connected and player.admission == "pending": _admit(int(player.id))
			if admitted_players >= 1 and not cooperative_clues_sent:
				cooperative_clues_sent = true
				weekend.start(admitted_players)
			for player in message.players:
				if player.connected and player.admission == "admitted" and latest_clues.has(int(player.id)):
					_send({"type":"private","playerId":int(player.id),"text":latest_clues[int(player.id)],"clue":mission_facts.get(int(player.id),latest_clues[int(player.id)])})
					if weekend.phase=="results": _send({"type":"mode","playerId":int(player.id),"title":"RESULTS","actionLabel":"READY","hint":"Choose another weekend on your phone"})
					elif player_modes.get(int(player.id),"foot")=="tractor": _send({"type":"mode","playerId":int(player.id),"title":"TRACTOR","actionLabel":"EXIT","hint":"Drag to drive; release to stop"})
					elif latest_modes.has(int(player.id)): _send(latest_modes[int(player.id)])
		"command":
			if weekend: weekend.command(int(message.playerId),str(message.command))
		"input":
			var id := int(message.get("playerId", 0)); if not inputs.has(id): return
			var current: Dictionary = inputs[id]; if int(message.seq) <= int(current.seq): return
			if bool(message.action) and not bool(current.action): pending_actions[id]=true
			inputs[id] = {"seq":int(message.seq), "x":float(message.x), "y":float(message.y), "action":bool(message.action), "seen":Time.get_ticks_msec()}
		"reset_input":
			var id := int(message.playerId); inputs[id] = neutral_input(); pending_actions[id]=false;last_acked[id] = -1
			if weekend and weekend.phase=="results":
				weekend.replay_votes.erase(id);weekend._update_replay_status()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for id in [1, 2]: _admit(id)
	if event is InputEventKey and event.pressed:
		if event.keycode==KEY_E: pending_actions[1]=true
		if event.keycode==KEY_SLASH: pending_actions[2]=true
		if event.keycode == KEY_1: _admit(1)
		if event.keycode == KEY_2: _admit(2)
		if event.keycode == KEY_P and weekend: weekend.command(1,"pause")
		if event.keycode == KEY_V and weekend: weekend.sound_enabled=not weekend.sound_enabled
		if event.keycode == KEY_M: debug_overview = not debug_overview
		if event.keycode == KEY_C: world_root.call("cycle_crop_state")
		if event.keycode == KEY_R and animal_incident:
			weekend.restart(weekend.seed_value)
		if event.keycode == KEY_T:
			logical_positions[1] = Vector2(-46, 31); logical_positions[2] = Vector2(48, -30); players[1].position = _logical_to_pixel(logical_positions[1]); players[2].position = _logical_to_pixel(logical_positions[2])

func _admit(id: int) -> void:
	_send({"type":"admit", "playerId":id})
	_send({"type":"private", "playerId":id, "text":"FARM RADIO: Joining the farm. Events start with the first farmer for solo testing."})

func _send(message: Dictionary) -> void:
	if message.get("type")=="private":
		var id:int=int(message.get("playerId",0))
		message.text=str(message.get("text","")).left(300)
		message.clue=str(message.get("clue",mission_facts.get(id,message.text))).left(300)
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN: socket.send_text(JSON.stringify(message))

func _load_room_qr() -> void:
	var http_url := relay_url.trim_suffix("/ws").replace("ws://", "http://").replace("wss://", "https://")
	var error := qr_request.request("%s/qr?room=%s" % [http_url, room])
	if error != OK: qr_status.text = "QR unavailable · use room code"

func _on_qr_loaded(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200: qr_status.text = "QR unavailable · use room code"; return
	var image := Image.new()
	if image.load_png_from_buffer(body) != OK: qr_status.text = "QR unavailable · use room code"; return
	qr_rect.texture = ImageTexture.create_from_image(image); qr_status.text = "SCAN TO JOIN"

func _build_ui() -> void:
	var layer := CanvasLayer.new(); layer.layer = 10; add_child(layer)
	lobby_backdrop = ColorRect.new(); lobby_backdrop.name = "JoiningBackdrop"; lobby_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); lobby_backdrop.color = Color(0.025,0.065,0.045,0.82); lobby_backdrop.mouse_filter = Control.MOUSE_FILTER_STOP; layer.add_child(lobby_backdrop)
	lobby_panel = PanelContainer.new(); lobby_panel.name = "JoiningCard"; lobby_panel.set_anchors_preset(Control.PRESET_CENTER); lobby_panel.position = Vector2(-380, -165); lobby_panel.size = Vector2(760, 330); layer.add_child(lobby_panel)
	var style := StyleBoxFlat.new(); style.bg_color = Color(0.035, 0.09, 0.07, 0.94); style.border_color = Color("#e7c66f"); style.set_border_width_all(3); style.corner_radius_top_left = 12; style.corner_radius_top_right = 12; style.corner_radius_bottom_left = 12; style.corner_radius_bottom_right = 12; lobby_panel.add_theme_stylebox_override("panel", style)
	var margin := MarginContainer.new(); margin.add_theme_constant_override("margin_left", 30); margin.add_theme_constant_override("margin_top", 24); margin.add_theme_constant_override("margin_right", 30); margin.add_theme_constant_override("margin_bottom", 24); lobby_panel.add_child(margin)
	var content := HBoxContainer.new(); content.add_theme_constant_override("separation", 32); margin.add_child(content)
	var text_box := VBoxContainer.new(); text_box.custom_minimum_size = Vector2(440, 258); text_box.add_theme_constant_override("separation", 8); content.add_child(text_box)
	var title := Label.new(); title.text = "BRACKENRIDGE FARM"; title.add_theme_font_size_override("font_size", 27); title.add_theme_color_override("font_color", Color("#ffe9a8")); text_box.add_child(title)
	var subtitle := Label.new(); subtitle.text = "Join from a phone to start · two farmers recommended"; subtitle.add_theme_font_size_override("font_size", 18); subtitle.add_theme_color_override("font_color", Color("#b9ddb1")); text_box.add_child(subtitle)
	room_label = Label.new(); room_label.text = room; room_label.add_theme_font_size_override("font_size", 58); room_label.add_theme_color_override("font_color", Color.WHITE); text_box.add_child(room_label)
	status_label = Label.new(); status_label.text = "Preparing room…"; status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; text_box.add_child(status_label)
	roster_label = Label.new(); roster_label.text = "0 of 2 farmers joined"; roster_label.add_theme_font_size_override("font_size", 20); text_box.add_child(roster_label)
	latency_label = Label.new(); latency_label.text = "Phone controls · illustrated 2D world"; latency_label.add_theme_color_override("font_color", Color("#a7d7b0")); text_box.add_child(latency_label)
	var qr_box := VBoxContainer.new(); qr_box.custom_minimum_size = Vector2(220, 258); qr_box.alignment = BoxContainer.ALIGNMENT_CENTER; content.add_child(qr_box)
	qr_rect = TextureRect.new(); qr_rect.custom_minimum_size = Vector2(210, 210); qr_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE; qr_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED; qr_box.add_child(qr_rect)
	qr_status = Label.new(); qr_status.text = "QR loading…"; qr_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; qr_box.add_child(qr_status)
	qr_request = HTTPRequest.new(); qr_request.request_completed.connect(_on_qr_loaded); add_child(qr_request)

func _set_lobby_visible(visible_value: bool) -> void:
	if lobby_panel: lobby_panel.visible = visible_value
	if lobby_backdrop: lobby_backdrop.visible = visible_value

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_SIZE_CHANGED and left_container: _apply_view_layout()
