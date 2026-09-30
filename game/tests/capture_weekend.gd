extends SceneTree
func _init() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,720)
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame;host.set_process(false);host.set_physics_process(false);host.admitted_players=2;host.lobby_panel.hide();host.lobby_backdrop.hide()
	var s=host.weekend;s.sound_enabled=false;s.start(2)
	var positions={1:Vector2(3,3),2:Vector2(8,7)}
	var packets={1:{"action":false},2:{"action":false}}
	for view in ["arrival","weather","dispatch","results"]:
		if view=="weather":s._enter("weather",210);s.remaining=20;positions={1:Vector2(46,-30),2:s.APIARY};host.world_root.crop_field.set_stage(5)
		if view=="dispatch":s.stock=2;s._enter("dispatch",210);s.handle_action(1,s.INTAKE);positions={1:s.PACK+Vector2(-3,0),2:s.DISPATCH}
		if view=="results":s.outcomes={"sheep":5,"repair":true,"weather":true,"dispatch":true};s.stock=2;s._enter("results",0)
		for id in [1,2]:host.logical_positions[id]=positions[id];host.players[id].position=host._logical_to_pixel(positions[id])
		host._update_camera(100);s.update(.016,positions,packets)
		await physics_frame;await process_frame;await process_frame;await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://../docs/audits/2026-09-30-release/%s.png" % view)
	quit()
