extends SceneTree
var errors:=0
func _init()->void:call_deferred("verify")
func check(ok:bool,text:String)->void:
	if not ok:errors+=1;push_error(text)
func verify()->void:
	root.size=Vector2i(1280,720)
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false)
	if host.weekend==null or host.minimap==null:quit(1);return
	host.minimap.set_process(false);host.weekend.sound_enabled=false
	host.minimap._process(.1);check(not host.minimap.visible,"Minimap obscures QR lobby")
	host.admitted_players=2;host.lobby_panel.hide();host.lobby_backdrop.hide();host.weekend.start(2)
	var folder="res://../docs/audits/2026-09-30-minimap"
	DirAccess.make_dir_recursive_absolute(folder)
	for mode in ["shared","split","merged"]:
		host.logical_positions={1:Vector2(-52,10),2:Vector2(60,-30)} if mode=="split" else {1:Vector2(-2,7),2:Vector2(5,9)}
		for id in [1,2]:host.players[id].position=host._logical_to_pixel(host.logical_positions[id])
		host.weekend._enter("weather",210);host.weekend._update_weather_guidance()
		host._update_camera(100);host.minimap._process(100)
		var m=host.minimap
		check(m.visible,"Minimap missing during play")
		check(m.get_rect().end.x<=1280 and m.get_rect().end.y<=720,"Minimap outside viewport")
		if mode=="split":check(absf(m.position.x+m.size.x*.5-640)<1,"Split minimap not centered on divider")
		else:check(m.position.x>1000,"Shared minimap not in right corner")
		if "--capture" in OS.get_cmdline_user_args():
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(folder+"/"+mode+".png")
	# Orders are private; changing the buyer's goods must not change targets.
	host.weekend._enter("dispatch",210);host.weekend.required_goods="barley"
	var targets=host.minimap.public_targets()
	host.weekend.required_goods="apples"
	check(targets==host.minimap.public_targets(),"Minimap reveals private buyer preference")
	host.weekend.loaded=2
	check(host.minimap.public_targets()==[host.weekend.DISPATCH],"Packed order did not target van")
	host.weekend.start(1);host._update_camera(100);host.minimap._process(100)
	check(not host.split_screen,"Solo minimap forced split view")
	root.size=Vector2i(640,360);await process_frame;host.minimap._process(100)
	var logical_screen:Vector2=root.get_visible_rect().size
	check(host.minimap.get_rect().end.x<=logical_screen.x and host.minimap.get_rect().end.y<=logical_screen.y,"Small viewport minimap clipped")
	host.weekend._enter("results",0);host.minimap._process(.1)
	check(not host.minimap.visible,"Minimap covers results")
	print("Minimap: shared/split/merge placement, small viewport, solo, privacy, van target and lobby/results visibility")
	quit(1 if errors else 0)
