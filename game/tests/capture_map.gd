extends SceneTree

func _init() -> void:
	call_deferred("capture")

func capture() -> void:
	root.size = Vector2i(1280,720)
	var host = load("res://main.tscn").instantiate()
	root.add_child(host)
	await process_frame
	host.set_process(false)
	host.set_physics_process(false)
	host.lobby_panel.hide()
	host.lobby_backdrop.hide()
	var prefix := "before"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0: prefix = args[0]
	var views := [["yard",Vector2(0,2)],["pasture",Vector2(-48,-17)],["orchard",Vector2(53,20)],["dispatch",Vector2(29,43)],["overview",Vector2.ZERO],["mature-field",Vector2(50,-27)],["overview-mature",Vector2.ZERO],["split",Vector2(-62,40)],["interior",Vector2(-8,-12)],["repair",Vector2(-8,5)]]
	for view in views:
		host.debug_overview = view[0] in ["overview","overview-mature"]
		host.logical_positions = {1:view[1],2:view[1]+Vector2(5,3)}
		if view[0] == "mature-field": host.world_root.crop_field.set_stage(5)
		if view[0] == "split": host.logical_positions[2] = Vector2(64,25)
		if view[0] == "repair": host.repair_incident.start_incident()
		for id in [1,2]:
			host.players[id].position = host._logical_to_pixel(host.logical_positions[id])
			host.players[id].visible = true
		host._update_camera(100.0)
		await physics_frame
		await physics_frame
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/audits/2026-09-28-cohesive/%s-%s.png" % [prefix,view[0]])
	quit()
