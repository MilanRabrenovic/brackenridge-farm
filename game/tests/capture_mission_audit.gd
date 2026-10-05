extends SceneTree
# Staged current mission states for a readability audit, not a human playtest.
func _init() -> void: call_deferred("capture")
func capture() -> void:
	root.size=Vector2i(1280,720)
	var folder="res://../docs/audits/2026-09-30-missions"
	DirAccess.make_dir_recursive_absolute(folder)
	var host=load("res://main.tscn").instantiate()
	root.add_child(host);await process_frame
	host.set_process(false);host.set_physics_process(false)
	host.admitted_players=2;host.lobby_panel.hide();host.lobby_backdrop.hide()
	var s=host.weekend
	if s==null:quit(1);return
	s.sound_enabled=false;s.start(2)
	var views=["arrival","sheep","planning_gate","repair","weather","planning_machine","dispatch","results"]
	var positions={1:Vector2(3,3),2:Vector2(8,7)}
	var packets={1:{"action":false},2:{"action":false}}
	var cards={}
	for index in range(views.size()):
		var phase:String=views[index]
		if phase=="dispatch":s.stock=2
		if phase=="results":
			s.outcomes={"sheep":5,"repair":true,"weather":true,"dispatch":true};s.stock=2
		s._enter(phase,75 if phase=="arrival" else 25 if phase.begins_with("planning") else 0 if phase=="results" else 210)
		match phase:
			"sheep":positions={1:Vector2(-50,21),2:host.animal_incident.GATE}
			"planning_gate","repair":positions={1:s.HAY,2:host.repair_incident.BAY}
			"weather":positions={1:Vector2(32,-25),2:s.APIARY}
			"planning_machine":positions={1:s.INTAKE,2:s.APIARY}
			"dispatch":positions={1:s.PACK,2:s.DISPATCH}
		for id in [1,2]:
			host.logical_positions[id]=positions[id];host.players[id].position=host._logical_to_pixel(positions[id])
		host._update_camera(100);s.update(.016,positions,packets)
		cards[phase]={"one":host.latest_clues.get(1,""),"two":host.latest_clues.get(2,"")}
		await physics_frame;await process_frame;await process_frame;await RenderingServer.frame_post_draw
		var result=root.get_texture().get_image().save_png("%s/%02d-%s.png" % [folder,index+1,phase])
		if result!=OK:quit(1);return
	var file=FileAccess.open(folder+"/private-cards.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(cards,"\t"))
	print("Captured eight staged cooperative mission screens and current private cards")
	quit()
