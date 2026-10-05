class_name CropField2D
extends Node2D

signal stage_changed(stage_name: String)

enum Stage { UNPREPARED, PREPARED, SEEDED, SEEDLING, YOUNG, MATURE, HARVESTED, DAMAGED }

const STAGE_NAMES := ["UNPREPARED", "PREPARED", "SEEDED", "SEEDLINGS", "YOUNG CROP", "MATURE", "HARVESTED", "DAMAGED"]
const WORK_CELLS_REQUIRED := 16
const TERRAIN_UNPREPARED := preload("res://assets/2d/production/terrain_unprepared_soil.png")
const TERRAIN_FURROWS := preload("res://assets/2d/production/terrain_furrow_soil.png")
const CROP_SEEDED := preload("res://assets/2d/production/crop_seeded_row.png")
const CROP_SEEDLING := preload("res://assets/2d/production/crop_seedling_cluster.png")
const CROP_YOUNG := preload("res://assets/2d/production/crop_young_cluster.png")
const CROP_MATURE := preload("res://assets/2d/production/crop_mature_cluster.png")
const CROP_DAMAGED := preload("res://assets/2d/production/crop_damaged_cluster.png")
const CROP_STUBBLE := preload("res://assets/2d/production/crop_stubble_cluster.png")
const CROP_HEADLAND := preload("res://assets/2d/production/crop_headland_cluster.png")
const TERRAIN_UV_SCALE := 2.55

var field_polygon := PackedVector2Array()
var field_bounds := Rect2()
var stage: Stage = Stage.UNPREPARED
var growth_clock := 0.0
var worked_cells: Dictionary = {}
var surface: Polygon2D
var crop_art: Node2D
var reserved_routes: Array[Dictionary] = []
var operation_ready := true
var work_plots: Array[Vector2] = []

func engage_operation() -> void:
	if stage in [Stage.PREPARED,Stage.MATURE]:operation_ready=true;queue_redraw()

func setup(points: PackedVector2Array) -> void:
	field_polygon = points
	field_bounds = _bounds_for(points)
	# Authored work plots span the productive area, away from the headland.
	for y in [-50,-42,-34,-26]:
		for x in [31,45,59,73]:work_plots.append(Vector2(850,600)+Vector2(x,y)*10)
	z_index = -19
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	surface = Polygon2D.new()
	surface.name = "FieldSurface"
	var edge_material := ShaderMaterial.new(); edge_material.shader = load("res://shaders/crop_surface.gdshader")
	var padded_points := PackedVector2Array(points)
	while padded_points.size() < 16: padded_points.append(Vector2.ZERO)
	edge_material.set_shader_parameter("edge_points",padded_points)
	edge_material.set_shader_parameter("point_count",points.size())
	surface.material = edge_material
	surface.polygon = points
	surface.uv = _scaled_uv(points, TERRAIN_UV_SCALE)
	surface.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	surface.z_index = -2
	add_child(surface)
	crop_art = Node2D.new()
	crop_art.name = "AuthoredCropClusters"
	# The world root is y-sorted; make the crop layer's global depth explicit so
	# field art stays above soil polygons and below actors/vehicles.
	crop_art.z_as_relative = false
	crop_art.z_index = -20
	add_child(crop_art)
	_update_surface()
	_rebuild_crop_art()
	queue_redraw()

func _process(delta: float) -> void:
	if stage not in [Stage.SEEDED, Stage.SEEDLING, Stage.YOUNG]: return
	growth_clock += delta
	var threshold := 10.0 if stage == Stage.SEEDED else (12.0 if stage == Stage.SEEDLING else 15.0)
	if growth_clock >= threshold:
		growth_clock = 0.0
		set_stage(stage + 1)

func contains_world_point(world_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(world_point, field_polygon)

func apply_tractor_work(world_point: Vector2) -> bool:
	if not contains_world_point(world_point): return false
	if _on_reserved_route(world_point, 0.0): return false
	if stage not in [Stage.UNPREPARED, Stage.PREPARED, Stage.MATURE]: return false
	if not operation_ready:return false
	var cell:=-1;var nearest:=INF
	for index in range(work_plots.size()):
		var distance:float=world_point.distance_to(work_plots[index])
		if distance<nearest:nearest=distance;cell=index
	if nearest>42 or worked_cells.has(cell):return false
	worked_cells[cell] = work_plots[cell]
	if stage==Stage.MATURE:
		for sprite in crop_art.get_children():
			if Rect2(work_plots[cell]-Vector2(70,40),Vector2(140,80)).has_point(sprite.position):sprite.hide()
	queue_redraw()
	if worked_cells.size() >= WORK_CELLS_REQUIRED:
		worked_cells.clear()
		match stage:
			Stage.UNPREPARED: set_stage(Stage.PREPARED)
			Stage.PREPARED: set_stage(Stage.SEEDED)
			Stage.MATURE: set_stage(Stage.HARVESTED)
	return true

func cycle_stage() -> void:
	set_stage((int(stage) + 1) % STAGE_NAMES.size())

func set_stage(next_stage: Stage) -> void:
	stage = next_stage
	growth_clock = 0.0
	worked_cells.clear()
	operation_ready=stage==Stage.UNPREPARED
	_update_surface()
	_rebuild_crop_art()
	queue_redraw()
	stage_changed.emit(STAGE_NAMES[int(stage)])

func current_stage_name() -> String:
	return STAGE_NAMES[int(stage)]

func _draw() -> void:
	if field_polygon.is_empty(): return
	pass # The soil material feathers into the surrounding grass instead of a bright polygon outline.
	_draw_field_detail()
	# Contiguous textured work cells, clipped to the field rather than paint circles.
	for point in worked_cells.values():
		var tile := PackedVector2Array([point+Vector2(-70,-40),point+Vector2(70,-40),point+Vector2(70,40),point+Vector2(-70,40)])
		for clipped in Geometry2D.intersect_polygons(tile,field_polygon):
			var uv := PackedVector2Array()
			for vertex in clipped: uv.append(vertex*TERRAIN_UV_SCALE/Vector2(TERRAIN_FURROWS.get_size()))
			var tint := Color(.74,.67,.55) if stage == Stage.UNPREPARED else Color(.64,.57,.46)
			draw_polygon(clipped,PackedColorArray([tint]),uv,TERRAIN_FURROWS)
	if stage in [Stage.UNPREPARED,Stage.PREPARED,Stage.MATURE]:
		for index in range(work_plots.size()):
			if worked_cells.has(index):continue
			var point:Vector2=work_plots[index]
			draw_circle(point,7,Color(1,.9,.6,.85),false,2)
			draw_line(point+Vector2(-14,0),point+Vector2(14,0),Color(1,.9,.6,.7),2)

func _update_surface() -> void:
	if surface == null: return
	surface.texture = TERRAIN_UNPREPARED if stage in [Stage.UNPREPARED, Stage.DAMAGED] else TERRAIN_FURROWS
	var tints := [
		Color(0.92,0.88,0.82), Color(0.92,0.88,0.82), Color(0.88,0.84,0.75), Color(0.74,0.80,0.60),
		Color(0.57,0.70,0.42), Color(0.78,0.66,0.34), Color(0.91,0.77,0.53), Color(0.64,0.51,0.43)
	]
	surface.color = tints[int(stage)]

func _draw_field_detail() -> void:
	var min_x := int(field_bounds.position.x)
	var max_x := int(field_bounds.end.x)
	var min_y := int(field_bounds.position.y)
	var max_y := int(field_bounds.end.y)
	# Headlands stay open around the field edge and two paired tramlines remain
	# readable for later spraying/fertilising jobs.
	if stage in [Stage.SEEDLING, Stage.YOUNG, Stage.MATURE, Stage.DAMAGED]:
		for x in [field_bounds.position.x + 176.0, field_bounds.position.x + 204.0, field_bounds.position.x + 396.0, field_bounds.position.x + 424.0]:
			for y in range(min_y + 14, max_y - 14, 20):
				var tram_point := Vector2(x, y)
				if Geometry2D.is_point_in_polygon(tram_point, field_polygon):
					draw_line(tram_point + Vector2(0,-11), tram_point + Vector2(0,11), Color(0.28,0.24,0.12,0.26), 7.0)
	for y in range(min_y + 18, max_y, 34):
		for x in range(min_x + 14, max_x, 25):
			var base := Vector2(x, y)
			var jitter := Vector2((_noise(base) - 0.5) * 12.0, (_noise(base + Vector2(91,37)) - 0.5) * 10.0)
			var point := base + jitter
			if not Geometry2D.is_point_in_polygon(point, field_polygon): continue
			match stage:
				Stage.UNPREPARED:
					if _noise(point) > 0.52: draw_line(point + Vector2(-4,1), point + Vector2(5,-2), Color("#805e42"), 2.2)
				Stage.PREPARED:
					if int((point.y - field_bounds.position.y) / 25.0) % 2 == 0: draw_line(point + Vector2(-10,0), point + Vector2(10,0), Color(0.24,0.17,0.13,0.34), 1.4)
				Stage.SEEDED:
					draw_circle(point, 1.4, Color(0.20,0.14,0.11,0.38))
				Stage.HARVESTED:
					draw_line(point + Vector2(-5,1), point + Vector2(6,-2), Color("#b78b4e"), 1.7)

func _rebuild_crop_art() -> void:
	if crop_art == null: return
	for child in crop_art.get_children(): child.queue_free()
	if stage in [Stage.UNPREPARED, Stage.PREPARED]: return
	var texture: Texture2D = CROP_SEEDED
	var target_width := 34.0
	var spacing := Vector2(52, 48)
	match stage:
		Stage.SEEDLING: texture = CROP_SEEDLING; target_width = 31.0; spacing = Vector2(43, 44)
		Stage.YOUNG: texture = CROP_YOUNG; target_width = 27.0; spacing = Vector2(28, 29)
		Stage.MATURE: texture = CROP_MATURE; target_width = 36.0; spacing = Vector2(18, 14)
		Stage.HARVESTED: texture = CROP_STUBBLE; target_width = 39.0; spacing = Vector2(47, 45)
		Stage.DAMAGED: texture = CROP_DAMAGED; target_width = 54.0; spacing = Vector2(59, 52)
	var min_x := int(field_bounds.position.x + 28.0)
	var max_x := int(field_bounds.end.x - 28.0)
	var min_y := int(field_bounds.position.y + 26.0)
	var max_y := int(field_bounds.end.y - 24.0)
	for y in range(min_y, max_y, int(spacing.y)):
		for x in range(min_x, max_x, int(spacing.x)):
			var seed := Vector2(x, y)
			var point := seed + Vector2((_noise(seed) - 0.5) * 15.0, (_noise(seed + Vector2(91,37)) - 0.5) * 10.0)
			if not _point_has_field_margin(point, 18.0): continue
			if _is_tramline(point.x): continue
			if stage != Stage.MATURE and _noise(point + Vector2(311,73)) < 0.12: continue
			var sprite := Sprite2D.new()
			sprite.texture = texture
			var scale_value := target_width / sprite.texture.get_width()
			sprite.scale = Vector2(scale_value, scale_value)
			sprite.position = point + Vector2(0, -sprite.texture.get_height() * scale_value * 0.28)
			sprite.modulate = Color(0.94 + _noise(point) * 0.06, 0.94 + _noise(point + Vector2(3,8)) * 0.06, 0.94, 1.0)
			crop_art.add_child(sprite)

func _is_tramline(x: float) -> bool:
	var local_x := x - field_bounds.position.x
	return absf(local_x - 176.0) < 15.0 or absf(local_x - 204.0) < 15.0 or absf(local_x - 396.0) < 15.0 or absf(local_x - 424.0) < 15.0

func _point_has_field_margin(point: Vector2, margin: float) -> bool:
	if _on_reserved_route(point, margin + 10.0): return false
	for offset in [Vector2.ZERO, Vector2(margin,0), Vector2(-margin,0), Vector2(0,margin), Vector2(0,-margin)]:
		if not Geometry2D.is_point_in_polygon(point + offset, field_polygon): return false
	return true

func _on_reserved_route(point: Vector2, margin: float) -> bool:
	for route in reserved_routes:
		var points: PackedVector2Array = route.points
		for index in range(points.size()-1):
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point,points[index],points[index+1])) < float(route.radius) + margin: return true
	return false

func _noise(point: Vector2) -> float:
	return fposmod(sin(point.x * 12.9898 + point.y * 78.233) * 43758.5453, 1.0)

func _bounds_for(points: PackedVector2Array) -> Rect2:
	var minimum := points[0]
	var maximum := points[0]
	for point in points:
		minimum.x = minf(minimum.x, point.x); minimum.y = minf(minimum.y, point.y)
		maximum.x = maxf(maximum.x, point.x); maximum.y = maxf(maximum.y, point.y)
	return Rect2(minimum, maximum - minimum)

func _scaled_uv(points: PackedVector2Array, scale_value: float) -> PackedVector2Array:
	var result := PackedVector2Array()
	for point in points: result.append(point * scale_value)
	return result
