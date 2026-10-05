extends Control
# A schematic of authored layout data, never a second World2D render.
# Only public destinations appear; this UI does not read private facts/orders.
var host: Node
var chart:=Rect2()
var placement_ready:=false
var elapsed:=0.0
const PLAYER_COLOURS:=[Color("#e76b56"),Color("#64d0e5")]
func setup(owner_host:Node)->void:
	host=owner_host;mouse_filter=Control.MOUSE_FILTER_IGNORE
	set_process(true)
func _process(delta:float)->void:
	if host==null or host.weekend==null:return
	var s=host.weekend
	visible=host.admitted_players>0 and s.phase not in ["waiting","results"] and not host.lobby_panel.visible
	if not visible:return
	elapsed+=delta
	var screen:=get_viewport_rect().size
	var width:=clampf(screen.x*.175,180,224)
	size=Vector2(width,29+(width-24)*120.0/170+30)
	chart=Rect2(Vector2(12,29),Vector2(width-24,(width-24)*120.0/170))
	var target:=Vector2((screen.x-size.x)*.5 if host.split_screen else screen.x-size.x-20,screen.y-size.y-18)
	target.x=maxf(8,target.x);target.y=maxf(8,target.y)
	position=position.lerp(target,1-exp(-delta*12)) if placement_ready else target
	placement_ready=true
	queue_redraw()
func project(point:Vector2)->Vector2:
	return chart.position+(point+Vector2(85,60))/Vector2(170,120)*chart.size
func public_targets()->Array[Vector2]:
	var result:Array[Vector2]=[]
	if host==null or host.weekend==null:return result
	var s=host.weekend
	if s.next_phase!="":return result
	match s.phase:
		"arrival":result.append(s.HAY)
		"sheep":result.append(host.animal_incident.GATE)
		"planning_gate":result.assign([s.HAY,host.repair_incident.BAY])
		"repair":result.append(host.repair_incident.BAY)
		"planning_machine":result.assign([s.PACK,s.DISPATCH])
		"weather":
			if host.world_root.crop_field.stage<6:result.append(Vector2(52,-38))
			if s.stock<2:result.append(s.INTAKE)
			if not s.covered:result.append(s.APIARY)
		"dispatch":result.append(s.DISPATCH if s.loaded==2 else s.PACK)
	return result
func _draw()->void:
	if host==null or chart.size.x==0:return
	var style:=StyleBoxFlat.new();style.bg_color=Color("#182f26");style.border_color=Color("#d6bb7d");style.set_border_width_all(2);style.set_corner_radius_all(12);style.shadow_color=Color(0,0,0,.3);style.shadow_size=5
	draw_style_box(style,Rect2(Vector2.ZERO,size))
	var font:=ThemeDB.fallback_font
	draw_string(font,Vector2(12,21),"FARM MAP",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("#ffe8aa"))
	draw_rect(chart,Color("#78905d"))
	var layout:Dictionary=host.world_root.layout
	for district in layout.districts:
		var points:=PackedVector2Array()
		for point in district.points:points.append(project(Vector2(point[0],point[1])))
		var colour:Color=Color("#b6ab6e") if district.kind=="crop" else Color("#c9af7c") if district.kind=="yard" else Color("#647e46") if district.kind=="orchard" else Color("#99a570")
		draw_colored_polygon(points,colour)
		points.append(points[0]);draw_polyline(points,Color("#50643e"),1,true)
	for road in layout.roads:
		var points:=PackedVector2Array()
		for point in road.points:points.append(project(Vector2(clampf(point[0],-84,84),clampf(point[1],-59,59))))
		draw_polyline(points,Color("#d6bd88"),maxf(1.5,float(road.width)/170*chart.size.x),true)
	var river:=PackedVector2Array()
	for p in [Vector2(-84,46),Vector2(-62,43),Vector2(-42,47),Vector2(-20,55),Vector2(6,59)]:river.append(project(p))
	draw_polyline(river,Color("#719eaa"),5,true)
	for building in layout.structures:
		var centre:=project(Vector2(building.x,building.z))
		var footprint:=Vector2(building.width,building.depth)/Vector2(170,120)*chart.size
		draw_rect(Rect2(centre-footprint*.5,footprint),Color("#665d50"))
	for label in [["PASTURE",Vector2(-60,-38)],["FIELD",Vector2(53,-38)],["YARD",Vector2(0,10)]]:
		draw_string(font,project(label[1])+Vector2(-20,0),label[0],HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("#253b2d"))
	for point in public_targets():
		var target:=project(point)
		draw_circle(target,6+sin(elapsed*3)*.6,Color("#1b3326"))
		draw_line(target-Vector2(4,0),target+Vector2(4,0),Color("#ffe39b"),2,true)
		draw_line(target-Vector2(0,4),target+Vector2(0,4),Color("#ffe39b"),2,true)
	for id in [1,2]:
		if id==2 and host.weekend.solo:continue
		var point:=project(host.logical_positions[id])
		if id==1:
			draw_circle(point,6,Color("#19362a"));draw_circle(point,4.5,PLAYER_COLOURS[0])
		else:
			var diamond:=PackedVector2Array([point+Vector2(0,-6),point+Vector2(6,0),point+Vector2(0,6),point+Vector2(-6,0)])
			draw_colored_polygon(diamond,PLAYER_COLOURS[1]);diamond.append(diamond[0]);draw_polyline(diamond,Color("#19362a"),1.5,true)
		draw_string(font,point+Vector2(-3,3),str(id),HORIZONTAL_ALIGNMENT_LEFT,-1,9,Color("#152b22"))
	var base:=size.y-11
	draw_circle(Vector2(16,base-4),3.5,PLAYER_COLOURS[0]);draw_string(font,Vector2(24,base),"1",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#f4e5ba"))
	if not host.weekend.solo:
		draw_colored_polygon(PackedVector2Array([Vector2(53,base-9),Vector2(57,base-5),Vector2(53,base-1),Vector2(49,base-5)]),PLAYER_COLOURS[1]);draw_string(font,Vector2(61,base),"2",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#f4e5ba"))
	draw_string(font,Vector2(90,base),"+  TASK",HORIZONTAL_ALIGNMENT_LEFT,-1,11,Color("#ffe39b"))
