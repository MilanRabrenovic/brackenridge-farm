class_name RepairIncident2D
extends Node

signal private_message(player_id: int, text: String)
signal controller_mode(player_id: int, title: String, action_label: String, hint: String)

const BAY := Vector2(-8,5)
const BELT_CRATE := Vector2(-11,17)
const GASKET_CRATE := Vector2(-11,7)
var state := "waiting"
var required_part := "belt"
var time_left := 180.0
var solo_assist := false
var diagnosis := false
var carried := ""
var delivered := false
var progress := 0.0
var fitting_seconds := 6.0
var pressure := 0.0
var pressure_hint := ""
var gauge: Control
var ui: AnimalIncident2D
var world: Node2D
var marker: Label

func setup(world_node: Node2D, presentation: AnimalIncident2D) -> void:
	world = world_node
	ui = presentation
	marker = Label.new(); marker.text = "REPAIR BAY"; marker.position = world.logical_to_pixel(BAY)+Vector2(-45,-45)
	marker.add_theme_font_size_override("font_size",12); marker.add_theme_color_override("font_outline_color",Color("#18372b")); marker.add_theme_constant_override("outline_size",4)
	marker.z_index = 60; marker.hide(); world.add_child(marker)
	gauge=preload("res://scripts/repair_pressure_gauge.gd").new()
	gauge.custom_minimum_size=Vector2(0,18);gauge.hide()
	ui.feedback_label.get_parent().add_child(gauge)

func start_incident(fault_part := "belt") -> void:
	required_part="gasket" if fault_part=="gasket" else "belt"
	state = "active"; time_left = 180.0; diagnosis = false; carried = ""; delivered = false; progress = 0.0; pressure=0;pressure_hint=""
	ui.gate_marker.hide(); ui.safe_marker.hide(); ui.incident_panel.show(); marker.show()
	world.set_destination_suppressed("repair_bay",true)
	private_message.emit(2,"DIAGNOSIS: The packing machine is spluttering. ACTION at repair bay reveals the fault. Then HOLD to build test pressure and RELEASE to cool; keep the needle GREEN while your partner fetches the part.")
	private_message.emit(1,"STORES: Feed-store supplies contain a belt. Workshop parts crate contains a gasket. Ask the mechanic which part is needed. ACTION collects; ACTION at the bay delivers. Then HOLD ACTION to fit while the mechanic balances the green gauge.")
	controller_mode.emit(1,"PARTS RUNNER","COLLECT / DELIVER","Ask which part; workshop crate or feed store, then repair bay")
	controller_mode.emit(2,"MECHANIC","PUMP / RELEASE","Hold to build pressure; release to stay in the green band")
	_refresh()

func handle_action(id: int, position: Vector2) -> bool:
	if state != "active": return false
	if id == 2 and position.distance_to(BAY)<5.0:
		if not diagnosis:pressure=.5
		diagnosis = true
		private_message.emit(2,"DIAGNOSIS: A %s is needed. Tell your partner. HOLD builds pressure; RELEASE cools it. Keep 40–75%% GREEN while your partner fetches and fits." % required_part)
		return true
	if id != 1: return false
	# Delivery takes priority when carrying; collection zones do not require
	# entering the crate's collision footprint.
	if not carried.is_empty() and position.distance_to(BAY)<5.0:
		if not diagnosis:
			private_message.emit(1,"Wait for the mechanic to inspect the machine first.")
		elif carried != required_part:
			private_message.emit(1,"That part does not fit. Return for the part your mechanic requested.")
			carried = ""
		else:
			delivered = true; carried = ""
			private_message.emit(1,"Part delivered. Hold ACTION at the repair bay to fit; your helper balances test pressure." if solo_assist else "Part delivered. Runner: HOLD ACTION to fit. Mechanic: balance pressure in GREEN, holding to pump and releasing to cool.")
		return true
	if position.distance_to(BELT_CRATE)<5.0:
		carried = "belt"; private_message.emit(1,"Carrying feed-store belt. Bring it to the mechanic."); return true
	if position.distance_to(GASKET_CRATE)<5.0:
		carried = "gasket"; private_message.emit(1,"Carrying workshop gasket. Bring it to the mechanic."); return true
	return false

func update_incident(delta: float, positions: Dictionary, inputs: Dictionary) -> void:
	if state != "active": return
	time_left = maxf(0,time_left-delta)
	var runner_near:=Vector2(positions.get(1,Vector2(999,999))).distance_to(BAY)<5
	var mechanic_near:=Vector2(positions.get(2,Vector2(999,999))).distance_to(BAY)<5
	var runner_holds:=bool(inputs.get(1,{}).get("action",false))
	var mechanic_pumps:=bool(inputs.get(2,{}).get("action",false))
	# Integrate small fixed-size pieces so a large test delta cannot skip the
	# green band or produce a different result from normal host updates.
	var remaining_delta:=delta
	while remaining_delta>0:
		var dt:=minf(remaining_delta,1.0/60);remaining_delta-=dt
		if solo_assist and diagnosis: pressure=.55
		elif diagnosis:pressure=clampf(pressure+dt*(.22 if mechanic_near and mechanic_pumps else -.12),0,1)
		if delivered and diagnosis and runner_near and mechanic_near and runner_holds and pressure>=.4 and pressure<=.75:
			progress=minf(fitting_seconds,progress+dt)
	_refresh()
	if progress >= fitting_seconds-.001: _finish(true)
	elif time_left <= 0: _finish(false)

func _refresh() -> void:
	ui.title_label.text = "REPAIR BEFORE DELIVERY"
	ui.timer_label.text = "%d:%02d" % [ceili(time_left)/60,ceili(time_left)%60]
	ui.objective_label.text = "Collect the %s at %s, deliver to the repair bay, then hold ACTION. Your helper handles diagnosis and keeps test pressure green." % [required_part,"workshop parts" if required_part=="gasket" else "feed-store supplies"] if solo_assist else "Share your private clues. Inspect the fault, bring the correct part, Runner holds to fit; mechanic pumps and releases to keep the gauge GREEN. Both stay at the repair bay."
	ui.progress_label.text = "FITTING %d%%" % int(progress/fitting_seconds*100) if delivered else "PART NEEDED" if diagnosis else "INSPECT MACHINE"
	var band:="GREEN" if pressure>=.4 and pressure<=.75 else "HOT" if pressure>.75 else "LOW"
	ui.feedback_label.text=("Helper balances pressure · runner holds to fit" if solo_assist else "PRESSURE %d%% · %s · %s" % [int(pressure*100),band,"Release! It's a packing machine, not a rocket." if band=="HOT" else "Hold to pump; runner keeps fitting" if band=="LOW" else "Steady! Runner holds to fit" ]) if diagnosis else "Mechanic inspects · runner asks which part"
	gauge.visible=state=="active";gauge.set("pressure",pressure);gauge.queue_redraw()
	var hint_key:=band+str(delivered)
	if diagnosis and hint_key!=pressure_hint:
		pressure_hint=hint_key
		if not solo_assist:private_message.emit(2,"TEST PRESSURE: %s. %s" % [band,"Release ACTION to cool; fitting pauses until green. Progress is safe." if band=="HOT" else "Hold ACTION at the bay to pump up into GREEN." if band=="LOW" else "Keep 40–75% GREEN: HOLD pumps, RELEASE cools. Your partner holds to fit after delivery."])

func _finish(success: bool) -> void:
	state = "success" if success else "failure"; marker.hide();gauge.hide()
	world.set_destination_suppressed("repair_bay",false)
	ui.objective_label.text = "REPAIR COMPLETE — the packing drive is ready for dispatch." if success else "DELIVERY DELAYED — the repair was not completed in time."
	ui.feedback_label.text = "Purrs like a tractor. Finally stopped sounding like a kettle." if success else "Manual loading still works — the weekend continues."
	for id in [1,2]:
		private_message.emit(id,"Repair complete! Balanced pressure and the right part saved the machine. Next: beat the rain." if success else "Repair missed. Delivery is still possible, with slower hand loading.")
		controller_mode.emit(id,"GROWER" if id==1 else "MECHANIC","INTERACT","Explore the farm and use nearby equipment")

func reset() -> void:
	state = "waiting"; pressure=0;progress=0;pressure_hint="";marker.hide();gauge.hide(); world.set_destination_suppressed("repair_bay",false)
