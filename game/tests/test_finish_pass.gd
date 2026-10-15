extends SceneTree
var errors := 0
func _init() -> void: call_deferred("verify")
func check(ok: bool, text: String) -> void:
	if not ok: errors += 1; push_error(text)
func verify() -> void:
	root.size = Vector2i(1280,720)
	var host = load("res://main.tscn").instantiate()
	root.add_child(host); await process_frame
	if host.weekend == null or host.guidance == null: quit(1); return
	host.set_process(false); host.set_physics_process(false)
	host._handle({"type":"roster","players":[{"id":1,"admission":"pending","connected":true}]})
	check("Enter/Select" in host.roster_label.text,"Pending phone lacks host admission instruction")
	host.admitted_players=2;host._set_lobby_visible(false)
	var s = host.weekend
	s.sound_enabled=false;s.start(2)
	var hud = host.guidance
	s.command(1,"replay");check(s.phase=="arrival","Replay bypassed the active weekend")
	s._enter("repair",180)
	var first: Dictionary = hud.task(1)
	host.repair_incident.required_part="gasket" if host.repair_incident.required_part=="belt" else "belt"
	check(first==hud.task(1),"Public guidance disclosed the private diagnosis")
	host.repair_incident.carried="belt"
	check(hud.task(1).target==host.repair_incident.BAY,"Carried part did not route to repair")
	s.stock=2;s._enter("dispatch",210)
	s.required_goods="barley";first=hud.task(1);s.required_goods="apples"
	check(first==hud.task(1),"Public guidance disclosed buyer preference")
	s.cargo[1]="apples";check(hud.task(1).target==s.PACK,"Carrying did not route to packing")
	s.loaded=2;check(hud.task(1).target==s.DISPATCH,"Packed loads did not route to van")
	for split in [false,true]:
		host.split_screen=split;host._apply_view_layout();hud._process(.1)
		for card in hud.cards:
			check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(card.rect),"Guidance clipped outside viewport")
		check(not hud.cards[0].rect.intersects(hud.cards[1].rect),"Farmer cards overlap")
		var old_target:Vector2=host.logical_positions[1]
		s.outcomes={"sheep":5,"repair":true,"weather":true,"dispatch":true}
		s._enter("results",0);hud._process(.1)
		check(not hud.visible,"Guidance obscures results")
		check(not host.player_sprites[1].is_playing(),"Walk animation continues behind results")
		host.inputs[1]={"seq":1,"seen":Time.get_ticks_msec(),"x":1,"y":0,"action":false}
		host._physics_process(.1);check(host.logical_positions[1]==old_target,"Farmer moved behind results")
		s.command(1,"replay");check(s.phase=="results" and s.replay_votes.size()==1,"One farmer forced co-op replay")
		s.command(1,"replay");check(s.replay_votes.is_empty(),"Replay vote could not be cancelled")
		s.command(1,"replay");host._handle({"type":"reset_input","playerId":1})
		check(s.replay_votes.is_empty(),"Disconnected farmer retained replay consent")
		s.command(1,"replay");host.admitted_players=1;s.command(2,"replay")
		check(s.phase=="results","Replay bypassed missing farmer")
		s.command(2,"replay");host.admitted_players=2
		var before: int=s.seed_value
		s.command(2,"replay")
		check(s.phase=="arrival" and s.seed_value==before+1,"Joint replay did not start next seed")
		check(s.replay_votes.is_empty(),"Replay votes leaked into next weekend")
	s.solo=true;host.admitted_players=1;s._enter("results",0)
	s.command(1,"replay");check(s.phase=="arrival" and s.solo,"Solo phone replay failed")
	if "--capture" in OS.get_cmdline_user_args():
		var folder="res://../docs/audits/2026-10-15-finish"
		DirAccess.make_dir_recursive_absolute(folder)
		host.admitted_players=2;s.solo=false;host.players[2].show()
		for name in ["shared","split","results"]:
			s._enter("weather",210)
			host.logical_positions={1:Vector2(32,-25),2:s.APIARY} if name=="split" else {1:Vector2(0,7),2:Vector2(8,9)}
			for id in [1,2]:host.players[id].position=host._logical_to_pixel(host.logical_positions[id])
			host._update_camera(100);s.update(.016,host.logical_positions,{1:{"action":false},2:{"action":false}})
			if name=="results":s._enter("results",0)
			hud._process(100);host.minimap._process(100)
			await process_frame;await process_frame;await RenderingServer.frame_post_draw
			if name=="results":check(Rect2(Vector2.ZERO,root.get_visible_rect().size).encloses(s.results_panel.get_global_rect()),"Results panel clipped")
			root.get_texture().get_image().save_png(folder+"/"+name+".png")
	print("Finish pass: private-fact boundaries, contextual routing, shared/split bounds, results freeze, replay voting/cancellation/missing-player/solo")
	quit(1 if errors else 0)
