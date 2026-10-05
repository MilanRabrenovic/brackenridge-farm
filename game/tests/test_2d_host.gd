extends SceneTree
var failures := 0

func _init() -> void:
	var scene := load("res://main.tscn") as PackedScene
	if scene == null: _fail("Main scene did not load")
	var host := scene.instantiate()
	root.add_child(host)
	await process_frame
	await process_frame
	var lobby := host.get("lobby_panel") as PanelContainer
	if lobby == null or not lobby.visible: _fail("Joining screen did not start visible")
	host.call("_handle", {"type":"roster", "players":[{"id":1, "connected":true, "admission":"admitted"}]})
	if lobby.visible: _fail("Joining screen did not hide after the first admitted phone")
	if host.weekend.phase != "arrival": _fail("First phone did not start weekend")
	host.animal_incident.time_left = 70.0
	host.call("_handle", {"type":"roster", "players":[{"id":1,"connected":true,"admission":"admitted"},{"id":2,"connected":true,"admission":"admitted"}]})
	if host.animal_incident.time_left != 70.0: _fail("Second phone restarted active event")
	var world := host.get_node_or_null("BrackenridgeFarm2D") as Node2D
	if world == null: _fail("2D farm world was not created")
	var crop := world.get_node_or_null("BarleyField")
	if crop == null: _fail("Layered barley field is missing")
	if str(crop.call("current_stage_name")) != "UNPREPARED": _fail("Barley field did not start as unprepared land")
	for z in [-50.0, -42.0, -34.0, -26.0]:
		for x in [31.0, 45.0, 59.0, 73.0]: crop.call("apply_tractor_work", host.call("_logical_to_pixel", Vector2(x, z)))
	if str(crop.call("current_stage_name")) != "PREPARED": _fail("Tractor passes did not prepare unworked land")
	crop.call("engage_operation")
	for z in [-50.0, -42.0, -34.0, -26.0]:
		for x in [31.0, 45.0, 59.0, 73.0]: crop.call("apply_tractor_work", host.call("_logical_to_pixel", Vector2(x, z)))
	if str(crop.call("current_stage_name")) != "SEEDED": _fail("Second tractor operation did not seed prepared land")
	crop.call("_process", 11.0)
	if str(crop.call("current_stage_name")) != "SEEDLINGS": _fail("Seeded crop did not grow into seedlings")
	crop.call("_process", 13.0)
	if str(crop.call("current_stage_name")) != "YOUNG CROP": _fail("Seedlings did not grow into young crop")
	crop.call("_process", 16.0)
	if str(crop.call("current_stage_name")) != "MATURE": _fail("Young crop did not reach maturity")
	crop.call("engage_operation")
	for z in [-50.0, -42.0, -34.0, -26.0]:
		for x in [31.0, 45.0, 59.0, 73.0]: crop.call("apply_tractor_work", host.call("_logical_to_pixel", Vector2(x, z)))
	if str(crop.call("current_stage_name")) != "HARVESTED": _fail("Mature crop was not converted to harvested stubble")
	crop.call("cycle_stage")
	if str(crop.call("current_stage_name")) != "DAMAGED": _fail("Damaged field presentation is missing")
	for id in [1, 2]:
		var player := world.get_node_or_null("Player%d" % id) as CharacterBody2D
		if player == null: _fail("Player %d 2D body is missing" % id)
		var sprite := player.get_node_or_null("WalkSprite") as AnimatedSprite2D
		if sprite == null: _fail("Player %d animated walk sprite is missing" % id)
		for animation_name in ["walk_down", "walk_left", "walk_right", "walk_up"]:
			if not sprite.sprite_frames.has_animation(animation_name): _fail("Player %d is missing %s" % [id, animation_name])
			if sprite.sprite_frames.get_frame_count(animation_name) != 4: _fail("Player %d %s does not have four frames" % [id, animation_name])
		if player.get_child_count() < 3: _fail("Player %d collision or identity layer is missing" % id)
		if sprite.scale.x > 0.15: _fail("Player %d remains oversized for the ten-pixels-per-metre world" % id)
	var tractor := world.get_node_or_null("IllustratedTractor") as CharacterBody2D
	if tractor == null or tractor.get_child_count() == 0: _fail("Illustrated tractor is missing")
	var tractor_art := tractor.get_child(1) as Sprite2D
	if tractor_art == null or tractor_art.scale.x > 0.32: _fail("Tractor scale is inconsistent with the world standard")
	for route_name in ["field_laneSurface", "field_headlandSurface", "dispatch_laneSurface"]:
		if world.get_node_or_null(route_name) == null: _fail("Connected route %s is missing" % route_name)
	for boundary_name in ["CropWest00", "CropSouthEast00", "PastureEast00", "MeadowSouth00"]:
		if world.get_node_or_null(boundary_name) == null: _fail("Snapped boundary %s is missing" % boundary_name)
	for building_name in ["StoneBarn", "MachineryShed", "RepairWorkshop", "FeedStore"]:
		var building := world.get_node_or_null(building_name) as Node2D
		if building == null: _fail("Enterable building %s is missing" % building_name)
		if building.get_node_or_null("ForegroundArt") == null or building.get_node_or_null("InteriorReveal") == null: _fail("%s foreground or interior reveal is missing" % building_name)
		if _count_static_bodies(building) < 5: _fail("%s does not have back, side and doorway collision pieces" % building_name)
	if world.get_node_or_null("Tree0") == null: _fail("Y-sorted production trees are missing")
	if world.get_node_or_null("StoneBridge") == null or world.get_node_or_null("ShallowFord") == null: _fail("Passable stream crossings are missing")
	for prop_name in ["PastureSheep00", "OrchardApiary", "SiloGrainIntake", "ParkedFarmTrailer", "DeliveryVan", "PackingProducePallet", "WorkshopSpareParts"]:
		if world.get_node_or_null(prop_name) == null: _fail("Operational map prop %s is missing" % prop_name)
	var expected_destinations := PackedStringArray(["animal_care", "repair_bay", "grain_intake", "crop_gate", "pasture_gate", "apiary", "packing", "dispatch", "bridge", "ford"])
	var actual_destinations: PackedStringArray = world.call("destination_ids")
	for destination_id in expected_destinations:
		if not actual_destinations.has(destination_id): _fail("Interaction destination %s is missing" % destination_id)
	var crop_destination: Dictionary = world.call("nearest_destination", host.call("_logical_to_pixel", Vector2(33,-11)), 8.0)
	if str(crop_destination.get("id", "")) != "crop_gate": _fail("Crop gate interaction destination is not queryable")
	var player_one := world.get_node("Player1") as CharacterBody2D
	player_one.position = host.call("_logical_to_pixel", Vector2(61,25))
	host.set("logical_positions", {1:Vector2(61,25), 2:Vector2(10,9)})
	host.call("_try_context_action", 1)
	var status := host.get("status_label") as Label
	if not status.text.begins_with("ORCHARD APIARY:"): _fail("Destination action did not expose its gameplay purpose")
	var incident := host.get_node_or_null("AnimalIncident2D") as AnimalIncident2D
	if incident == null: _fail("Animal incident controller is missing")
	incident.start_incident()
	if not incident.active(): _fail("Animal incident did not enter its active state")
	var incident_panel := incident.get("incident_panel") as PanelContainer
	if incident_panel == null or not incident_panel.visible: _fail("Animal incident objective HUD is missing")
	var incident_inputs := {
		1:{"x":0.0,"y":0.0,"action":false},
		2:{"x":0.0,"y":0.0,"action":true}
	}
	incident.update_incident(0.1,{1:Vector2(-60,8),2:Vector2(-42,-9)},incident_inputs)
	if int(incident.get("gate_holder")) != 2: _fail("Held phone action did not keep the pasture gate open")
	incident.restart_incident()
	for simulation_step in range(1000):
		var target_sheep: Node2D = null
		var southernmost_y := -999.0
		for sheep_index in range(5):
			var candidate := world.get_node("PastureSheep%02d" % sheep_index) as Node2D
			var candidate_position: Vector2 = world.call("pixel_to_logical",candidate.position)
			if candidate_position.y > southernmost_y and candidate_position.y > -18.0:
				target_sheep = candidate; southernmost_y = candidate_position.y
		if target_sheep == null or incident.result() != "active": break
		var sheep_position: Vector2 = world.call("pixel_to_logical",target_sheep.position)
		incident.update_incident(0.1,{1:sheep_position + Vector2(0,5.5),2:Vector2(-42,-9)},incident_inputs)
	if incident.result() != "success" or incident.returned_count() != 5: _fail("The guide-and-gate route is not solvable inside its timer")
	var first_sprite := world.get_node("Player1/WalkSprite") as AnimatedSprite2D
	host.call("_move_player", 1, Vector2.RIGHT, 0.2)
	if first_sprite.animation != "walk_right" or not first_sprite.is_playing(): _fail("Directional walk animation did not start")
	if host.get("left_camera") == null or host.get("right_camera") == null: _fail("Shared/split 2D cameras were not created")
	host.set("logical_positions", {1: Vector2(-46, 31), 2: Vector2(48, -30)})
	host.call("_update_camera", 1.0)
	if not bool(host.get("split_screen")): _fail("Separated players did not activate the split-screen composition")
	if failures==0: print("2D host visual test passed: lobby, production map, crop states, destinations, complete animal incident, collision, occlusion, animated players, tractor and adaptive cameras verified")
	host.queue_free()
	quit(1 if failures else 0)

func _fail(message: String) -> void:
	push_error(message)
	failures+=1

func _count_static_bodies(parent: Node) -> int:
	var count := 0
	for child in parent.get_children():
		if child is StaticBody2D: count += 1
	return count
