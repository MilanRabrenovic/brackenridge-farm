extends "res://tests/test_solo_playthrough.gd"
# Both slots travel using input packets, real physics and normal mission ticks.
# No actor placement, crop-stage assignments or direct interaction calls.
# This deterministic route is technical evidence, not human fun/pacing evidence.
var companion_hold := false
var balance_pressure := false
var route_seed := 1731

func step(direction := Vector2.ZERO, hold := false) -> void:
	await physics_frame
	for id in [1,2]:
		input_sequence+=1
		var movement:Vector2=direction if id==active_id else Vector2.ZERO
		var pressed:bool=hold if id==active_id else companion_hold
		if id==2 and balance_pressure:pressed=host.repair_incident.pressure<.60
		host._handle({"type":"input","playerId":id,"seq":input_sequence,"x":movement.x,"y":movement.y,"action":pressed})
	host._physics_process(DT)
	if not session.paused:host.world_root.crop_field._process(DT)
	simulated_seconds+=DT

func capture_view(label: String) -> void:
	if not capture_enabled:return
	host._update_camera(100);host.minimap._process(100)
	await process_frame;await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/audits/2026-10-05-coop-route/%s.png" % label)

func verify() -> void:
	capture_enabled="--capture" in OS.get_cmdline_user_args()
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):route_seed=arg.trim_prefix("--seed=").to_int()
	DirAccess.make_dir_recursive_absolute("res://../docs/audits/2026-10-05-coop-route")
	root.size=Vector2i(1280,720)
	Engine.max_fps=0;Engine.physics_ticks_per_second=600;Engine.time_scale=10
	host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame;await physics_frame
	host.set_process(false);host.set_physics_process(false);host.world_root.crop_field.set_process(false)
	session=host.weekend
	if session==null:quit(1);return
	host.admitted_players=2;host.lobby_panel.hide();host.lobby_backdrop.hide()
	session.sound_enabled=false;session.start(2,route_seed)
	check(not session.solo,"Co-op silently enabled assistance")
	make_grid(8)
	# Position the gate keeper through actual travel during the tutorial.
	active_id=2;await travel(host.animal_incident.GATE)
	active_id=1;await travel(session.HAY);await action();await hold_for(8.2)
	check(session.phase=="sheep","Arrival did not advance")
	companion_hold=true
	await travel(Vector2(-42,12))
	for tick in range(10000):
		if session.phase!="sheep":break
		var target:Node2D=null;var southernmost:float=-999
		for sheep in host.animal_incident.sheep:
			var pos:Vector2=host.world_root.pixel_to_logical(sheep.position)
			if pos.y>southernmost and pos.y>-18:target=sheep;southernmost=pos.y
		if target==null:await step();continue
		var behind:Vector2=host.world_root.pixel_to_logical(target.position)+Vector2(0,5.5)
		await step((behind-host.logical_positions[1]).limit_length(1.0))
	check(session.phase=="planning_gate" and session.outcomes.get("sheep",0)==5,"Co-op physical herding failed")
	companion_hold=false
	if errors>0:quit(1);return
	# Let the normal clock choose saving, rather than skip the planning phase.
	await hold_for(28.3)
	check(session.phase=="repair","Planning clock did not reach repair")
	active_id=2;await travel(host.repair_incident.BAY);await action()
	check(host.repair_incident.diagnosis,"Mechanic's input did not inspect fault")
	check(host.repair_incident.required_part in host.mission_facts[2],"Private diagnosis missing")
	check(not "DIAGNOSIS:" in host.mission_facts[1],"Runner received private diagnosis")
	balance_pressure=true
	active_id=1
	await travel(host.repair_incident.GASKET_CRATE if host.repair_incident.required_part=="gasket" else host.repair_incident.BELT_CRATE)
	await action();await travel(host.repair_incident.BAY);await action()
	await capture_view("repair");await hold_for(9.3)
	check(session.phase=="weather" and session.outcomes.repair,"Co-op physical repair failed")
	balance_pressure=false;companion_hold=false
	if errors>0:quit(1);return
	# The storage farmer uses their real motor while the grower remains at bay.
	active_id=2;await travel(session.INTAKE);await hold_for(4.2)
	await travel(session.APIARY);await hold_for(6.2)
	await travel(session.PACK);await hold_for(4.2)
	check(session.sealed and session.covered and session.crates_ready,"Storage farmer jobs failed")
	var storage_fact:String=host.mission_facts[2]
	active_id=1;await travel(host._tractor_logical()+Vector2(4,0));await action()
	check(host.tractor_driver==1,"Input did not enter tractor")
	make_grid(22)
	var stages:Dictionary={0:true}
	host.world_root.crop_field.stage_changed.connect(func(_label):stages[int(host.world_root.crop_field.stage)]=true)
	for operation in range(2):
		if operation==1:host._handle({"type":"command","playerId":1,"command":"tool"})
		for y in [-26,-34,-42,-50]:await travel(Vector2(31,y));await travel(Vector2(73,y))
	for tick in range(2400):
		if host.world_root.crop_field.stage>=5:break
		await step()
	host._handle({"type":"command","playerId":1,"command":"tool"})
	for y in [-50,-42,-34,-26]:await travel(Vector2(73,y));await travel(Vector2(31,y))
	await capture_view("harvest")
	for stage in range(7):check(stages.has(stage),"Missing natural crop stage %d" % stage)
	check(host.mission_facts[2]==storage_fact,"Driver updates overwrote partner's private fact")
	await travel(session.INTAKE+Vector2(4,0));await action();make_grid(8)
	await travel(session.INTAKE);await action();await hold_for(3.2)
	check(session.phase=="planning_machine" and session.outcomes.weather,"Co-op weather failed")
	check(host.player_modes[1]=="foot","Result-beat hold accidentally boarded parked tractor")
	if errors>0:quit(1);return
	# Both ready through normal context inputs; buyer inspected by player two.
	await travel(session.PACK);await action()
	active_id=2;await action()
	check(session.phase=="dispatch","Two inputs did not finish delivery briefing")
	if errors>0:quit(1);return
	await travel(session.DISPATCH);await action()
	check(session.checked,"Buyer was not inspected")
	var store:Vector2=session.INTAKE if session.required_goods=="barley" else session.APIARY
	for id in [1,2]:
		active_id=id;await travel(store);await action();await travel(session.PACK);await action()
	check(session.loaded==2,"Two farmers did not pack both loads")
	active_id=1;await travel(session.DISPATCH)
	active_id=2;await travel(session.DISPATCH)
	await hold_for(1)
	check(session.load_progress==0,"Single held input bypassed cooperative loading")
	companion_hold=true;await hold_for(4.2)
	check(session.phase=="results" and session.outcomes.dispatch,"Joint input did not complete dispatch")
	await capture_view("results")
	check(not session.solo,"Co-op route used solo assistance")
	companion_hold=false;session.restart(1732)
	check(session.phase=="arrival" and not session.solo and host.tractor_driver==0,"Co-op replay failed")
	if errors==0:print("Co-op input/physics route seed %d completed all four outcomes and replay; %.1fs simulated input time, no actor/crop teleports or helper assistance" % [route_seed,simulated_seconds])
	quit(1 if errors else 0)
