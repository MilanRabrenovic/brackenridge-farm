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
var next_phase := ""
var result_seconds := 0.0
var planning_progress := 0.0
var planning_candidate := ""
var briefing_ready := {}
var sealed := false
var seal_progress := 0.0
var crates_ready := false
var crate_progress := 0.0
var task_credits := {}
var replay_votes := {}
var replay_status: Label

func _credit(id: int, task: String) -> void:
	var key:="%d:%s" % [id,task]
	if not task_credits.has(key):task_credits[key]=true;contributions[id]+=1

func _result_then(next: String, title: String, detail: String) -> void:
	next_phase=next;result_seconds=3.0;waypoint.hide()
	host.animal_incident.gate_marker.hide();host.animal_incident.safe_marker.hide()
	present(title,detail,"NEXT JOB IN 3 SECONDS","Your farm continues even after a missed deadline")
	for id in ([1] if solo else [1,2]):host._on_incident_private_message(id,detail)

func _goods() -> String:
	return "barley" if stock>0 and variant!=2 else "apples"

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
	shared_clue=Label.new();shared_clue.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE);shared_clue.offset_top=-145;shared_clue.offset_left=40;shared_clue.offset_right=-40;shared_clue.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;shared_clue.add_theme_font_size_override("font_size",20);shared_clue.add_theme_color_override("font_outline_color",Color("#173329"));shared_clue.add_theme_constant_override("outline_size",7);layer.add_child(shared_clue);shared_clue.hide()
	phase_banner = Label.new(); phase_banner.position = Vector2(20,12); phase_banner.add_theme_font_size_override("font_size",20); phase_banner.add_theme_color_override("font_outline_color",Color("#18372b")); phase_banner.add_theme_constant_override("outline_size",6); layer.add_child(phase_banner)
	results_panel = PanelContainer.new(); results_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER); results_panel.position=Vector2(-285,-190); results_panel.custom_minimum_size=Vector2(570,380); layer.add_child(results_panel)
	var style := StyleBoxFlat.new(); style.bg_color=Color("#173329"); style.border_color=Color("#e6ce88"); style.set_border_width_all(3); style.set_corner_radius_all(18); style.content_margin_left=26;style.content_margin_right=26;style.content_margin_top=24;style.content_margin_bottom=24; results_panel.add_theme_stylebox_override("panel",style)
	var box := VBoxContainer.new(); box.add_theme_constant_override("separation",16); results_panel.add_child(box)
	summary=Label.new();summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;summary.custom_minimum_size=Vector2(510,230);summary.add_theme_font_size_override("font_size",22); box.add_child(summary)
	replay_status=Label.new();replay_status.add_theme_font_size_override("font_size",16);box.add_child(replay_status)
	replay_button=Button.new(); replay_button.text="PLAY ANOTHER WEEKEND";replay_button.custom_minimum_size.y=48;box.add_child(replay_button);replay_button.pressed.connect(func(): restart(seed_value+1))
	results_panel.resized.connect(func(): results_panel.position=(host.get_viewport().get_visible_rect().size-results_panel.size)*.5)
	results_panel.hide()
	for id in [1,2]:
		var sprite := Sprite2D.new();sprite.texture=preload("res://assets/2d/production/produce_crates.png");sprite.scale=Vector2(.065,.065);sprite.position=Vector2(0,-21);sprite.hide();host.players[id].add_child(sprite);cargo_sprites[id]=sprite

func start(player_count: int, replay_seed: int = 1731) -> void:
	if phase != "waiting": return
	solo=player_count<2;seed_value=replay_seed;rng.seed=seed_value;variant=rng.randi_range(0,2)
	host.players[2].visible=not solo
	_enter("arrival",75.0)

func restart(new_seed: int) -> void:
	replay_votes.clear()
	next_phase="";result_seconds=0;planning_progress=0;planning_candidate="";briefing_ready.clear();task_credits.clear();sealed=false;seal_progress=0;crates_ready=false;crate_progress=0
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
	next_phase="";result_seconds=0
	host.animal_incident.gate_marker.hide();host.animal_incident.safe_marker.hide()
	host.repair_incident.gauge.hide()
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
			clues("WELCOME: Drag to walk. Tap ACTION beside the tractor to enter; EXIT returns on foot. Reach the animal-care sign to check hay.","WELCOME: Drag to walk. Meet your partner at CHECK HAY by animal care and tap ACTION. You will open the sheep gate and inspect the faulty machine.")
		"sheep":
			host.animal_incident.escape_variant=variant;host.animal_incident.start_incident();host.animal_incident.time_left=150+variant*10
			if not solo: host._on_incident_private_message(1,"FLOCK: Guide five sheep toward the pasture gate. Approach from below to push them north. Ask your partner to refresh the eight-second latch window; deadline %d:%02d." % [int(host.animal_incident.time_left)/60,int(host.animal_incident.time_left)%60])
			if solo: clues("SOLO FLOCK: The gate is held open for you. Approach below the sheep to push them toward the pasture.","")
		"planning_gate":
			planning_choice="";planning_candidate="";planning_progress=0
			clues("TEAM CHOICE: Hold ACTION for three seconds at animal care for rain covers, or repair bay for maintenance. Each costs £20. Wait to save your money.","TEAM CHOICE: Covers halve apple-covering time; maintenance halves fitting time. Meet at the same place and both hold for three seconds.")
		"planning_machine":
			briefing_ready.clear();required_goods=_goods()
			clues("STORE REPORT: %s Read your partner's buyer clue, then ACTION at packing when ready." % ("Two dry barley loads are stored." if stock>0 else "Rain spoiled the barley. Two salvage apple loads remain."),"BUYER: Two loads of %s. Collect at %s, pack at the canopy, then meet at the van. ACTION at dispatch when ready." % [required_goods,"grain intake" if required_goods=="barley" else "orchard apiary"])
			if solo:clues("DELIVERY BRIEFING: Two %s loads are needed. ACTION at packing or dispatch to start, or wait for the briefing to finish." % required_goods,"")
		"repair":
			host.repair_incident.solo_assist=solo;host.repair_incident.start_incident("gasket" if variant==2 else "belt");host.repair_incident.marker.hide();host.repair_incident.fitting_seconds=3.0 if improvements.maintenance else 6.0;host.repair_incident.time_left=180-variant*10
			if solo: clues("SOLO REPAIR: Collect the %s at %s, deliver to the repair bay and hold ACTION to fit; diagnosis and helper are provided." % [host.repair_incident.required_part,"workshop parts" if host.repair_incident.required_part=="gasket" else "feed-store supplies"],"")
		"weather":
			host.world_root.crop_field.set_stage(0);covered=false;cover_progress=0;stock=0;weather_guidance_key="";sealed=false;seal_progress=0;crates_ready=false;crate_progress=0
			clues("FORECAST: Use the tractor to work all 16 marked plots. Engage field tool on your phone before sowing and harvesting. While barley grows, help prepare storage or cover apples.","STORAGE CREW: Hold ACTION at intake for four seconds to seal it, at apiary for six to cover apples, and optionally at packing for four to prepare crates. Prepared crates speed dispatch. Then store the grower's harvest at intake.")
			if solo: clues("SOLO HARVEST: Work all 16 gold plot markers. Engage field tool before sowing and harvest. While crops grow, EXIT and seal intake (hold 4s) or cover apples (hold 6s). After harvest, ACTION at sealed intake stores grain.","")
		"dispatch":
			loaded=0;checked=false;cargo={1:"",2:""};load_progress=0;inventory={"barley":stock,"apples":2}
			required_goods=_goods()
			clues("STORE REPORT: Barley is dry and ready." if stock>0 else "STORE REPORT: Barley missed the rain deadline. Covered apples are the safe replacement; wet barley will be rejected.","BUYER: Bring two loads of %s. If barley is spoiled, reserve apples are accepted instead. Inspect at dispatch, pack the safe goods, then hold ACTION together by the van." % required_goods)
			if solo: clues("SOLO DISPATCH: Collect two %s loads at %s, take each to packing, then hold ACTION at dispatch. Inspection and helper are provided." % [required_goods,"grain intake" if required_goods=="barley" else "apiary"],"")
		"results": _show_results()

func clues(one: String, two: String) -> void:
	for id in [1,2]:
		host._on_incident_private_message(id,one if id==1 else two)
		if host.player_modes[id]=="tractor":
			host._on_incident_controller_mode(id,"TRACTOR","EXIT","Drive through gold plots; engage the tool before sowing or harvesting")
		else:
			host._on_incident_controller_mode(id,"FARMHAND" if phase=="arrival" else "GROWER" if id==1 else "ORDERKEEPER","INTERACT","Follow the objective and share your private clue")

func command(id: int, value: String) -> void:
	match value:
		"replay":
			if phase!="results" or id not in ([1] if solo else [1,2]): return
			if replay_votes.has(id): replay_votes.erase(id)
			else: replay_votes[id]=true
			_update_replay_status()
			if replay_votes.size()>=(1 if solo else 2) and host.admitted_players>=(1 if solo else 2): restart(seed_value+1)
		"tool":
			if paused or next_phase!="" or phase!="weather" or host.tractor_driver!=id:return
			host.world_root.crop_field.engage_operation()
			_update_weather_guidance(true)
		"pause":
			if host.disconnected_pause: return
			paused=not paused;host.world_root.crop_field.set_process(not paused);phase_banner.text="PAUSED · resume from phone or P" if paused else "BRACKENRIDGE WEEKEND"
		"pin":
			shared_clue.text="FARMER %d SHARED: %s" % [id,host.mission_facts.get(id,host.latest_clues.get(id,""))];shared_clue.show();shared_seconds=8
		"drop":
			if phase=="repair" and id==1 and not host.repair_incident.carried.is_empty():
				host.repair_incident.carried="";cargo_sprites[id].hide();host._on_incident_private_message(id,"Part returned to supplies. Ask the mechanic which one is needed.")
			if not str(cargo[id]).is_empty(): inventory[cargo[id]]+=1;cargo[id]="";cargo_sprites[id].hide();host._on_incident_private_message(id,"Item returned to its store. Your hands are free.")

func handle_action(id: int, pos: Vector2) -> bool:
	if phase in ["waiting","results"] or paused or next_phase!="": return false
	match phase:
		"arrival":
			if pos.distance_to(HAY)<7:
				if not hay_checked.has(id): _credit(id,"hay");hay_checked[id]=true
				host._on_incident_private_message(id,"Hay checked! The flock has food. Get ready: sheep have slipped out near the meadow.")
				remaining=minf(remaining,8);return true
		"planning_machine":
			if pos.distance_to(PACK)<7 or pos.distance_to(DISPATCH)<7:
				briefing_ready[id]=true;host._on_incident_private_message(id,"Ready for delivery. Waiting for your partner's briefing.");return true
		"weather":
			if pos.distance_to(INTAKE)<7:
				if not sealed:host._on_incident_private_message(id,"Hold ACTION here for four seconds to seal the grain intake first.")
				elif host.world_root.crop_field.stage==6:
					if stock==0:_credit(id,"store")
					stock=2;host._on_incident_private_message(id,"Two grain loads stored dry. Good work!")
				else: host._on_incident_private_message(id,"The silo needs harvested barley. Prepare, sow and harvest the field first.")
				return true
		"dispatch":
			if pos.distance_to(DISPATCH)<7:
				if not checked: _credit(id,"buyer")
				checked=true;return true
			if pos.distance_to(PACK)<7 and not str(cargo[id]).is_empty():
				if cargo[id]==required_goods and loaded<2:
					loaded+=1;_credit(id,"pack%d" % loaded);host._on_incident_private_message(id,"Packed %d/2. %s" % [loaded,"Both loads ready: meet at the van." if loaded==2 else "One load still needed. Coordinate with your partner."])
				else:
					inventory[cargo[id]]+=1
					host._on_incident_private_message(id,"Load returned: buyer requested %s. Check your partner's buyer clue." % required_goods)
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
	if next_phase!="":
		elapsed+=delta;result_seconds-=delta
		host.animal_incident.progress_label.text="NEXT JOB IN %d SECONDS" % ceili(maxf(0,result_seconds))
		if result_seconds<=0:_enter(next_phase,25 if next_phase in ["planning_gate","planning_machine"] else 210)
		return
	elapsed+=delta;phase_clock+=delta;remaining=maxf(0,remaining-delta)
	if phase=="arrival" and host.admitted_players>=2: solo=false;host.players[2].show()
	match phase:
		"arrival":
			present("WELCOME · SAVE THE WEEKEND","Keep the flock safe, fix the machine and deliver a dry harvest. First: ACTION at CHECK HAY; try the tractor.","HAY CHECKED · ESCAPE COMING" if not hay_checked.is_empty() else "FIRST JOB: CHECK HAY","Use your phones to share what only you know")
			if remaining<=0: _enter("sheep",150)
		"sheep":
			var effective := packets.duplicate(true)
			var loc := positions.duplicate()
			if solo:
				loc[2]=host.animal_incident.GATE;effective[2]={"action":true}
			host.animal_incident.update_incident(delta,loc,effective)
			if host.animal_incident.state in ["success","failure"]:
				outcomes.sheep=host.animal_incident.returned_count();contributions[1]+=int(outcomes.sheep);contributions[2]+=int(outcomes.sheep) if not solo else 0
				_result_then("planning_gate","FLOCK SAFE" if outcomes.sheep==5 else "FLOCK RESCUED: %d/5" % outcomes.sheep,"%d sheep made it home. Next: choose one improvement before repair and rain." % outcomes.sheep)
		"planning_gate":
			var candidate:=""
			for option in ["shelter","maintenance"]:
				var spot: Vector2=HAY if option=="shelter" else host.repair_incident.BAY
				var agreement:=true
				for id in ([1] if solo else [1,2]): agreement=agreement and positions[id].distance_to(spot)<7 and bool(packets[id].action)
				if agreement and not improvements[option] and money>=20:candidate=option
			if candidate!=planning_candidate:planning_progress=0;planning_candidate=candidate
			planning_progress=planning_progress+delta if candidate!="" else 0
			if planning_progress>=3:planning_choice=candidate
			present("ONE FARM IMPROVEMENT","Rain covers at animal care: half covering time. Maintenance at repair bay: half fitting time. Hold together for 3s, or wait to save.","%s · CONFIRM %d%%" % [planning_candidate.to_upper(),mini(100,int(planning_progress/3*100))] if candidate!="" else "CHOOSE TOGETHER · HOLD TO CONFIRM","£20 upgrade · £%d available · timeout saves" % money)
			if remaining<=0 or planning_choice!="":
				if planning_choice!="" and money>=20: improvements[planning_choice]=true;money-=20
				_result_then("repair","IMPROVEMENT CONFIRMED" if planning_choice!="" else "MONEY SAVED","%s Next: inspect the faulty packing machine." % ("%s fitted for £20." % planning_choice.capitalize() if planning_choice!="" else "£20 kept for the farm."))
		"planning_machine":
			present("DELIVERY BRIEFING","Two loads are needed. Read your private buyer and stock clues. ACTION at packing or dispatch marks you ready.","%d/%d FARMERS READY" % [briefing_ready.size(),1 if solo else 2],"Tell your partner what only your phone knows")
			if remaining<=0 or briefing_ready.size()>=(1 if solo else 2):_enter("dispatch",210)
		"repair":
			cargo_sprites[1].visible=not host.repair_incident.carried.is_empty()
			var loc:=positions.duplicate();var effective:=packets.duplicate(true)
			if solo: host.repair_incident.diagnosis=true;loc[2]=host.repair_incident.BAY;effective[2]={"action":true}
			host.repair_incident.update_incident(delta,loc,effective)
			if host.repair_incident.state in ["success","failure"]:
				cargo_sprites[1].hide();outcomes.repair=host.repair_incident.state=="success";contributions[1]+=1 if outcomes.repair else 0;contributions[2]+=1 if outcomes.repair and not solo else 0
				_result_then("weather","MACHINE REPAIRED" if outcomes.repair else "MANUAL PACKING NEEDED","Next: beat the rain. %s" % ("No more kettle noises! The repaired machine makes loading faster." if outcomes.repair else "You can still deliver, but hand loading will take longer."))
		"weather":
			if host.world_root.crop_field.stage==6:_credit(host.tractor_driver if host.tractor_driver>0 else 1,"harvest")
			rain_material.set_shader_parameter("strength",clampf(1-remaining/70.0,0,1))
			host.world_root.modulate=Color.WHITE.lerp(Color(.80,.88,.94),clampf(1-remaining/70.0,0,1))
			for id in ([1] if solo else [1,2]):
				if bool(packets[id].action) and host.player_modes[id]=="foot":
					if positions[id].distance_to(APIARY)<7 and not covered:
						cover_progress+=delta
						if cover_progress>=(3 if improvements.shelter else 6):covered=true;_credit(id,"cover")
					if positions[id].distance_to(INTAKE)<7 and not sealed:
						seal_progress+=delta
						if seal_progress>=4:sealed=true;_credit(id,"seal")
					if positions[id].distance_to(PACK)<7 and not crates_ready:
						crate_progress+=delta
						if crate_progress>=4:crates_ready=true;_credit(id,"crates")
			_update_weather_guidance()
			if (stock==2 and covered) or remaining<=0:
				outcomes.weather=stock==2 and covered
				if stock==0: host.world_root.crop_field.set_stage(7)
				# A modest salvage load keeps failure recoverable, never a softlock.
				_result_then("planning_machine","HARVEST PROTECTED" if outcomes.weather else "RAIN RECOVERY","%s Next: read the buyer's order and deliver together." % ("Dry grain and covered apples are ready." if outcomes.weather else "Two salvage apple loads keep delivery possible; recovery earns a smaller bonus."))
		"dispatch":
			var together:=loaded==2 and (checked or solo)
			for id in ([1] if solo else [1,2]): together=together and positions[id].distance_to(DISPATCH)<7 and bool(packets[id].action)
			if together: load_progress+=delta
			var load_time:float=(6 if outcomes.get("repair",false) else 10)-(2 if crates_ready else 0)
			waypoint.position=host._logical_to_pixel(DISPATCH if loaded==2 else PACK)+Vector2(-45,-115)
			waypoint.text="MEET AT VAN" if loaded==2 else "PACK CARRIED LOAD" if cargo[1]!="" or cargo[2]!="" else "READ BUYER CLUE";waypoint.show()
			present("SUNDAY · FINAL DISPATCH","Ask which goods the buyer wants. Barley: grain intake; apples: apiary. ACTION collects and packs. Hold together at the van.","PACKED %d/2 · LOAD %d%%" % [loaded,mini(100,int(load_progress/load_time*100))],"Loading takes %ds · %s" % [int(load_time),"buyer checked" if checked or solo else "ACTION at dispatch to inspect buyer"])
			if load_progress>=load_time or remaining<=0: outcomes.dispatch=load_progress>=load_time;_enter("results",0)

func _update_weather_guidance(force_phone := false) -> void:
	var crop=host.world_root.crop_field
	var stage:int=int(crop.stage)
	var objective:=""
	var task_label:="BARLEY FIELD"
	var target:=Vector2(52,-38)
	var progress:String=crop.current_stage_name()
	match stage:
		0:
			objective="Enter the tractor and cultivate all 16 gold plot markers. Worked plots change colour behind you."
			progress="CULTIVATE %d/16" % crop.worked_cells.size()
		1:
			objective="Sowing tool engaged. Drive through all gold plot markers to sow barley." if crop.operation_ready else "Soil is ready. Tap ENGAGE FIELD TOOL on your phone, then drive through the gold markers to sow."
			progress="SOW %d/16" % crop.worked_cells.size()
		2,3,4:
			var growth_left:float=(10.0 if stage==2 else 12.0 if stage==3 else 15.0)-crop.growth_clock
			objective="Barley is growing. Park and EXIT to help seal intake or cover apples; return when the crop is golden."
			progress="%s · next growth in %ds" % [crop.current_stage_name(),ceili(maxf(0,growth_left))]
		5:
			objective="Harvest tool engaged. Drive through all gold plot markers to harvest barley." if crop.operation_ready else "Barley is ripe. ENGAGE FIELD TOOL on your phone, then harvest the 16 marked plots."
			progress="HARVEST %d/16" % crop.worked_cells.size()
		6:
			objective="Harvest complete. Return to grain intake and EXIT. Seal it (hold ACTION 4s), then tap ACTION to store two loads." if not sealed else "Harvest complete. Drive to the sealed grain intake, EXIT, then ACTION stores two dry loads."
			target=INTAKE;task_label="STORE HARVEST";progress="HARVEST COMPLETE"
		_:
			objective="The harvest window is closed. Reserve apples keep the farm going."
	if stock==2:
		target=APIARY;task_label="COVER APPLES"
		objective="Grain is safely stored. Hold ACTION at the apiary to protect reserve apples before rain."
		progress="APPLE COVER %d%%" % mini(100,int(cover_progress/(3 if improvements.shelter else 6)*100))
	waypoint.position=host._logical_to_pixel(target)+Vector2(-45,-115)
	waypoint.text=task_label;waypoint.show()
	present("SATURDAY · BEAT THE RAIN",objective,progress,"SEAL %d%% · COVER %d%% · CRATES %d%% · GRAIN %d/2" % [mini(100,int(seal_progress/4*100)),mini(100,int(cover_progress/(3 if improvements.shelter else 6)*100)),mini(100,int(crate_progress/4*100)),stock])
	var next_key:="%d:%d:%s:%s:%s:%s" % [stage,stock,str(covered),str(sealed),str(crates_ready),str(crop.operation_ready)]
	if force_phone or next_key!=weather_guidance_key:
		weather_guidance_key=next_key
		var detail:=objective
		detail+=" " + ("Also cover apples at apiary (hold ACTION 6s)." if solo and not covered else "Ask your partner about storage readiness." if not solo else "")
		host._on_incident_private_message(1,"FORECAST · BEAT THE RAIN: "+detail.strip_edges())
		if not solo:host._on_incident_private_message(2,"STORAGE JOBS: %s %s %s" % ["Intake sealed." if sealed else "Seal intake: hold ACTION 4s.","Apples covered." if covered else "Cover at apiary: hold ACTION 6s.","Crates ready: loading is faster." if crates_ready else "Prepare packing crates: hold ACTION 4s, then help store the harvest."])

func present(title: String, objective: String, progress: String, feedback: String) -> void:
	var ui=host.animal_incident
	ui.title_label.text=title;ui.objective_label.text=objective;ui.progress_label.text=progress;ui.feedback_label.text=feedback;ui.timer_label.text="%d:%02d" % [int(remaining)/60,int(remaining)%60]

func _update_replay_status() -> void:
	replay_status.text="PHONE READY %d/%d · host button also starts next seed" % [replay_votes.size(),1 if solo else 2]
	for id in ([1] if solo else [1,2]):
		host._on_incident_private_message(id,"WEEKEND COMPLETE: %s" % ("Ready for another weekend! Waiting for your partner. Tap again to cancel." if replay_votes.has(id) else "Your farm report is on screen. Tap Ready for another weekend on your phone; both farmers must agree." if not solo else "Your farm report is on screen. Tap Ready for another weekend to try a new seed."))

func _show_results() -> void:
	host.animal_incident.incident_panel.hide();waypoint.hide();results_panel.show();replay_button.grab_focus()
	for id in [1,2]:host._update_walk_animation(id,Vector2.ZERO)
	var perfect:bool=outcomes.get("sheep",0)==5 and outcomes.get("repair",false) and outcomes.get("weather",false) and outcomes.get("dispatch",false)
	var grade := "A flourishing weekend — together!" if perfect else "Delivery saved — the farm carries on!" if outcomes.get("dispatch",false) else "A tough weekend — try a new plan"
	var bonus:int=int(outcomes.get("sheep",0))*2+(10 if outcomes.get("repair",false) else 0)+(20 if outcomes.get("weather",false) else 0)
	money+=(80 if outcomes.get("dispatch",false) else 20)+bonus
	var recognition:String="You completed %d farm tasks · helper assisted" % contributions[1] if solo else "Farm tasks: Grower %d · Mechanic %d" % [contributions[1],contributions[2]]
	summary.text="WEEKEND COMPLETE\n%s\n\nSheep safe: %d / 5\nEquipment: %s\nHarvest: %s\nDelivery: %s\n\n%s\nCare bonus £%d · Balance £%d\nSeed %d · %d:%02d elapsed" % [grade,outcomes.get("sheep",0),"repaired" if outcomes.get("repair",false) else "manual loading used","stored dry" if stock>0 else "salvage apples used","on time" if outcomes.get("dispatch",false) else "buyer delayed",recognition,bonus,money,seed_value,int(elapsed)/60,int(elapsed)%60]
	var file=FileAccess.open("user://last_weekend.json",FileAccess.WRITE)
	if file: file.store_string(JSON.stringify({"seed":seed_value,"outcomes":outcomes,"contributions":contributions,"seconds":elapsed,"events":log_events}))
	replay_votes.clear()
	_update_replay_status()
	for id in [1,2]:
		var mode={"type":"mode","playerId":id,"title":"RESULTS","actionLabel":"READY","hint":"Choose another weekend on your phone"}
		host.latest_modes[id]=mode
		host._send(mode)
