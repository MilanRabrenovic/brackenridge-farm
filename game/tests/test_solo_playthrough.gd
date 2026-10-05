extends SceneTree
# Walk/driving routes use the actual CharacterBody motor and physics collisions.
# One complete assisted solo route; all travel uses the real physics motor.
var host: Node
var session: Node
var errors := 0
var simulated_seconds := 0.0
var open_cells := {}
var capture_enabled := false
var input_sequence := 0
var active_id := 1
const DT := 1.0 / 60.0
func _init() -> void: call_deferred("verify")
func check(ok: bool, message: String) -> void:
	if not ok: errors+=1;push_error(message)
func step(direction := Vector2.ZERO, hold := false) -> void:
	await physics_frame
	input_sequence+=1
	host._handle({"type":"input","playerId":active_id,"seq":input_sequence,"x":direction.x,"y":direction.y,"action":hold})
	host._physics_process(DT)
	if not session.paused:host.world_root.crop_field._process(DT)
	simulated_seconds+=DT
func make_grid(radius: float) -> void:
	open_cells.clear()
	var shape:=CircleShape2D.new();shape.radius=radius
	for x in range(-80,81,2):
		for y in range(-56,57,2):
			var q:=PhysicsShapeQueryParameters2D.new();q.shape=shape;q.collision_mask=1;q.transform=Transform2D(0,host._logical_to_pixel(Vector2(x,y)))
			if host.world_root.get_world_2d().direct_space_state.intersect_shape(q).is_empty(): open_cells[Vector2i(x,y)]=true
func closest(point: Vector2) -> Vector2i:
	var result:=Vector2i.ZERO;var best:=INF
	for cell in open_cells:
		var distance:float=Vector2(cell).distance_squared_to(point)
		if distance<best:best=distance;result=cell
	return result
func travel(target: Vector2) -> void:
	var start:=closest(host.logical_positions[active_id]);var end:=closest(target)
	var queue=[start];var parents={start:start};var cursor:=0
	while cursor<queue.size() and not parents.has(end):
		var current:Vector2i=queue[cursor];cursor+=1
		for direction in [Vector2i(2,0),Vector2i(-2,0),Vector2i(0,2),Vector2i(0,-2)]:
			var next:Vector2i=current+direction
			if open_cells.has(next) and not parents.has(next): parents[next]=current;queue.append(next)
	if not parents.has(end):check(false,"No motor route to %s" % target);return
	var route=[Vector2(end)];var cell=end
	while cell!=start:cell=parents[cell];route.push_front(Vector2(cell))
	for point in route:
		for attempt in range(120):
			var diff:Vector2=point-host.logical_positions[active_id]
			if diff.length()<.25:break
			var speed:float=host.SPEED*(1.65 if host.player_modes[active_id]=="tractor" else 1.0)
			await step(diff.normalized()*minf(1,diff.length()/(speed*DT)))
		check(host.logical_positions[active_id].distance_to(point)<.5,"Motor blocked en route to %s at %s" % [target,host.logical_positions[active_id]])
		if errors>0:return
	check(host.logical_positions[active_id].distance_to(target)<2,"Did not reach target %s" % target)
func capture_view(label: String) -> void:
	check(host.animal_incident.incident_panel.get_global_rect().end.x<=root.size.x,"Objective panel runs off the screen")
	if not capture_enabled:return
	host._update_camera(100)
	await process_frame;await process_frame;await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("res://../docs/audits/2026-09-30-solo/%s.png" % label)
func action() -> void:
	await step() # Release a preceding hold before the next distinct tap.
	# A real quick tap can arrive down/up in one network poll. Only the normal
	# host tick may consume it; never invoke the context-action handler directly.
	for pressed in [true,false]:
		input_sequence+=1
		host._handle({"type":"input","playerId":active_id,"seq":input_sequence,"x":0.0,"y":0.0,"action":pressed})
	await step()
	await step()
func hold_for(seconds: float) -> void:
	for tick in range(ceili(seconds/DT)):await step(Vector2.ZERO,true)
func verify() -> void:
	# Faster wall-clock execution while keeping motor physics at 60 Hz simulated time.
	capture_enabled="--capture" in OS.get_cmdline_user_args()
	root.size=Vector2i(1280,720)
	Engine.max_fps=0
	Engine.physics_ticks_per_second=600
	Engine.time_scale=10
	host=load("res://main.tscn").instantiate();root.add_child(host);await process_frame;await physics_frame
	host.set_process(false);host.set_physics_process(false);host.world_root.crop_field.set_process(false)
	session=host.weekend
	if session==null:check(false,"Host/session failed to compile or initialize");quit(1);return
	host.admitted_players=1;host.lobby_panel.hide();host.lobby_backdrop.hide();session.sound_enabled=false;session.start(1,1731)
	# Losing the only phone freezes play, including an existing manual pause.
	host._handle({"type":"roster","players":[]})
	var before:float=session.remaining
	await step(Vector2.DOWN)
	check(session.paused and session.remaining==before,"Solo disconnect advanced the mission")
	host._handle({"type":"roster","players":[{"id":1,"connected":true,"admission":"admitted"}]})
	check(not session.paused,"Solo reconnect stayed paused")
	host.world_root.crop_field.set_process(false)
	host._handle({"type":"command","playerId":1,"command":"pause"})
	host._handle({"type":"roster","players":[]})
	host._handle({"type":"roster","players":[{"id":1,"connected":true,"admission":"admitted"}]})
	check(session.paused,"Reconnect cancelled the user's manual pause")
	host._handle({"type":"command","playerId":1,"command":"pause"})
	host.world_root.crop_field.set_process(false)
	make_grid(8)
	await capture_view("arrival")
	await travel(session.HAY);await action();await hold_for(8.2)
	check(session.phase=="sheep","Arrival did not advance")
	await travel(Vector2(-42,12))
	for tick in range(10000):
		if session.phase!="sheep":break
		var target:Node2D=null;var southernmost:float=-999
		for sheep in host.animal_incident.sheep:
			var pos:Vector2=host.world_root.pixel_to_logical(sheep.position)
			if pos.y>southernmost and pos.y>-18:target=sheep;southernmost=pos.y
		if target==null:await step();continue
		var behind:Vector2=host.world_root.pixel_to_logical(target.position)+Vector2(0,5.5)
		var direction:Vector2=(behind-host.logical_positions[1]).limit_length(1.0)
		await step(direction)
	check(session.phase=="planning_gate" and session.outcomes.get("sheep",0)==5,"Motor herding did not return all sheep")
	session.update(26,host.logical_positions,{1:{"action":false},2:{"action":false}})
	await hold_for(3.2)
	await travel(host.repair_incident.GASKET_CRATE if host.repair_incident.required_part=="gasket" else host.repair_incident.BELT_CRATE);await action();await step()
	await travel(host.repair_incident.BAY);await action();await capture_view("repair");await hold_for(9.3)
	check(session.phase=="weather" and session.outcomes.repair,"Solo motor repair failed")
	check(host.world_root.crop_field.stage==0,"Solo starts with unprepared ground")
	check("cultivate" in host.animal_incident.objective_label.text and session.waypoint.text=="BARLEY FIELD","Unprepared soil has no cultivation guidance")
	await travel(host._tractor_logical()+Vector2(4,0));await action();check(host.tractor_driver==1,"Tractor entry failed")
	await capture_view("cultivate")
	make_grid(22)
	var observed_stages:Dictionary={0:true}
	host.world_root.crop_field.stage_changed.connect(func(_label):observed_stages[int(host.world_root.crop_field.stage)]=true)
	# Drive rows through the real field entrance and work cells, never set crop state.
	for pass_index in range(2):
		if pass_index==1:host._handle({"type":"command","playerId":1,"command":"tool"})
		for y in [-26,-34,-42,-50]:
			await travel(Vector2(31,y));await travel(Vector2(73,y))
	print("After sowing route: stage=",host.world_root.crop_field.stage," phase=",session.phase," remaining=",session.remaining)
	check(host.world_root.crop_field.stage>=2,"Driving did not prepare and sow")
	for tick in range(2400):
		if host.world_root.crop_field.stage>=5:break
		await step()
	check(host.world_root.crop_field.stage in [5,6],"Crop never grew to maturity")
	host._handle({"type":"command","playerId":1,"command":"tool"})
	for y in [-50,-42,-34,-26]:
		await travel(Vector2(73,y));await travel(Vector2(31,y))
	await capture_view("harvest")
	check(host.world_root.crop_field.stage==6,"Motor harvest failed")
	check("EXIT" in host.animal_incident.objective_label.text and session.waypoint.text=="STORE HARVEST","Harvest does not direct safe tractor exit/storage")
	for stage in range(7):check(observed_stages.has(stage),"Missing natural crop stage %d" % stage)
	await travel(session.INTAKE+Vector2(4,0));await action();make_grid(8)
	await travel(session.INTAKE);await hold_for(4.2);await action();await travel(session.APIARY);await hold_for(9.3)
	print("After cover: phase=",session.phase," stock=",session.stock," covered=",session.covered," remaining=",session.remaining)
	check(session.phase=="planning_machine" and session.outcomes.weather,"Solo harvest/storage/cover failed")
	session.update(26,host.logical_positions,{1:{"action":false},2:{"action":false}})
	var store:Vector2=session.INTAKE if session.required_goods=="barley" else session.APIARY
	for load_index in range(2):await travel(store);await action();await travel(session.PACK);await action()
	await travel(session.DISPATCH);await hold_for(6.2)
	await capture_view("results")
	check(session.phase=="results" and session.outcomes.dispatch,"Solo delivery/results failed")
	session.restart(1732);check(session.phase=="arrival" and session.solo and host.tractor_driver==0,"Solo replay failed")
	print("Solo motor route: repair, tractor entrance, full crop lifecycle, intake, apple cover, two carried loads, dispatch/results/replay; %.1fs input-pipeline simulation, five sheep herded with gate assistance" % simulated_seconds)
	quit(1 if errors else 0)
