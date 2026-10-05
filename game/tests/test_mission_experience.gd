extends SceneTree
var errors:=0
func _init() -> void:call_deferred("verify")
func check(ok: bool, message: String) -> void:
	if not ok:errors+=1;push_error(message)
func verify() -> void:
	var host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false);host.admitted_players=2
	var s=host.weekend
	if s==null:quit(1);return
	s.sound_enabled=false;s.start(2)
	var pos={1:s.HAY,2:s.HAY};var inputs={1:{"action":true},2:{"action":true}}
	s.handle_action(1,s.HAY);s.update(.1,pos,inputs)
	check("HAY CHECKED" in host.animal_incident.progress_label.text,"Hay has no acknowledgement")
	s._enter("planning_gate",25);s.update(.2,pos,inputs)
	check(s.money==100 and s.planning_progress<3,"A short tap bought an upgrade")
	inputs[2].action=false;s.update(.1,pos,inputs)
	check(s.planning_progress==0,"Releasing confirmation did not reset it")
	inputs[2].action=true;s.update(3.1,pos,inputs)
	check(s.money==80 and s.improvements.shelter and s.next_phase=="repair","Confirmed upgrade did not apply")
	check("CONFIRMED" in host.animal_incident.title_label.text,"Purchase result vanished")
	s.update(1,pos,inputs);check(s.phase=="planning_gate","Result beat ended before it could be read")
	s._enter("planning_gate",25);s.update(4,pos,inputs)
	check(s.money==80,"Owned upgrade charged twice")
	s._enter("planning_machine",25);s.update(26,pos,inputs)
	check(s.phase=="dispatch" and s.money==80,"Late briefing spent money on a completed job")
	s.required_goods="apples";s.clues("STORE REPORT: Two safe apple loads.","BUYER: Apples only.")
	s.handle_action(2,s.APIARY)
	check(host.mission_facts[2]=="BUYER: Apples only.","Carrying replaced the private buyer fact")
	var before:int=s.contributions[2]
	for n in range(20):s.command(2,"pin")
	check(s.contributions[2]==before,"Sharing spam inflated recognition")
	s._enter("weather",210)
	var crop=host.world_root.crop_field
	for plot in crop.work_plots:crop.apply_tractor_work(plot)
	check(crop.stage==1 and not crop.operation_ready,"Preparation did not stop for tool confirmation")
	for plot in crop.work_plots:crop.apply_tractor_work(plot)
	check(crop.stage==1,"Sowing began without a deliberate tool change")
	host.tractor_driver=1;host.player_modes[1]="tractor";s.command(2,"tool")
	check(not crop.operation_ready,"A non-driver changed the tractor tool")
	s.command(1,"tool");check(crop.operation_ready,"Driver tool command failed")
	host.player_modes[1]="foot";host.tractor_driver=0
	pos={1:s.INTAKE,2:s.APIARY};s.update(4.1,pos,inputs)
	check(s.sealed and s.covered,"Sealing or purchased faster covering did not complete")
	pos[2]=s.PACK;s.update(4.1,pos,inputs);check(s.crates_ready,"Packing preparation did not take effect")
	# Gate lease permits the keeper to move, but expires and must be refreshed.
	host.animal_incident.start_incident();var a=host.animal_incident
	a.update_incident(.1,{1:Vector2.ZERO,2:a.GATE},inputs)
	inputs[2].action=false;a.update_incident(2,{1:Vector2.ZERO,2:Vector2.ZERO},inputs)
	check(a.gate_holder==2,"Gate closed as soon as the keeper left")
	a.update_incident(7,{1:Vector2.ZERO,2:Vector2.ZERO},inputs);check(a.gate_holder==0,"Gate lease never expired")
	print("Mission experience: purchase confirmation/ownership, hay/result feedback, delivery briefing, persistent buyer clue, fair task credits, tool authority, storage prep and gate windows")
	quit(1 if errors else 0)
