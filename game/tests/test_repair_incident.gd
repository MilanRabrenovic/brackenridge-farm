extends SceneTree
var failures := 0
func _init() -> void:
	call_deferred("verify")
func check(value: bool, message: String) -> void:
	if not value: push_error(message); failures += 1
func verify() -> void:
	var host = load("res://main.tscn").instantiate(); root.add_child(host)
	await process_frame
	host.set_physics_process(false)
	var repair = host.repair_incident
	var clues := {}
	repair.private_message.connect(func(id,text): clues[id]=text)
	repair.start_incident()
	check(clues[1]!=clues[2],"Private roles must differ")
	repair.handle_action(1,repair.GASKET_CRATE)
	repair.handle_action(1,repair.BAY)
	check(not repair.delivered,"Part accepted before diagnosis")
	repair.handle_action(2,repair.BAY)
	repair.handle_action(1,repair.BAY)
	check(not repair.delivered and repair.carried.is_empty(),"Wrong part accepted")
	repair.handle_action(1,repair.BELT_CRATE)
	repair.handle_action(1,repair.BAY)
	check(repair.delivered,"Correct part was not delivered")
	var positions = {1:repair.BAY,2:repair.BAY}
	var inputs = {1:{"action":true},2:{"action":false}}
	repair.update_incident(3,positions,inputs)
	check(repair.progress==0,"One player repaired alone")
	inputs[2].action=true
	repair.update_incident(3,positions,inputs)
	positions[1]=Vector2(60,40)
	repair.update_incident(1,positions,inputs)
	check(repair.progress==3,"Distant helper advanced repair")
	positions[1]=repair.BAY
	repair.update_incident(3,positions,inputs)
	check(repair.state=="success","Cooperative repair failed")
	repair.reset(); repair.start_incident(); repair.update_incident(181,positions,{1:{"action":false},2:{"action":false}})
	check(repair.state=="failure","Timeout failed")
	var barn=host.world_root.get_node("StoneBarn")
	var floor= barn.get_node("UsableInteriorFloor")
	var bounds: Rect2=barn.get_meta("usable_interior")
	check(bounds.size.x < 180 and bounds.size.y < 110,"Interior exceeds structural footprint")
	barn.get_node("InteriorReveal").body_entered.emit(host.players[1])
	barn.get_node("InteriorReveal").body_entered.emit(host.players[2])
	check(floor.visible,"Interior floor not revealed")
	barn.get_node("InteriorReveal").body_exited.emit(host.players[1])
	check(floor.visible,"Floor hidden with second player inside")
	barn.get_node("InteriorReveal").body_exited.emit(host.players[2])
	check(not floor.visible,"Floor remained after exit")
	print("Repair lifecycle passed: private roles, diagnosis, wrong part, delivery, shared hold, distance, success, timeout; two-occupant interior passed")
	quit(1 if failures > 0 else 0)
