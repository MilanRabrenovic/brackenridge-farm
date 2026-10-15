extends Control
# Public, role-aware wayfinding. Never consults diagnosis or buyer preferences.
var host: Node
var cards: Array[Dictionary] = []
const INK := Color("#173329")
const CREAM := Color("#ffe8aa")

func setup(owner_host: Node) -> void:
	host = owner_host
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func task(id: int) -> Dictionary:
	var s = host.weekend
	var p: Vector2 = host.logical_positions[id]
	var target: Vector2 = s.HAY
	var label := "CHECK HAY"
	var action := "ACTION · check hay"
	var radius := 7.0
	if s.next_phase != "": return {"label":"NEXT JOB", "hint":"Take a breath — the next job is coming", "target":p, "near":true}
	match s.phase:
		"sheep":
			target = host.animal_incident.GATE; label = "PASTURE GATE"
			action = "ACTION · open gate for 8s"
			if id == 1 or s.solo:
				label = "GUIDE THE FLOCK"; action = "Walk below sheep · guide them north"
				var nearest := INF
				for sheep in host.animal_incident.sheep:
					if host.animal_incident.returned.has(sheep.get_instance_id()): continue
					var point: Vector2 = host.world_root.pixel_to_logical(sheep.position)
					if p.distance_to(point) < nearest: nearest = p.distance_to(point); target = point
				radius = 12
		"planning_gate":
			target = s.HAY if p.distance_to(s.HAY) < p.distance_to(host.repair_incident.BAY) else host.repair_incident.BAY
			label = "RAIN COVERS" if target == s.HAY else "MAINTENANCE"
			action = "HOLD together · £20 upgrade (3s)" if not s.solo else "HOLD · £20 upgrade (3s)"
		"repair":
			target = host.repair_incident.BAY; label = "REPAIR BAY"; radius = 5
			action = "ACTION · inspect, then pump / release"
			if id == 1:
				var repair = host.repair_incident
				if repair.delivered: action = "HOLD · fit while pressure is GREEN"
				elif not repair.carried.is_empty(): action = "ACTION · deliver part"
				else:
					# Both supplies are public; which one fits remains a phone clue.
					target = repair.BELT_CRATE if p.distance_to(repair.BELT_CRATE) < p.distance_to(repair.GASKET_CRATE) else repair.GASKET_CRATE
					label = "FEED-STORE BELT" if target == repair.BELT_CRATE else "WORKSHOP GASKET"
					action = "ACTION · collect (check mechanic's clue)"
		"weather":
			var stage: int = host.world_root.crop_field.stage
			if id == 1 and stage < 6 and stage not in [2,3,4]:
				target = Vector2(52,-38); label = "BARLEY FIELD"; action = "Drive through gold plots"
				if host.player_modes[id] != "tractor": target = host._tractor_logical(); label = "TRACTOR"; action = "ACTION · enter tractor"; radius = 11
				elif stage in [1,5] and not host.world_root.crop_field.operation_ready: action = "Phone · ENGAGE FIELD TOOL"
			else:
				target = s.INTAKE; label = "GRAIN INTAKE"; action = "HOLD · seal intake (4s)"
				if s.sealed and stage == 6 and s.stock == 0: action = "ACTION · store harvest"
				elif s.sealed and not s.covered: target = s.APIARY; label = "APPLE COVERS"; action = "HOLD · cover apples"
				elif s.sealed and not s.crates_ready: target = s.PACK; label = "PACKING CRATES"; action = "HOLD · prepare crates (4s)"
				elif s.stock == 0: action = "Waiting for harvest · help your partner"
		"planning_machine":
			target = s.PACK if id == 1 else s.DISPATCH; label = "DELIVERY BRIEFING"; action = "Read phone clue · ACTION when ready"
		"dispatch":
			if s.loaded == 2: target = s.DISPATCH; label = "DELIVERY VAN"; action = "HOLD together · load the van" if not s.solo else "HOLD · load the van"
			elif s.cargo[id] != "": target = s.PACK; label = "PACKING CANOPY"; action = "ACTION · pack carried load"
			elif id == 2 and not s.checked and not s.solo: target = s.DISPATCH; label = "BUYER CHECK"; action = "ACTION · inspect buyer"
			else:
				target = s.INTAKE if p.distance_to(s.INTAKE) < p.distance_to(s.APIARY) else s.APIARY
				label = "GRAIN STORE" if target == s.INTAKE else "APPLE STORE"
				action = "ACTION · collect (check buyer's clue)"
	var near := p.distance_to(target) < radius
	var hint := action if near else "Head to %s · %dm" % [label.to_lower(), ceili(p.distance_to(target))]
	if host.player_modes[id] == "tractor" and near and label not in ["BARLEY FIELD"]: hint = "EXIT tractor · " + action
	return {"label":label, "hint":hint, "target":target, "near":near}

func _process(_delta: float) -> void:
	if host == null or host.weekend == null: return
	visible = host.admitted_players > 0 and not host.lobby_panel.visible and host.weekend.phase not in ["waiting","results"]
	if not visible: return
	cards.clear()
	var screen := get_viewport_rect().size
	for id in ([1] if host.weekend.solo else [1,2]):
		var data := task(id)
		var width := minf(410, screen.x * .32)
		var x := 18.0 if id == 1 else screen.x - width - 18 if host.split_screen else width + 32
		data["rect"] = Rect2(Vector2(x,screen.y-78),Vector2(width,60))
		data["id"] = id
		cards.append(data)
	queue_redraw()

func _draw() -> void:
	var font := ThemeDB.fallback_font
	for data in cards:
		var rect: Rect2 = data.rect
		var colour := Color("#ef947c") if data.id == 1 else Color("#83d7df")
		var style := StyleBoxFlat.new(); style.bg_color = Color("#173329ee"); style.border_color = colour; style.set_border_width_all(1); style.set_corner_radius_all(10)
		draw_style_box(style,rect)
		draw_string(font,rect.position+Vector2(12,21),"%d · %s" % [data.id,data.label],HORIZONTAL_ALIGNMENT_LEFT,rect.size.x-24,14,colour)
		draw_string(font,rect.position+Vector2(12,44),data.hint,HORIZONTAL_ALIGNMENT_LEFT,rect.size.x-24,14,CREAM)
		if host.debug_overview or data.near: continue
		var container: SubViewportContainer = host.left_container if data.id == 1 or not host.split_screen else host.right_container
		var camera: Camera2D = host.left_camera if container == host.left_container else host.right_camera
		var local: Vector2 = camera.get_viewport().get_canvas_transform() * host._logical_to_pixel(data.target)
		var destination := local + container.position
		var view := Rect2(container.position,container.size)
		var safe := Rect2(view.position+Vector2(28,260),view.size-Vector2(56,370))
		if safe.size.y <= 0: continue
		if view.grow(-24).has_point(destination): continue
		var centre := safe.get_center()
		var direction := (destination-centre).normalized()
		var half := safe.size*.5
		var scale_to_edge := minf(half.x/maxf(.001,absf(direction.x)),half.y/maxf(.001,absf(direction.y)))
		var point := centre+direction*scale_to_edge
		draw_circle(point,15,INK)
		var side := direction.orthogonal()
		draw_colored_polygon(PackedVector2Array([point+direction*9,point-direction*6+side*6,point-direction*6-side*6]),colour)
