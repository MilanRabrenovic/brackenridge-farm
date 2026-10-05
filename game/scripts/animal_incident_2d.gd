class_name AnimalIncident2D
extends Node

signal private_message(player_id: int, text: String)
signal controller_mode(player_id: int, title: String, action_label: String, hint: String)

const PIXELS_PER_METRE := 10.0
const INCIDENT_TIME := 105.0
const GATE := Vector2(-42,-9)
const SAFE_CENTRE := Vector2(-56,-29)
const ESCAPED_POSITIONS := [Vector2(-67,8),Vector2(-58,15),Vector2(-73,24),Vector2(-50,21),Vector2(-39,10)]
const RETURNED_LINE_Y := -18.0

var animation_clock := 0.0
var escape_seconds := 0.0
var escape_duration := 4.0
var escape_variant := 0
var world: Node2D
var players: Dictionary
var sheep: Array[Node2D] = []
var state := "waiting"
var time_left := INCIDENT_TIME
var gate_holder := 0
var latch_seconds := 0.0
var latch_owner := 0
var returned: Dictionary = {}
var sheep_motion: Dictionary = {}
var incident_panel: PanelContainer
var title_label: Label
var timer_label: Label
var objective_label: Label
var progress_label: Label
var feedback_label: Label
var gate_marker: Node2D
var gate_ring: Line2D
var gate_label: Label
var safe_marker: Node2D

func setup(world_node: Node2D, player_bodies: Dictionary) -> void:
	world = world_node
	players = player_bodies
	for index in range(5):
		var actor := world.get_node_or_null("PastureSheep%02d" % index) as Node2D
		if actor != null:
			sheep.append(actor)
			sheep_motion[actor.get_instance_id()] = Vector2.ZERO
			var sprite := actor.get_child(1) as Sprite2D
			if sprite:
				var material := ShaderMaterial.new()
				material.shader=preload("res://shaders/sheep_gait.gdshader")
				sprite.material=material
	_build_world_markers()
	_build_objective_ui()

func start_incident() -> void:
	if sheep.size() != 5: return
	state = "active"
	title_label.text = "SHEEP ON THE LOOSE"
	world.call("set_destination_suppressed","pasture_gate",true)
	time_left = INCIDENT_TIME
	gate_holder = 0
	latch_seconds=0;latch_owner=0
	returned.clear()
	animation_clock=0;escape_seconds=escape_duration
	for index in range(sheep.size()):
		sheep[index].position = world.call("logical_to_pixel", Vector2(ESCAPED_POSITIONS[index].x,-13))
		var sprite:=sheep[index].get_child(1) as Sprite2D
		if sprite:sprite.modulate=Color.WHITE
		sheep[index].visible = true
		sheep_motion[sheep[index].get_instance_id()] = Vector2.ZERO
	incident_panel.visible = true
	gate_marker.visible = true
	safe_marker.visible = true
	objective_label.text = "Share your phone clues. Open the gate for eight seconds, then help guide the five sheep home."
	feedback_label.text = "One found a gap — now they are all copying it!"
	private_message.emit(1, "FLOCK: Storm wind arrives in 1:45. Sheep move away from a nearby farmer; approach from below and guide them toward the marked pasture.")
	private_message.emit(2, "GATE: ACTION at the marked gate opens the latch for eight seconds. Help guide the flock while it is open, then return to refresh it. Holding ACTION also keeps it open.")
	controller_mode.emit(1, "HERDER", "GUIDE", "Approach from below and steer the flock toward the pasture")
	controller_mode.emit(2, "GATE KEEPER", "OPEN GATE", "ACTION opens the gate for eight seconds; return to refresh it")
	_update_ui()

func restart_incident() -> void:
	start_incident()

func update_incident(delta: float, logical_positions: Dictionary, inputs: Dictionary) -> void:
	if state != "active": return
	animation_clock+=delta
	time_left = maxf(0.0, time_left - delta)
	var holding:=_find_gate_holder(logical_positions, inputs)
	if holding>0:latch_owner=holding;latch_seconds=8.0
	else:latch_seconds=maxf(0,latch_seconds-delta)
	gate_holder=latch_owner if latch_seconds>0 else 0
	_update_gate_marker()
	if escape_seconds>0:
		escape_seconds=maxf(0,escape_seconds-delta)
		for index in range(sheep.size()): _escape_sheep(sheep[index],index)
	else:
		for actor in sheep:
			_update_sheep(actor, delta, logical_positions, inputs)
	_update_ui()
	if returned.size() == sheep.size():
		_finish(true)
	elif time_left <= 0.0:
		_finish(false)

func handles_context_action(_player_id: int, pixel_position: Vector2) -> bool:
	if state != "active": return false
	var logical: Vector2 = world.call("pixel_to_logical", pixel_position)
	return logical.distance_to(GATE) <= 7.0

func active() -> bool:
	return state == "active"

func result() -> String:
	return state

func returned_count() -> int:
	return returned.size()

func _find_gate_holder(logical_positions: Dictionary, inputs: Dictionary) -> int:
	for id in [1,2]:
		var packet: Dictionary = inputs.get(id,{})
		if bool(packet.get("action",false)) and Vector2(logical_positions.get(id,Vector2.ZERO)).distance_to(GATE) <= 7.0:
			return id
	return 0

func _update_sheep(actor: Node2D, delta: float, logical_positions: Dictionary, inputs: Dictionary) -> void:
	var key := actor.get_instance_id()
	var position: Vector2 = world.call("pixel_to_logical", actor.position)
	if returned.has(key):
		var rest_direction := SAFE_CENTRE - position
		if rest_direction.length() > 2.0: position += rest_direction.normalized() * delta * 0.8
		actor.position = world.call("logical_to_pixel", position)
		_bob_sheep(actor, rest_direction.normalized() * .8 if rest_direction.length()>2 else Vector2.ZERO)
		return
	var nearest_id := 0
	var nearest_distance := 999.0
	for id in [1,2]:
		var player_position := Vector2(logical_positions.get(id,Vector2.ZERO))
		var distance := position.distance_to(player_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = id
	var desired := Vector2.ZERO
	if nearest_distance <= 12.5:
		var player_position := Vector2(logical_positions[nearest_id])
		var flee := (position - player_position).normalized()
		var route_target := GATE + Vector2(0,3) if position.y > -10.0 and absf(position.x - GATE.x) > 5.0 else GATE + Vector2(0,-5) if position.y > -10.0 else SAFE_CENTRE
		var route_pull := (route_target - position).normalized()
		var player_input: Dictionary = inputs.get(nearest_id,{})
		var panic := 1.35 if nearest_distance < 4.0 and Vector2(float(player_input.get("x",0.0)),float(player_input.get("y",0.0))).length() > 0.75 else 1.0
		# Rushing creates a bounded side-step; calm guiding retains a reliable route.
		var jink:=Vector2(-flee.y,flee.x)*sin(animation_clock*3.5+float(sheep.find(actor))*1.7)*.55 if panic>1 else Vector2.ZERO
		desired = (flee * 0.90 + route_pull * 1.35+jink).normalized() * 2.9 * panic
	else:
		desired = Vector2(sin(float(sheep.find(actor)) + animation_clock * .7),cos(float(sheep.find(actor)) + animation_clock * .5)) * 0.10
	var previous_motion := Vector2(sheep_motion.get(key,Vector2.ZERO))
	var motion := previous_motion.lerp(desired,minf(1.0,delta * 3.2))
	var next := position + motion * delta
	# The south hedge is a real barrier for the flock. The gate is the only
	# crossing; ACTION refreshes an eight-second opening window.
	if position.y > -9.0 and next.y <= -9.0:
		if gate_holder == 0 or absf(next.x - GATE.x) > 6.0:
			next.y = -8.65
			motion.y = absf(motion.y) * 0.45
	if position.y <= -9.0 and next.y > -9.0:
		next.y = -9.35
	next.x = clampf(next.x,-80.0,-29.0)
	next.y = clampf(next.y,-54.0,37.0)
	actor.position = world.call("logical_to_pixel",next)
	sheep_motion[key] = motion
	_bob_sheep(actor,motion)
	if next.y <= RETURNED_LINE_Y:
		returned[key] = true
		var sprite := actor.get_child(1) as Sprite2D if actor.get_child_count() > 1 else null
		if sprite: sprite.modulate = Color(0.88,1.0,0.84,1.0)

func _escape_sheep(actor: Node2D, index: int) -> void:
	# Staggered, seeded order. One bounded opening spectacle per incident;
	# safe sheep stay safe afterwards, so successful teamwork is not erased.
	var delay:=float((index+escape_variant)%5)*.18
	var t:=clampf(escape_duration-escape_seconds-delay,0,3.1)
	var origin:=Vector2(ESCAPED_POSITIONS[index].x,-13)
	var landing:=Vector2(origin.x,-5)
	var point:Vector2=origin.lerp(landing,minf(t/.8,1))
	if t>.8:point=landing.lerp(ESCAPED_POSITIONS[index],clampf((t-.8)/2.3,0,1))
	actor.position=world.call("logical_to_pixel",point)
	_bob_sheep(actor,Vector2(0,3))
	var sprite:=actor.get_child(1) as Sprite2D
	if sprite:
		var hop:=sin(PI*minf(t/.8,1))*24
		sprite.position.y-=hop
		var shadow:=actor.get_child(0) as Sprite2D
		if shadow:shadow.modulate.a=.85-hop/80

func _bob_sheep(actor: Node2D, motion: Vector2) -> void:
	var sprite := actor.get_child(1) as Sprite2D if actor.get_child_count() > 1 else null
	if sprite == null: return
	var moving:=motion.length()>.3
	var gait:=animation_clock*(11 if motion.length()>3 else 8)+float(sheep.find(actor))*1.8
	# Body settles gently; diagonal leg pairs step independently in the shader.
	sprite.position.y=-1.5+sin(gait*2)*(.6 if moving else .15)
	if absf(motion.x) > 0.12: sprite.flip_h = motion.x < 0.0
	if sprite.material:
		sprite.material.set_shader_parameter("gait",gait)
		sprite.material.set_shader_parameter("stride",1.0 if moving else 0.0)
	var shadow:=actor.get_child(0) as Sprite2D
	if shadow:shadow.modulate.a=.85

func _finish(success: bool) -> void:
	state = "success" if success else "failure"
	world.call("set_destination_suppressed","pasture_gate",false)
	gate_holder = 0
	_update_gate_marker()
	if success:
		objective_label.text = "FLOCK SAFE — you combined both clues and brought all five sheep home."
		feedback_label.text = "Pasture secure. Choose an improvement before the next job."
		private_message.emit(1,"SUCCESS: All five sheep are safe. Your calm approach kept the flock together.")
		private_message.emit(2,"SUCCESS: All five sheep are safe. Holding the latch gave the flock a clear route.")
	else:
		objective_label.text = "STORM ARRIVED — some sheep remain outside the pasture."
		feedback_label.text = "The farm continues. Choose an improvement before the next job."
		private_message.emit(1,"RESULT: The storm arrived before the flock was safe. Press R on the host to retry.")
		private_message.emit(2,"RESULT: The storm arrived before the flock was safe. Press R on the host to retry.")
	for id in [1,2]: controller_mode.emit(id,"GROWER" if id == 1 else "MECHANIC","INTERACT","Walk close to equipment or a destination to use it")

func _update_ui() -> void:
	var seconds := ceili(time_left)
	timer_label.text = "%d:%02d" % [seconds / 60, seconds % 60]
	progress_label.text = "%d / %d SHEEP SAFE" % [returned.size(),sheep.size()]
	if state == "active" and escape_seconds>0:
		feedback_label.text="FENCE BREAKOUT! Approach calmly from below; rushing makes them jink"
	elif state == "active":
		feedback_label.text = "Gate open %ds — both can guide sheep; refresh at the latch" % ceili(latch_seconds) if gate_holder > 0 else "Gate shut — ACTION at the latch opens an eight-second window"

func _update_gate_marker() -> void:
	if gate_ring == null: return
	gate_ring.default_color = Color("#70d27a") if gate_holder > 0 else Color("#f2b84b")
	gate_label.text = "OPEN %ds" % ceili(latch_seconds) if gate_holder > 0 else "OPEN GATE"

func _build_world_markers() -> void:
	gate_marker = Node2D.new(); gate_marker.name = "AnimalIncidentGateMarker"; gate_marker.position = world.call("logical_to_pixel",GATE); gate_marker.z_index = 45; world.add_child(gate_marker)
	gate_ring = _make_ring(31.0,Color("#f2b84b")); gate_marker.add_child(gate_ring)
	gate_label = _make_world_label("HOLD ACTION",Vector2(-70,-58),140); gate_marker.add_child(gate_label)
	safe_marker = Node2D.new(); safe_marker.name = "AnimalIncidentSafePasture"; safe_marker.position = world.call("logical_to_pixel",SAFE_CENTRE); safe_marker.z_index = -5; world.add_child(safe_marker)
	var safe_ring := _make_ring(78.0,Color(0.42,0.85,0.48,0.72)); safe_ring.width = 5.0; safe_marker.add_child(safe_ring)
	safe_marker.add_child(_make_world_label("SAFE PASTURE",Vector2(-72,-102),144))
	gate_marker.visible = false; safe_marker.visible = false

func _make_ring(radius: float, colour: Color) -> Line2D:
	var ring := Line2D.new(); ring.width = 4.0; ring.default_color = colour; ring.closed = true
	for index in range(33):
		var angle := TAU * float(index) / 32.0
		ring.add_point(Vector2(cos(angle),sin(angle) * 0.48) * radius)
	return ring

func _make_world_label(text_value: String, offset: Vector2, width: float) -> Label:
	var label := Label.new(); label.text = text_value; label.position = offset; label.size = Vector2(width,26); label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",12); label.add_theme_color_override("font_color",Color("#fff3c4")); label.add_theme_color_override("font_outline_color",Color("#1b3527")); label.add_theme_constant_override("outline_size",5)
	return label

func _build_objective_ui() -> void:
	var layer := CanvasLayer.new(); layer.layer = 8; add_child(layer)
	incident_panel = PanelContainer.new(); incident_panel.name = "AnimalIncidentPanel"; incident_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT); incident_panel.position = Vector2(-536,24); incident_panel.size = Vector2(512,176); incident_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE; layer.add_child(incident_panel)
	var style := StyleBoxFlat.new(); style.bg_color = Color(0.035,0.10,0.075,0.94); style.border_color = Color("#e7c66f"); style.set_border_width_all(3); style.set_corner_radius_all(12); incident_panel.add_theme_stylebox_override("panel",style)
	var margin := MarginContainer.new(); margin.add_theme_constant_override("margin_left",18); margin.add_theme_constant_override("margin_right",18); margin.add_theme_constant_override("margin_top",12); margin.add_theme_constant_override("margin_bottom",12); incident_panel.add_child(margin)
	var content := VBoxContainer.new(); content.add_theme_constant_override("separation",5); margin.add_child(content)
	var heading := HBoxContainer.new(); content.add_child(heading)
	var title := Label.new(); title_label = title; title.text = "SHEEP ON THE LOOSE"; title.size_flags_horizontal = Control.SIZE_EXPAND_FILL; title.add_theme_font_size_override("font_size",21); title.add_theme_color_override("font_color",Color("#ffe6a0")); heading.add_child(title)
	timer_label = Label.new(); timer_label.text = "1:45"; timer_label.add_theme_font_size_override("font_size",22); timer_label.add_theme_color_override("font_color",Color.WHITE); heading.add_child(timer_label)
	objective_label = Label.new(); objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; objective_label.custom_minimum_size = Vector2(470,48); objective_label.add_theme_font_size_override("font_size",15); content.add_child(objective_label)
	var status_row := VBoxContainer.new(); status_row.add_theme_constant_override("separation",3); content.add_child(status_row)
	progress_label = Label.new(); progress_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL; progress_label.add_theme_font_size_override("font_size",15); progress_label.add_theme_color_override("font_color",Color("#a9e2a6")); status_row.add_child(progress_label)
	feedback_label = Label.new(); feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT; feedback_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART; feedback_label.custom_minimum_size = Vector2(0,20); feedback_label.add_theme_font_size_override("font_size",13); feedback_label.add_theme_color_override("font_color",Color("#fff0c4")); status_row.add_child(feedback_label)
	incident_panel.visible = false
