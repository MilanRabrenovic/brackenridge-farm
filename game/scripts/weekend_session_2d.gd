class_name WeekendSession2D
extends Node

# Host-owned authored weekend. All clocks use simulation delta and seeded choices.
const PACK := Vector2(18,46)
const DISPATCH := Vector2(65,49)
const APIARY := Vector2(64,28)
const INTAKE := Vector2(20,17)
const HAY := Vector2(-13,-2)
var host: Node
var phase := "waiting"
var elapsed := 0.0
var phase_clock := 0.0
var remaining := 0.0
var seed_value := 1731
var rng := RandomNumberGenerator.new()
var solo := false
var paused := false
var outcomes: Dictionary = {}
var contributions := {1:0,2:0}
var stock := 0
var covered := false
var cover_progress := 0.0
var loaded := 0
var checked := false
var cargo := {1:"",2:""}
var chosen_goods := "barley"
var required_goods := "barley"
var load_progress := 0.0
var planning_choice := ""
var improvements := {"shelter":false,"maintenance":false}
var results_panel: PanelContainer
var summary: Label
var replay_button: Button
var phase_banner: Label
var cargo_sprites := {}
var rain: ColorRect
var rain_material: ShaderMaterial
var variant := 0
var money := 100
var waypoint: Label
var sound: AudioStreamPlayer
var sound_enabled := true
var shared_clue: Label
var shared_seconds := 0.0
var inventory := {"barley":0,"apples":2}
var log_events: Array = []
var hay_checked := {}
var weather_guidance_key := ""

func setup(owner_host: Node) -> void:
	host = owner_host
	sound=AudioStreamPlayer.new();sound.volume_db=-22;add_child(sound)
	var wave:=AudioStreamWAV.new();wave.format=AudioStreamWAV.FORMAT_16_BITS;wave.mix_rate=22050
	var bytes:=PackedByteArray();bytes.resize(6615*2)
	for i in range(6615):
		var value:=int(sin(float(i)*TAU*660/22050)*sin(PI*float(i)/6615)*5000)
		bytes.encode_s16(i*2,value)
	wave.data=bytes;sound.stream=wave
	waypoint=Label.new();waypoint.z_index=80;waypoint.add_theme_font_size_override("font_size",16);waypoint.add_theme_color_override("font_outline_color",Color("#173329"));waypoint.add_theme_constant_override("outline_size",6);host.world_root.add_child(waypoint)
	var layer := CanvasLayer.new(); layer.layer = 30; add_child(layer)
	rain=ColorRect.new();rain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);rain.mouse_filter=Control.MOUSE_FILTER_IGNORE;rain_material=ShaderMaterial.new();rain_material.shader=preload("res://shaders/rain_overlay.gdshader");rain.material=rain_material;layer.add_child(rain)
	shared_clue=Label.new();shared_clue.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);shared_clue.offset_top=-105;shared_clue.offset_left=40;shared_clue.offset_right=-40;shared_clue.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;shared_clue.add_theme_font_size_override("font_size",20);shared_clue.add_theme_color_override("font_outline_color",Color("#173329"));shared_clue.add_theme_constant_override("outline_size",7);layer.add_child(shared_clue);shared_clue.hide()
	phase_banner = Label.new(); phase_banner.position = Vector2(20,12); phase_banner.add_theme_font_size_override("font_size",20); phase_banner.add_theme_color_override("font_outline_color",Color("#18372b")); phase_banner.add_theme_constant_override("outline_size",6); layer.add_child(phase_banner)
	results_panel = PanelContainer.new(); results_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER); results_panel.position=Vector2(-285,-190); results_panel.custom_minimum_size=Vector2(570,380); layer.add_child(results_panel)
	var style := StyleBoxFlat.new(); style.bg_color=Color("#173329"); style.border_color=Color("#e6ce88"); style.set_border_width_all(3); style.set_corner_radius_all(18); style.content_margin_left=26;style.content_margin_right=26;style.content_margin_top=24;style.content_margin_bottom=24; results_panel.add_theme_stylebox_override("panel",style)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation",16); results_panel.add_child(box)
	summary=Label.new();summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;summary.custom_minimum_size=Vector2(510,230);summary.add_theme_font_size_override("font_size",22); box.add_child(summary)
	replay_button=Button.new(); replay_button.text="PLAY ANOTHER WEEKEND";replay_button.custom_minimum_size.y=48;box.add_child(replay_button);replay_button.pressed.connect(func(): restart(seed_value+1))
	results_panel.hide()
	for id in [1,2]:
		var sprite := Sprite2D.new();sprite.texture=preload("res://assets/2d/production/produce_crates.png");sprite.scale=Vector2(.065,.065);sprite.position=Vector2(0,-21);sprite.hide();host.players[id].add_child(sprite);cargo_sprites[id]=sprite

func start(player_count: int, replay_seed: int = 1731) -> void:
	if phase != "waiting": return
	solo=player_count<2;seed_value=replay_seed;rng.seed=seed_value;variant=rng.randi_range(0,2)
	host.players[2].visible=not solo
	_enter("arrival",75.0)

func restart(new_seed: int) -> void:
	host.repair_incident.reset();host.animal_incident.state="waiting";host.animal_incident.gate_marker.hide();host.animal_incident.safe_marker.hide()
	host.cooperative_clues_sent=true
	phase="waiting";elapsed=0;outcomes.clear();contributions={1:0,2:0};stock=0;covered=false;cover_progress=0;loaded=0;checked=false;cargo={1:"",2:""};load_progress=0;inventory={"barley":stock,"apples":2};improvements={"shelter":false,"maintenance":false};log_events.clear();hay_checked.clear();results_panel.hide();paused=false;money=100;host.world_root.crop_field.set_process(true)
	host.world_root.crop_field.set_stage(0)
	for id in [1,2]:
		host.player_modes[id]="foot";host.players[id].collision_layer=2;host.players[id].show();host.inputs[id]=host.neutral_input();host.previous_actions[id]=false;host.pending_actions[id]=false;host.logical_positions[id]=Vector2(-2+id*5,7);host.players[id].position=host._logical_to_pixel(host.logical_positions[id]);cargo_sprites[id].hide()
	host.tractor_driver=0;host.tractor_body.position=host._logical_to_pixel(host.TRACTOR_START)
	host.tractor_facing="down";host.tractor_sprite.texture=host.tractor_directions.down;host.tractor_sprite.flip_h=false;host.tractor_sprite.rotation=0;host.wheel_front.hide();host.wheel_rear.hide();host.disconnected_pause=false;host.disconnected_was_paused=false
	start(host.admitted_players,new_seed)

func _enter(next: String, duration: float) -> void:
	phase=next;remaining=duration;phase_clock=0
	if sound_enabled: sound.play()
	host.world_root.modulate=Color.WHITE
	log_events.append({"time":snappedf(elapsed,.01),"phase":phase})
	host.animal_incident.incident_panel.show()
	rain_material.set_shader_parameter("strength",0.0)
	waypoint.hide()
	var target:=Vector2.ZERO
	match phase:
		"arrival": target=HAY;waypoint.text="CHECK HAY"
		"repair": target=host.repair_incident.BAY;waypoint.text="REPAIR BAY"
		"weather": target=INTAKE;waypoint.text="STORE HARVEST"
		"dispatch": target=PACK;waypoint.text="PACK THE ORDER"
	if waypoint.text!="" and phase in ["arrival","repair","weather","dispatch"]: waypoint.position=host._logical_to_pixel(target)+Vector2(-45,-115);waypoint.show()
	phase_banner.text=("SOLO TEST WEEKEND" if solo else "BRACKENRIDGE WEEKEND")+" · SEED %d" % seed_value
	match phase:
		"arrival":
			clues("WELCOME: Drag to walk. Tap ACTION beside the tractor to enter; EXIT returns on foot. Reach the animal-care sign to check hay.","WELCOME: Follow the blue marker. Tap ACTION near equipment; later you will inspect machines and hold gates.")
		"sheep":
			host.animal_incident.start_incident();host.animal_incident.time_left=150+variant*10
			if not solo: host._on_incident_private_message(1,"FLOCK: Guide five sheep toward the pasture gate. Approach from below to push them north. Ask your partner to keep the latch held; deadline %d:%02d." % [int(host.animal_incident.time_left)/60,int(host.animal_incident.time_left)%60])
			if solo: clues("SOLO FLOCK: The gate is held open for you. Approach below the sheep to push them toward the pasture.","")
		"planning_gate","planning_machine":
			planning_choice=""
			clues(("SOLO CHOICE: Hold ACTION at animal care for rain covers, or at repair bay for maintenance. Each costs £20; wait to save." if solo else "TEAM CHOICE: Hold ACTION at animal care to fit rain covers, or at repair bay for preventive maintenance. Both farmers must choose the same place."),"TEAM CHOICE: Rain covers halve the apple-covering effort; maintenance reduces repair effort. Meet your partner at the improvement you want, then both hold ACTION.")
		"repair":
			host.repair_incident.solo_assist=solo;host.repair_incident.start_incident("gasket" if variant==2 else "belt");host.repair_incident.marker.hide();host.repair_incident.time_left=180-variant*10
			if solo: clues("SOLO REPAIR: Collect the %s at %s, deliver to the repair bay and hold ACTION to fit; diagnosis and helper are provided." % [host.repair_incident.required_part,"workshop parts" if host.repair_incident.required_part=="gasket" else "feed-store supplies"],"")
		"weather":
			host.world_root.crop_field.set_stage(0);covered=false;cover_progress=0;stock=0;weather_guidance_key=""
			clues("FORECAST: Rain reaches the barley field soon. Use the tractor: cultivate, sow, let plants grow, then harvest. Deliver the grain at the intake sign before time runs out.","STORAGE: Two sealed loads fit in the silo. Hold ACTION at the apiary for six seconds to cover reserve apples; ACTION at grain intake stores harvested barley. Split these jobs with your grower.")
			if solo: clues("SOLO HARVEST: Drive the tractor across 16 different field cells to prepare soil; repeat to sow. Let the crop grow, then harvest 16 cells. EXIT and ACTION at grain intake stores two loads. Hold ACTION at the apiary for six seconds to cover apples before rain.","")
		"dispatch":
			loaded=0;checked=false;cargo={1:"",2:""};load_progress=0;inventory={"barley":stock,"apples":2}
			required_goods="barley" if stock>0 and variant!=2 else "apples"
			clues("STORE REPORT: Barley is dry and ready." if stock>0 else "STORE REPORT: Barley missed the rain deadline. Covered apples are the safe replacement; wet barley will be rejected.","BUYER: Bring two loads of %s. If barley is spoiled, reserve apples are accepted instead. Inspect at dispatch, pack the safe goods, then hold ACTION together by the van." % required_goods)
			if solo: clues("SOLO DISPATCH: Collect two %s loads at %s, take each to packing, then hold ACTION at dispatch. Inspection and helper are provided." % [required_goods,"grain intake" if required_goods=="barley" else "apiary"],"")
		"results": _show_results()

func clues(one: String, two: String) -> void:
	for id in [1,2]:
		host._on_incident_private_message(id,one if id==1 else two)
		if host.player_modes[id]=="tractor":
			host._on_incident_controller_mode(id,"TRACTOR","EXIT","Drive repeated passes over the field to work it")
		else:
			host._on_incident_controller_mode(id,"FARMHAND" if phase=="arrival" else "GROWER" if id==1 else "ORDERKEEPER","INTERACT","Follow the objective and share your private clue")

func command(id: int, value: String) -> void:
	match value:
		"pause":
			if host.disconnected_pause: return
			paused=not paused;host.world_root.crop_field.set_process(not paused);phase_banner.text="PAUSED · resume from phone or P" if paused else "BRACKENRIDGE WEEKEND"
		"pin":
			shared_clue.text="FARMER %d SHARED: %s" % [id,host.latest_clues.get(id,"")];shared_clue.show();shared_seconds=8;contributions[id]+=1
		"drop":
			if phase=="repair" and id==1 and not host.repair_incident.carried.is_empty():
				host.repair_incident.carried="";cargo_sprites[id].hide();host._on_incident_private_message(id,"Part returned to supplies. Ask the mechanic which one is needed.")
			if not str(cargo[id]).is_empty(): inventory[cargo[id]]+=1;cargo[id]="";cargo_sprites[id].hide();host._on_incident_private_message(id,"Item returned to its store. Your hands are free.")

func handle_action(id: int, pos: Vector2) -> bool:
	if phase in ["waiting","results"] or paused: return false
	match phase:
		"arrival":
			if pos.distance_to(HAY)<7:
				if not hay_checked.has(id): contributions[id]+=1;hay_checked[id]=true
				remaining=minf(remaining,8);return true
		"weather":
			if pos.distance_to(INTAKE)<7:
				if host.world_root.crop_field.stage==6: stock=2;contributions[id]+=1
				else: host._on_incident_private_message(id,"The silo needs harvested barley. Prepare, sow and harvest the field first.")
				return true
		"dispatch":
			if pos.distance_to(DISPATCH)<7:
				if not checked: contributions[id]+=1
				checked=true;return true
			if pos.distance_to(PACK)<7 and not str(cargo[id]).is_empty():
				if cargo[id]==required_goods and loaded<2:
					loaded+=1;contributions[id]+=1;host._on_incident_private_message(id,"Packed %d of 2 loads. Take another, then meet at dispatch." % loaded)
				else:
					inventory[cargo[id]]+=1
					host._on_incident_private_message(id,"That load fails the buyer's condition check. Ask your partner about dry stock.")
				cargo[id]="";cargo_sprites[id].hide();return true
			if cargo[id]=="":
				if pos.distance_to(INTAKE)<7 and inventory.barley>0: cargo[id]="barley"
				elif pos.distance_to(APIARY)<7 and inventory.apples>0: cargo[id]="apples"
				else: return false
				inventory[cargo[id]]-=1;cargo_sprites[id].show();host._on_incident_private_message(id,"Carrying %s. Take it to packing. ACTION there delivers." % cargo[id]);return true
	return false

func update(delta: float, positions: Dictionary, packets: Dictionary) -> void:
	if shared_seconds>0:
		shared_seconds-=delta
		if shared_seconds<=0: shared_clue.hide()
	if phase in ["waiting","results"] or paused: return
	elapsed+=delta;phase_clock+=delta;remaining=maxf(0,remaining-delta)
	if phase=="arrival" and host.admitted_players>=2: solo=false;host.players[2].show()
	match phase:
		"arrival":
			present("ARRIVAL · LEARN THE FARM","Walk to animal care and check the hay. Try entering and exiting the tractor.","ACTION beside equipment","Two farmers recommended" if not solo else "Full weekend · second-farmer assistance")
			if remaining<=0: _enter("sheep",150)
		"sheep":
			var effective := packets.duplicate(true)
			var loc := positions.duplicate()
			if solo:
				loc[2]=host.animal_incident.GATE;effective[2]={"action":true}
			host.animal_incident.update_incident(delta,loc,effective)
			if host.animal_incident.state in ["success","failure"]:
				outcomes.sheep=host.animal_incident.returned_count();contributions[1]+=int(outcomes.sheep);contributions[2]+=int(outcomes.sheep) if not solo else 0
				_enter("planning_gate",25)
		"planning_gate","planning_machine":
			for option in ["shelter","maintenance"]:
				var spot: Vector2=HAY if option=="shelter" else host.repair_incident.BAY
				var agreement:=true
				for id in ([1] if solo else [1,2]): agreement=agreement and positions[id].distance_to(spot)<7 and bool(packets[id].action)
				if agreement: planning_choice=option
			present("TEAM PLANNING",("Hold ACTION at animal care for rain covers, or repair bay for maintenance. Wait to save £20." if solo else "Meet at animal care for rain covers, or repair bay for maintenance. Hold ACTION together to choose."),planning_choice.to_upper() if planning_choice!="" else "CHOICE PENDING","£20 upgrade · £%d available · default saves" % money)
			if remaining<=0 or planning_choice!="":
				if planning_choice!="" and money>=20: improvements[planning_choice]=true;money-=20
				_enter("repair" if phase=="planning_gate" else "dispatch",210)
		"repair":
			cargo_sprites[1].visible=not host.repair_incident.carried.is_empty()
			var loc:=positions.duplicate();var effective:=packets.duplicate(true)
			if solo: host.repair_incident.diagnosis=true;loc[2]=host.repair_incident.BAY;effective[2]={"action":true}
			if improvements.maintenance and host.repair_incident.progress>=3: host.repair_incident.progress=6
			host.repair_incident.update_incident(delta,loc,effective)
			if host.repair_incident.state in ["success","failure"]:
				cargo_sprites[1].hide();outcomes.repair=host.repair_incident.state=="success";contributions[1]+=1 if outcomes.repair else 0;contributions[2]+=1 if outcomes.repair and not solo else 0
				_enter("weather",210)
		"weather":
			rain_material.set_shader_parameter("strength",clampf(1-remaining/70.0,0,1))
			host.world_root.modulate=Color.WHITE.lerp(Color(.80,.88,.94),clampf(1-remaining/70.0,0,1))
			for id in ([1] if solo else [1,2]):
				if positions[id].distance_to(APIARY)<7 and bool(packets[id].action): cover_progress+=delta;contributions[id]+=1 if not covered and cover_progress>=6 else 0
			if cover_progress>=(3 if improvements.shelter else 6): covered=true
			_update_weather_guidance()
			if (stock==2 and covered) or remaining<=0:
				outcomes.weather=stock==2 and covered
				if stock==0: host.world_root.crop_field.set_stage(7)
				# A modest salvage load keeps failure recoverable, never a softlock.
				covered=true;_enter("planning_machine",25)
		"dispatch":
			var together:=loaded==2 and (checked or solo)
			for id in ([1] if solo else [1,2]): together=together and positions[id].distance_to(DISPATCH)<7 and bool(packets[id].action)
			if together: load_progress+=delta
			present("SUNDAY · FINAL DISPATCH",("Carry two %s loads to packing, then hold ACTION by the dispatch van. A helper assists loading." % required_goods if solo else "Share the stock and buyer clues. Carry two correct loads to packing, then hold ACTION together at dispatch."),"PACKED %d/2 · LOAD %d%%" % [loaded,mini(100,int(load_progress/6*100))],"Buyer checked" if checked else ("Helper checked the buyer" if solo else "Inspect the buyer at dispatch"))
			if load_progress>=6 or remaining<=0: outcomes.dispatch=load_progress>=6;_enter("results",0)

func _update_weather_guidance(force_phone := false) -> void:
	var crop=host.world_root.crop_field
	var stage:int=int(crop.stage)
	var objective:=""
	var task_label:="BARLEY FIELD"
	var target:=Vector2(52,-38)
	var progress:String=crop.current_stage_name()
	match stage:
		0:
			objective="Enter the tractor and cultivate the barley field. Drive across different soil cells to prepare it."
			progress="CULTIVATE %d/16" % crop.worked_cells.size()
		1:
			objective="Soil is ready. Drive another pass across different field cells to sow barley."
			progress="SOW %d/16" % crop.worked_cells.size()
		2,3,4:
			var growth_left:float=(10.0 if stage==2 else 12.0 if stage==3 else 15.0)-crop.growth_clock
			objective="Barley is growing. Keep the headland clear; harvest when the crop turns golden."
			progress="%s · next growth in %ds" % [crop.current_stage_name(),ceili(maxf(0,growth_left))]
		5:
			objective="Barley is ripe. Drive the tractor across different crop cells to harvest it."
			progress="HARVEST %d/16" % crop.worked_cells.size()
		6:
			objective="Harvest complete. Drive back to grain intake, EXIT the tractor, then tap ACTION to store two loads."
			target=INTAKE;task_label="STORE HARVEST";progress="HARVEST COMPLETE"
		_:
			objective="The harvest window is closed. Reserve apples keep the farm going."
	if stock==2:
		target=APIARY;task_label="COVER APPLES"
		objective="Grain is safely stored. Hold ACTION at the apiary to protect reserve apples before rain."
		progress="APPLE COVER %d%%" % mini(100,int(cover_progress/(3 if improvements.shelter else 6)*100))
	waypoint.position=host._logical_to_pixel(target)+Vector2(-45,-115)
	waypoint.text=task_label;waypoint.show()
	present("SATURDAY · BEAT THE RAIN",objective,progress,"GRAIN %d/2 · APPLES %s" % [stock,"COVERED" if covered else "EXPOSED"])
	var next_key:="%d:%d:%s" % [stage,stock,str(covered)]
	if force_phone or next_key!=weather_guidance_key:
		weather_guidance_key=next_key
		var detail:=objective
		if stage in [0,1,5] and stock==0:detail+=" Work 16 different cells; staying still does not count."
		detail+=" " + ("Also hold ACTION at the apiary for six seconds to cover apples." if solo and stock<2 else "Ask your partner to protect the reserve apples." if not solo else "")
		host._on_incident_private_message(1,"FORECAST · BEAT THE RAIN: "+detail.strip_edges())

func present(title: String, objective: String, progress: String, feedback: String) -> void:
	var ui=host.animal_incident
	ui.title_label.text=title;ui.objective_label.text=objective;ui.progress_label.text=progress;ui.feedback_label.text=feedback;ui.timer_label.text="%d:%02d" % [int(remaining)/60,int(remaining)%60]

func _show_results() -> void:
	host.animal_incident.incident_panel.hide();waypoint.hide();results_panel.show();replay_button.grab_focus()
	var grade := "A flourishing weekend" if outcomes.get("dispatch",false) else "A weekend of useful lessons"
	money+=80 if outcomes.get("dispatch",false) else 20
	summary.text="WEEKEND COMPLETE\n%s\n\nSheep safe: %d / 5\nEquipment: %s\nHarvest: %s\nDelivery: %s\n\nGrower contributions: %d · Mechanic: %d\nBalance £%d · Seed %d · %d:%02d elapsed" % [grade,outcomes.get("sheep",0),"repaired" if outcomes.get("repair",false) else "workaround used","stored dry" if stock>0 else "reserve apples salvaged","on time" if outcomes.get("dispatch",false) else "buyer delayed",contributions[1],contributions[2],money,seed_value,int(elapsed)/60,int(elapsed)%60]
	var file=FileAccess.open("user://last_weekend.json",FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"seed":seed_value,"outcomes":outcomes,"contributions":contributions,"seconds":elapsed,"events":log_events}))
	for id in [1,2]: host._on_incident_private_message(id,"Weekend complete. See the TV results. Choose Play another weekend on the host or press R.")
