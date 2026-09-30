extends SceneTree
var errors := 0
func _init() -> void: call_deferred("verify")
func check(condition: bool, message: String) -> void:
	if not condition: errors+=1;push_error(message)
func verify() -> void:
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame;host.set_physics_process(false);host.set_process(false)
	var s=host.weekend
	if s==null:check(false,"Host/session failed to compile or initialize");quit(1);return
	s.sound_enabled=false
	var positions={1:Vector2.ZERO,2:Vector2.ZERO}
	var inputs={1:{"action":false},2:{"action":false}}
	host.admitted_players=2
	for run in range(3):
		s.restart(1731+run);check(s.phase=="arrival" and not s.solo,"Coop arrival")
		s.update(76,positions,inputs);check(s.phase=="sheep","Arrival transition")
		# Same deterministic herding solution used by the collision/animal suite.
		inputs[2].action=true
		for step in range(1000):
			if s.phase!="sheep": break
			var target:Node2D=null;var southernmost:float=-999
			for sheep in host.animal_incident.sheep:
				var pos:Vector2=host.world_root.pixel_to_logical(sheep.position)
				if pos.y>southernmost and pos.y>-18: target=sheep;southernmost=pos.y
			if target==null: break
			positions={1:host.world_root.pixel_to_logical(target.position)+Vector2(0,5.5),2:host.animal_incident.GATE}
			s.update(.1,positions,inputs)
		check(s.phase=="planning_gate" and s.outcomes.sheep==5,"Sheep success reaches planning")
		s.update(26,positions,inputs);check(s.phase=="repair","Planning transition")
		s.handle_action(2,host.repair_incident.BAY) # contextual repair routes are handled by the repair controller
		host.repair_incident.handle_action(2,host.repair_incident.BAY)
		host.repair_incident.handle_action(1,host.repair_incident.GASKET_CRATE if host.repair_incident.required_part=="gasket" else host.repair_incident.BELT_CRATE)
		host.repair_incident.handle_action(1,host.repair_incident.BAY)
		positions={1:host.repair_incident.BAY,2:host.repair_incident.BAY};inputs[1].action=true
		s.update(6.1,positions,inputs);check(s.phase=="weather" and s.outcomes.repair,"Repair transition")
		# Work the actual crop through preparation, sowing, timed growth and harvest.
		var crop=host.world_root.crop_field
		var storage_clue:String=host.latest_clues[2]
		s.update(.016,positions,inputs)
		check(host.latest_clues[2]==storage_clue,"Crop guidance exposed or replaced the partner storage clue")
		for pass_index in range(2):
			for y in [-50,-42,-34,-26]:
				for x in [31,45,59,73]: crop.apply_tractor_work(host._logical_to_pixel(Vector2(x,y)))
		crop._process(11);crop._process(13);crop._process(16)
		for y in [-50,-42,-34,-26]:
			for x in [31,45,59,73]:crop.apply_tractor_work(host._logical_to_pixel(Vector2(x,y)))
		check(crop.stage==6,"Mission harvest lifecycle")
		s.handle_action(1,s.INTAKE);positions[2]=s.APIARY
		s.update(6.1,positions,inputs);check(s.phase=="planning_machine" and s.stock==2,"Weather success")
		s.update(26,positions,inputs);check(s.phase=="dispatch","Dispatch transition")
		var wrong=s.APIARY if s.required_goods=="barley" else s.INTAKE
		s.handle_action(1,wrong);s.handle_action(1,s.PACK);check(s.loaded==0,"Wrong order accepted")
		var correct=s.INTAKE if s.required_goods=="barley" else s.APIARY
		for i in range(2):s.handle_action(1,correct);s.handle_action(1,s.PACK)
		s.handle_action(2,s.DISPATCH);positions={1:s.DISPATCH,2:s.DISPATCH}
		inputs[2].action=false;s.update(2,positions,inputs);check(s.load_progress==0,"One farmer loaded alone")
		inputs[2].action=true;s.update(6.1,positions,inputs)
		check(s.phase=="results" and s.outcomes.dispatch and s.results_panel.visible,"Complete weekend ending")
	# All failures lead forward, with a viable reserve load.
	s.restart(43)
	for i in range(20):
		inputs={1:{"action":false},2:{"action":false}}
		s.update(500,positions,inputs)
		if s.phase=="results":break
	check(s.phase=="results" and not s.outcomes.dispatch,"Failure recovery ending")
	host.admitted_players=1;s.restart(11)
	check(s.solo,"Solo label missing")
	s.update(76,positions,inputs);s.update(171,positions,inputs);s.update(26,positions,inputs)
	check(s.phase=="repair","Solo reaches assisted repair")
	host.repair_incident.handle_action(1,host.repair_incident.GASKET_CRATE if host.repair_incident.required_part=="gasket" else host.repair_incident.BELT_CRATE);s.update(.1,positions,inputs)
	host.repair_incident.handle_action(1,host.repair_incident.BAY);positions[1]=host.repair_incident.BAY;inputs[1].action=true;s.update(6.1,positions,inputs)
	check(s.phase=="weather","Solo repair solvable")
	check(host.world_root.crop_field.stage==0 and not s.covered,"Solo bypassed preparation or apple covering")
	check(s.remaining==210,"Solo lacks full harvest time")
	host.player_modes[1]="tractor";s.clues("test","")
	check(host.latest_modes[1].title=="TRACTOR" and host.latest_modes[1].actionLabel=="EXIT","Phase changed tractor dashboard to walking")
	host.player_modes[1]="foot"
	# Pausing freezes the mission clock, and cannot bypass a disconnect pause.
	var before=s.remaining;s.command(1,"pause");s.update(12,positions,inputs)
	check(s.remaining==before and s.paused,"Pause advanced the clock")
	s.command(1,"pause");host.disconnected_pause=true;s.paused=true;s.command(1,"pause")
	check(s.paused,"Phone bypassed missing-farmer pause");host.disconnected_pause=false
	# Dropping conserves stock; replay restores walker collision after driving.
	s.paused=false;s.stock=2;s._enter("dispatch",100);s.required_goods="barley"
	s.handle_action(1,s.INTAKE);check(s.inventory.barley==1,"Collect duplicated stock")
	s.command(1,"drop");check(s.inventory.barley==2 and s.cargo[1]=="","Drop lost stock")
	host.players[1].collision_layer=0;host.player_modes[1]="tractor";host.tractor_driver=1
	s.restart(77);check(host.players[1].collision_layer==2 and host.tractor_driver==0 and host.player_modes[1]=="foot","Replay kept tractor state")
	# A tap down/up in one network poll must survive until the simulation tick.
	host._handle({"type":"input","playerId":1,"seq":991,"x":0,"y":0,"action":true})
	host._handle({"type":"input","playerId":1,"seq":992,"x":0,"y":0,"action":false})
	check(host.pending_actions[1],"Quick tap was discarded")
	# Both seeded faults must be feasible and diagnosis must stay private.
	for fault_variant in [0,2]:
		s.variant=fault_variant;s.solo=false;s._enter("repair",210)
		var repair=host.repair_incident
		check(repair.required_part==("gasket" if fault_variant==2 else "belt"),"Wrong seeded repair fault")
		check(repair.required_part.to_upper() in host.latest_clues[2],"Mechanic has no fault diagnosis")
		check("DIAGNOSIS" not in host.latest_clues[1],"Runner received mechanic diagnosis")
		repair.handle_action(2,repair.BAY)
		repair.handle_action(1,repair.BELT_CRATE if repair.required_part=="gasket" else repair.GASKET_CRATE)
		repair.handle_action(1,repair.BAY);check(not repair.delivered,"Wrong seeded part accepted")
		repair.handle_action(1,repair.GASKET_CRATE if repair.required_part=="gasket" else repair.BELT_CRATE)
		repair.handle_action(1,repair.BAY);check(repair.delivered,"Correct seeded part rejected")
	# Replay variants are stable and every seed has a feasible order.
	for seed_index in range(1000):
		s.phase="waiting";s.start(2,seed_index);var first=s.variant
		s.phase="waiting";s.start(2,seed_index);check(first==s.variant and s.variant>=0 and s.variant<=2,"Seed mismatch")
	print("Weekend: three complete success routes, wrong goods, shared loading, failures, solo repair and 1000 stable seeded variants checked")
	quit(1 if errors else 0)
