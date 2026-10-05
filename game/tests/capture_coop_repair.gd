extends SceneTree
func _init()->void:call_deferred("capture")
func capture()->void:
	root.size=Vector2i(1280,720)
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false);host.admitted_players=2
	host.lobby_panel.hide();host.lobby_backdrop.hide()
	if host.weekend==null:quit(1);return
	host.weekend.sound_enabled=false;host.weekend.start(2,1731);host.weekend._enter("repair",180)
	var r=host.repair_incident
	r.handle_action(2,r.BAY);r.handle_action(1,r.BELT_CRATE);r.handle_action(1,r.BAY)
	for id in [1,2]:host.logical_positions[id]=r.BAY+Vector2(-2 if id==1 else 2,1);host.players[id].position=host._logical_to_pixel(host.logical_positions[id])
	host._update_camera(100)
	var folder="res://../docs/audits/2026-09-30-repair-play"
	DirAccess.make_dir_recursive_absolute(folder)
	for band in ["low","green","hot"]:
		r.pressure=.2 if band=="low" else .57 if band=="green" else .92
		r.progress=2;r._refresh()
		await process_frame;await process_frame;await RenderingServer.frame_post_draw
		if root.get_texture().get_image().save_png(folder+"/"+band+".png")!=OK:quit(1);return
		if host.animal_incident.incident_panel.get_global_rect().end.x>root.size.x:quit(1);return
	var f=FileAccess.open(folder+"/private-cards.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"facts":host.mission_facts,"hints":host.latest_clues},"\t"))
	print("Captured co-op low/green/hot gauge and preserved private cards; not a human playthrough")
	quit()
