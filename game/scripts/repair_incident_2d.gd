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
var ui: AnimalIncident2D
var world: Node2D
var marker: Label

func setup(world_node: Node2D, presentation: AnimalIncident2D) -> void:
	world = world_node
	ui = presentation
	marker = Label.new(); marker.text = "REPAIR BAY"; marker.position = world.logical_to_pixel(BAY)+Vector2(-45,-45)
	marker.add_theme_font_size_override("font_size",12); marker.add_theme_color_override("font_outline_color",Color("#18372b")); marker.add_theme_constant_override("outline_size",4)
	marker.z_index = 60; marker.hide(); world.add_child(marker)

func start_incident(fault_part := "belt") -> void:
	required_part="gasket" if fault_part=="gasket" else "belt"
	state = "active"; time_left = 180.0; diagnosis = false; carried = ""; delivered = false; progress = 0.0
	ui.gate_marker.hide(); ui.safe_marker.hide(); ui.incident_panel.show(); marker.show()
	world.set_destination_suppressed("repair_bay",true)
	private_message.emit(2,"DIAGNOSIS: %s Inspect the repair bay, then hold ACTION there while your partner delivers and helps fit it." % ("The packing pump leaks and needs a GASKET." if required_part=="gasket" else "The packing drive slips and needs a BELT."))
	private_message.emit(1,"STORES: Feed-store supplies contain a belt. Workshop parts crate contains a gasket. Ask the mechanic which part is needed. ACTION collects it; ACTION at repair bay delivers it.")
	controller_mode.emit(1,"PARTS RUNNER","COLLECT / DELIVER","Ask which part; workshop crate or feed store, then repair bay")
	controller_mode.emit(2,"MECHANIC","INSPECT / HOLD","Inspect repair bay. Hold together to fit the delivered part")
	_refresh()

func handle_action(id: int, position: Vector2) -> bool:
	if state != "active": return false
	if id == 2 and position.distance_to(BAY)<5.0:
		diagnosis = true
		private_message.emit(2,"CONFIRMED: A %s is needed. Tell your partner. Stay here and hold ACTION once it is delivered." % required_part)
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
			private_message.emit(1,"Part delivered. Hold ACTION at the repair bay for six seconds; your helper holds the other side." if solo_assist else "Part delivered. Both farmers must hold ACTION at the repair bay for six seconds.")
		return true
	if position.distance_to(BELT_CRATE)<5.0:
		carried = "belt"; private_message.emit(1,"Carrying feed-store belt. Bring it to the mechanic."); return true
	if position.distance_to(GASKET_CRATE)<5.0:
		carried = "gasket"; private_message.emit(1,"Carrying workshop gasket. Bring it to the mechanic."); return true
	return false

func update_incident(delta: float, positions: Dictionary, inputs: Dictionary) -> void:
	if state != "active": return
	time_left = maxf(0,time_left-delta)
	var together := delivered
	for id in [1,2]:
		together = together and Vector2(positions[id]).distance_to(BAY)<5.0 and bool(inputs[id].get("action",false))
	if together: progress = minf(6.0,progress+delta)
	_refresh()
	if progress >= 6.0: _finish(true)
	elif time_left <= 0: _finish(false)

func _refresh() -> void:
	ui.title_label.text = "REPAIR BEFORE DELIVERY"
	ui.timer_label.text = "%d:%02d" % [ceili(time_left)/60,ceili(time_left)%60]
	ui.objective_label.text = "Collect the %s at %s, deliver to the repair bay, then hold ACTION. Your helper handles diagnosis and the second hold." % [required_part,"workshop parts" if required_part=="gasket" else "feed-store supplies"] if solo_assist else "Share your private clues. Inspect the fault, bring the correct part, then hold ACTION together at the repair bay."
	ui.progress_label.text = "FITTING %d%%" % int(progress/6.0*100) if delivered else "PART NEEDED" if diagnosis else "INSPECT MACHINE"
	ui.feedback_label.text = ("Hold ACTION · helper ready" if solo_assist else "Both hold at repair bay") if delivered else "Runner carrying a part" if not carried.is_empty() else "Helper diagnosed: %s needed" % required_part if solo_assist else "Mechanic inspects · partner fetches"

func _finish(success: bool) -> void:
	state = "success" if success else "failure"; marker.hide()
	world.set_destination_suppressed("repair_bay",false)
	ui.objective_label.text = "REPAIR COMPLETE — the packing drive is ready for dispatch." if success else "DELIVERY DELAYED — the repair was not completed in time."
	ui.feedback_label.text = "Free farming · R replays both events"
	for id in [1,2]:
		private_message.emit(id,"Repair complete. Explore the farm, or press R on the host to replay." if success else "Delivery delayed. Explore the farm, or press R on the host to retry.")
		controller_mode.emit(id,"GROWER" if id==1 else "MECHANIC","INTERACT","Explore the farm and use nearby equipment")

func reset() -> void:
	state = "waiting"; marker.hide(); world.set_destination_suppressed("repair_bay",false)
