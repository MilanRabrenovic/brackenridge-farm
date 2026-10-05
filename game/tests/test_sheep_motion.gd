extends SceneTree
var errors:=0
func _init() -> void:call_deferred("verify")
func check(ok:bool,text:String)->void:
	if not ok:errors+=1;push_error(text)
func verify()->void:
	root.size=Vector2i(1280,720)
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false);host.admitted_players=2
	if host.weekend==null:quit(1);return
	host.lobby_panel.hide();host.lobby_backdrop.hide();host.weekend.sound_enabled=false
	host.weekend.start(2,1731);host.weekend._enter("sheep",150)
	var a=host.animal_incident
	var pos={1:Vector2(-60,-4),2:Vector2(-46,-4)}
	for id in pos:host.logical_positions[id]=pos[id];host.players[id].position=host._logical_to_pixel(pos[id])
	host._update_camera(100)
	var initial:Vector2=a.sheep[0].position
	a.update_incident(.4,{},{});check(a.sheep[0].position!=initial,"Escape has no motion")
	var sprite=a.sheep[0].get_child(1) as Sprite2D
	check(sprite.position.y < -15,"Jump does not leave the ground")
	check(sprite.material!=null and sprite.material.get_shader_parameter("stride")==1.0,"Leg gait not active")
	var folder="res://../docs/audits/2026-09-30-sheep"
	DirAccess.make_dir_recursive_absolute(folder)
	if "--capture" in OS.get_cmdline_user_args():
		for index in range(4):
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(folder+"/motion-%d.png" % index)
			a.update_incident(.16,{},{} )
	a.update_incident(4,{},{});check(a.escape_seconds==0,"Breakout repeats indefinitely")
	for actor in a.sheep:check(host.world_root.pixel_to_logical(actor.position).y>-9,"Breakout did not cross the boundary")
	var first:Vector2=a.sheep[0].position
	var clock:float=a.animation_clock
	a.update_incident(.3,{1:host.world_root.pixel_to_logical(first)+Vector2(0,3)}, {1:{"x":0,"y":-1}})
	check(a.animation_clock>clock and a.sheep[0].position!=first,"Flock does not flee a farmer")
	var key=a.sheep[0].get_instance_id();a.returned[key]=true
	for n in range(120):a.update_incident(.016,{},{} )
	check(a.returned.has(key),"Safe sheep lost progress without warning")
	a.start_incident();check(a.returned.is_empty() and a.escape_seconds==4,"Replay failed to reset escape")
	check(sprite.modulate==Color.WHITE,"Replay retained success tint")
	print("Sheep motion: staggered breakout, grounded jump, gait activation, flee, secured progress and replay")
	quit(1 if errors else 0)
