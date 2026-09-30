extends Node3D

const LAYOUT_PATH := "res://data/world_layout.json"
const TRACTOR_SCENE := preload("res://scenes/vehicles/tractor.tscn")
const STONE_BARN_SCENE := preload("res://scenes/buildings/stone_barn.tscn")
const MACHINERY_SHED_SCENE := preload("res://scenes/buildings/machinery_shed.tscn")
const GRAIN_STORE_SCENE := preload("res://scenes/buildings/grain_store.tscn")
const WORKSHOP_SCENE := preload("res://scenes/buildings/workshop.tscn")
const FEED_STORE_SCENE := preload("res://scenes/buildings/feed_store.tscn")
const SILO_SET := preload("res://assets/buildings/bracken_silo_set.glb")
const COMBINE := preload("res://assets/vehicles/bracken_combine.glb")
const GRAIN_TRAILER := preload("res://assets/vehicles/bracken_grain_trailer.glb")
const ENGLISH_OAK := preload("res://assets/environment/english_oak.glb")
const HEDGE_STRAIGHT := preload("res://assets/environment/boundary_kit/hawthorn_straight.glb")
const HEDGE_CURVE := preload("res://assets/environment/boundary_kit/hawthorn_curve.glb")
const HEDGE_CORNER := preload("res://assets/environment/boundary_kit/hawthorn_corner.glb")
const HEDGE_GATE := preload("res://assets/environment/boundary_kit/hawthorn_gate.glb")
const WALL_STRAIGHT := preload("res://assets/environment/boundary_kit/drystone_straight.glb")
const WALL_CORNER := preload("res://assets/environment/boundary_kit/drystone_corner.glb")
const WALL_GATE := preload("res://assets/environment/boundary_kit/drystone_gate.glb")
const OAK_COURTYARD_BASE := preload("res://assets/environment/boundary_kit/oak_courtyard_base.glb")
const BOUNDARY_MODULE_LENGTH := 8.0
const FIELD_GATE_GAPS := [
	{"id": "combine_gate", "position": Vector2(27.35, -8.88), "width": 10.0},
	{"id": "hay_gate", "position": Vector2(-25.0, 16.07), "width": 6.0},
]
var layout: Dictionary
var farm_environment: Environment
var farm_sky_material: ProceduralSkyMaterial
var farm_sun: DirectionalLight3D
var weather_mix := 0.0
var weather_target := 0.0
var crop_field: FieldStateSystem

func _ready() -> void:
	layout = JSON.parse_string(FileAccess.get_file_as_string(LAYOUT_PATH))
	_build_environment()
	_build_ground()
	_build_districts()
	_build_roads()
	_build_farmyard_surface()
	_build_structures()
	_build_gates()
	_build_props()
	_build_farmyard_dressing()

func _process(delta: float) -> void:
	weather_mix = move_toward(weather_mix, weather_target, delta * 0.28)
	if not farm_environment or not farm_sky_material or not farm_sun: return
	farm_sky_material.sky_top_color = Color("#6f9fb0").lerp(Color("#344750"), weather_mix)
	farm_sky_material.sky_horizon_color = Color("#d8d2ad").lerp(Color("#7f8d90"), weather_mix)
	farm_sky_material.ground_horizon_color = Color("#8fa17b").lerp(Color("#66736b"), weather_mix)
	farm_environment.ambient_light_color = Color("#b9cbd0").lerp(Color("#a8b6bd"), weather_mix)
	farm_environment.ambient_light_energy = lerpf(0.31, 0.44, weather_mix)
	farm_environment.fog_light_color = Color("#c4c7af").lerp(Color("#738087"), weather_mix)
	farm_environment.fog_light_energy = lerpf(0.42, 0.62, weather_mix)
	farm_environment.fog_density = lerpf(0.0018, 0.0065, weather_mix)
	farm_sun.light_color = Color("#ffe4b3").lerp(Color("#aebbc3"), weather_mix)
	farm_sun.light_energy = lerpf(0.78, 0.20, weather_mix)

func toggle_weather_preview() -> void:
	weather_target = 0.0 if weather_target > 0.5 else 1.0

func set_storm(enabled: bool) -> void:
	weather_target = 1.0 if enabled else 0.0

func cycle_crop_state() -> String:
	return crop_field.cycle_state() if crop_field else "unavailable"

func set_crop_state(state: String) -> void:
	if crop_field:
		crop_field.set_state(state)

func _build_environment() -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	farm_sky_material = ProceduralSkyMaterial.new()
	farm_sky_material.sky_top_color = Color("#6f9fb0")
	farm_sky_material.sky_horizon_color = Color("#d8d2ad")
	farm_sky_material.ground_horizon_color = Color("#8fa17b")
	farm_sky_material.ground_bottom_color = Color("#536448")
	farm_sky_material.sun_angle_max = 18.0
	var sky := Sky.new()
	sky.sky_material = farm_sky_material
	farm_environment = environment
	farm_environment.background_mode = Environment.BG_SKY
	farm_environment.sky = sky
	farm_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	farm_environment.ambient_light_color = Color("#b9cbd0")
	farm_environment.ambient_light_energy = 0.31
	farm_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	farm_environment.fog_enabled = true
	farm_environment.fog_light_color = Color("#c4c7af")
	farm_environment.fog_light_energy = 0.42
	farm_environment.fog_density = 0.0018
	farm_environment.fog_sky_affect = 0.42
	farm_environment.adjustment_enabled = true
	farm_environment.adjustment_brightness = 0.96
	farm_environment.adjustment_contrast = 1.08
	farm_environment.adjustment_saturation = 1.06
	world_environment.environment = farm_environment
	add_child(world_environment)
	farm_sun = DirectionalLight3D.new()
	farm_sun.rotation_degrees = Vector3(-58, -32, 0)
	farm_sun.light_color = Color("#ffe4b3")
	farm_sun.light_energy = 0.78
	farm_sun.shadow_enabled = true
	farm_sun.shadow_blur = 1.8
	farm_sun.directional_shadow_max_distance = 180
	add_child(farm_sun)

func _build_ground() -> void:
	_add_box("Ground", Vector3(0, -0.3, 0), Vector3(float(layout.bounds.width), 0.6, float(layout.bounds.depth)), Color("#799b61"))
	# Layered silhouettes imply rolling countryside beyond the playable boundary.
	_add_box("NorthBank", Vector3(0, -1.2, -69), Vector3(210, 2.2, 20), Color("#678a55"))
	_add_box("WestBank", Vector3(-96, -1.0, 0), Vector3(25, 1.6, 150), Color("#6f925b"))
	_add_box("EastBank", Vector3(96, -1.0, 0), Vector3(25, 1.6, 150), Color("#6f925b"))
	for i in range(18):
		var edge_x := -88.0 + float(i) * 10.5
		_add_tree(Vector3(edge_x, 0, -63 + sin(float(i) * 1.7) * 3.0), 0.8 + float(i % 3) * 0.12)

func _build_districts() -> void:
	var hedge_edges := {}
	for district in layout.districts:
		var points: Array = district.get("points", [])
		var kind := str(district.kind)
		var height := 0.04 if kind in ["yard", "loading", "delivery"] else 0.025
		_add_polygon(str(district.id), points, height, _district_color(kind), kind)
		if kind in ["hay", "pasture", "crop", "orchard", "meadow"]:
			_record_hedge_edges(points, hedge_edges)
	for edge in hedge_edges.values():
		if _is_west_yard_stone_boundary(edge[0], edge[1]):
			_add_wall_segment(edge[0], edge[1], "WestYardBoundary")
		else:
			_add_hedge_segment(edge[0], edge[1], "FieldBoundary")
	_build_crop_rows()
	_build_orchard()
	_build_meadow_detail()

func _build_roads() -> void:
	for road in layout.roads:
		var points: Array = road.points
		var color := Color("#c7a875")
		if road.kind == "heavy": color = Color("#b69569")
		if road.kind == "foot": color = Color("#a98a5e")
		for index in range(points.size() - 1):
			_add_road_segment(str(road.id), Vector2(float(points[index][0]), float(points[index][1])), Vector2(float(points[index + 1][0]), float(points[index + 1][1])), float(road.width), color)
		for point in points:
			_add_disc(Vector3(float(point[0]), 0.095, float(point[1])), float(road.width) * 0.49, color)

func _build_farmyard_surface() -> void:
	# Irregular compacted earth and gravel layers keep the courtyard from reading as one flat polygon.
	var patches := [
		[Vector3(-13, 0.155, 7), Vector2(8.8, 4.2), -12.0, Color("#9b7950")],
		[Vector3(2, 0.158, 10), Vector2(10.5, 5.0), 8.0, Color("#ae8a59")],
		[Vector3(10, 0.161, -1), Vector2(7.2, 4.5), -18.0, Color("#8e6b48")],
		[Vector3(-5, 0.164, -1), Vector2(6.5, 3.5), 22.0, Color("#b49261")],
	]
	for patch in patches:
		var disc := _add_disc(patch[0], 1.0, patch[3])
		disc.scale = Vector3(patch[1].x, 1.0, patch[1].y)
		disc.rotation_degrees.y = patch[2]
	# Paired wheel ruts curve from the western apron through the centre of the yard.
	var route := [Vector2(-24, 12), Vector2(-15, 9), Vector2(-5, 8), Vector2(5, 10), Vector2(15, 15), Vector2(23, 18)]
	for index in range(route.size() - 1):
		var route_start: Vector2 = route[index]
		var route_end: Vector2 = route[index + 1]
		var direction: Vector2 = (route_end - route_start).normalized()
		var normal := Vector2(-direction.y, direction.x) * 1.22
		for side in [-1.0, 1.0]:
			_add_road_segment("TyreRut", route_start + normal * side, route_end + normal * side, 0.34, Color("#6c5138"))
	# Shallow reflective puddles collect in the low points without blocking movement.
	for puddle_data in [[Vector3(-9,0.205,12),Vector2(2.8,1.15),-8.0],[Vector3(8,0.207,4),Vector2(1.9,.8),18.0],[Vector3(17,0.209,15),Vector2(2.2,.75),-24.0]]:
		var puddle := _add_disc(puddle_data[0], 1.0, Color("#486e73"))
		puddle.scale = Vector3(puddle_data[1].x, 0.32, puddle_data[1].y)
		puddle.rotation_degrees.y = puddle_data[2]
	# Scattered pale stones create gravel texture at normal gameplay distance.
	for index in range(42):
		var angle := float(index) * 2.39996
		var radius := 3.0 + float((index * 7) % 19)
		var point := Vector3(cos(angle) * radius, 0.23, 6.0 + sin(angle) * radius * 0.72)
		if point.distance_to(Vector3(8,0,11)) < 3.5: continue
		var gravel := _add_disc(point, 0.09 + float(index % 3) * 0.035, Color("#d0b783") if index % 2 == 0 else Color("#796a50"))
		gravel.scale.z = 0.55

func _build_structures() -> void:
	for structure in layout.structures:
		var kind := str(structure.kind)
		if kind in ["silo", "intake", "canopy"]:
			continue
		elif kind == "workshop":
			var workshop := WORKSHOP_SCENE.instantiate()
			workshop.name = "BrackenWorkshop"
			workshop.position = Vector3(float(structure.x), 0, float(structure.z))
			workshop.rotation_degrees.y = float(structure.get("rotation", 0))
			add_child(workshop)
		elif kind == "barn":
			var barn := STONE_BARN_SCENE.instantiate()
			barn.name = "BrackenStoneBarn"
			barn.position = Vector3(float(structure.x), 0, float(structure.z))
			barn.rotation_degrees.y = float(structure.get("rotation", 0))
			barn.scale = Vector3(1.12, 1.0, 1.12)
			add_child(barn)
		elif kind == "shed" and str(structure.id) == "machine_shed":
			var machinery_shed := MACHINERY_SHED_SCENE.instantiate()
			machinery_shed.name = "BrackenMachineryShed"
			machinery_shed.position = Vector3(float(structure.x), 0, float(structure.z))
			machinery_shed.rotation_degrees.y = float(structure.get("rotation", 0))
			add_child(machinery_shed)
		elif kind == "shed" and str(structure.id) == "feed":
			var feed_store := FEED_STORE_SCENE.instantiate()
			feed_store.name = "BrackenFeedStore"
			feed_store.position = Vector3(float(structure.x), 0, float(structure.z))
			feed_store.rotation_degrees.y = float(structure.get("rotation", 0))
			add_child(feed_store)
		else:
			_add_building(structure)
	# The complete grain chain sits on the southern loading yard. The intake is
	# aligned with the delivery route so a tractor and trailer can drive through.
	var grain_store := GRAIN_STORE_SCENE.instantiate()
	grain_store.name = "BrackenGrainStore"
	grain_store.position = Vector3(15, 0.14, 37)
	add_child(grain_store)
	var silos := SILO_SET.instantiate()
	silos.name = "BrackenConnectedSilos"
	silos.position = Vector3(33, 0.14, 35)
	add_child(silos)

func _add_building(data: Dictionary) -> void:
	var root := Node3D.new()
	root.name = str(data.id)
	root.position = Vector3(float(data.x), 0, float(data.z))
	root.rotation_degrees.y = float(data.get("rotation", 0))
	add_child(root)
	var width := float(data.width)
	var depth := float(data.depth)
	var height := float(data.height)
	var wall_color := _structure_color(str(data.kind))
	var walls := _add_box("Walls", Vector3(0, height * 0.5, 0), Vector3(width, height, depth), wall_color, true, root)
	var roof_color := Color("#874d3d") if str(data.kind) != "canopy" else Color("#50685e")
	var pitch := 24.0
	var slope_length := (width * 0.5) / cos(deg_to_rad(pitch))
	for side in [-1, 1]:
		var panel := _add_box("Roof", Vector3(float(side) * width * 0.245, height + width * 0.105, 0), Vector3(slope_length + 0.5, 0.45, depth + 1.1), roof_color, false, root)
		panel.rotation_degrees.z = float(side) * pitch
	_add_box("Door", Vector3(0, height * 0.37, -depth * 0.505), Vector3(minf(4.2, width * 0.38), height * 0.72, 0.18), Color("#4c392a"), false, root)
	for side in [-1, 1]:
		_add_box("Window", Vector3(float(side) * width * 0.31, height * 0.56, -depth * 0.512), Vector3(1.7, 1.45, 0.2), Color("#a9d8d6"), false, root)
		_add_box("WindowTrim", Vector3(float(side) * width * 0.31, height * 0.56, -depth * 0.526), Vector3(2.0, 1.72, 0.08), Color("#f3e4c5"), false, root)

func _build_gates() -> void:
	# This ordinary gate is projected onto the real road/wall crossing rather than the old rough marker.
	var hay_gate := _add_open_gate(WALL_GATE, "hay_gate", Vector3(-25.0, 0.08, 16.07), -90.0)
	hay_gate.scale.x = 6.0 / 4.4
	# The combine crossing remains a clear ten-metre opening until its distinct wide gate is authored.

func _add_open_gate(asset: PackedScene, gate_name: String, position: Vector3, rotation_y: float) -> Node3D:
	var instance := _add_authored_environment(asset, gate_name, position, rotation_y, 1.0)
	var gate_pivot := instance.find_child("GatePivot", true, false) as Node3D
	if gate_pivot: gate_pivot.rotation_degrees.y = -72.0
	return instance

func _build_props() -> void:
	var combine := COMBINE.instantiate()
	combine.name = "BrackenCombine"
	combine.position = Vector3(37, 0.15, -15)
	combine.rotation_degrees.y = -18
	add_child(combine)
	var tractor := TRACTOR_SCENE.instantiate()
	tractor.name = "BrackenTractor"
	tractor.position = Vector3(-5, 0, 12)
	tractor.rotation_degrees.y = -18
	add_child(tractor)
	var trailer := GRAIN_TRAILER.instantiate()
	trailer.name = "BrackenGrainTrailer"
	trailer.position = Vector3(10, 0.15, 15)
	trailer.rotation_degrees.y = -12
	add_child(trailer)
	_add_van(Vector3(59, 0, 44))
	for index in range(7):
		var x := -42.0 + float(index % 4) * 6.5
		var z := -39.0 + float(index / 4) * 7.0
		_add_sheep(Vector3(x + sin(index * 2.1), 0, z))
	for index in range(6):
		_add_hive(Vector3(61 + float(index % 3) * 2.4, 0, 13 + float(index / 3) * 2.8))
	# A curving blue stream and stone bridge anchor the western edge.
	var stream_points := [Vector2(-84, 52), Vector2(-74, 39), Vector2(-69, 24), Vector2(-72, 8), Vector2(-80, -5)]
	for index in range(stream_points.size() - 1):
		_add_road_segment("Stream", stream_points[index], stream_points[index + 1], 7.0, Color("#62abc0"))
		_add_disc(Vector3(stream_points[index].x, 0.08, stream_points[index].y), 3.45, Color("#62abc0"))
	var bridge := _add_box("StoneBridge", Vector3(-71, 0.3, 31), Vector3(9, 0.5, 7), Color("#9c9482"))
	bridge.rotation_degrees.y = -17

func _build_farmyard_dressing() -> void:
	_add_authored_environment(OAK_COURTYARD_BASE, "CourtyardOakBase", Vector3(8, 0.18, 11), 0.0, 0.90)
	_add_authored_environment(ENGLISH_OAK, "CourtyardOak", Vector3(8, 0.22, 11), 0.0, 0.82)
	# The curving orchard entrance demonstrates a softer authored transition beside the path.
	_add_authored_environment(HEDGE_CURVE, "OrchardEntranceHedge", Vector3(28, 0.08, 20), -9.0, 1.0)
	# Verge vegetation clusters around walls and buildings instead of being scattered uniformly.
	for index in range(30):
		var x := -17.0 + float((index * 11) % 40)
		var z := -17.0 + float((index * 17) % 38)
		if Vector2(x, z).distance_to(Vector2(0, 5)) < 9.0: continue
		_add_grass_tuft(Vector3(x, 0.30, z))
		if index % 4 == 0: _add_flower_patch(Vector3(x + 0.35, 0.26, z - 0.2), index)

func _add_authored_environment(asset: PackedScene, node_name: String, position: Vector3, rotation_y: float, scale_factor: float) -> Node3D:
	var instance := asset.instantiate()
	instance.name = node_name
	instance.position = position
	instance.rotation_degrees.y = rotation_y
	instance.scale = Vector3.ONE * scale_factor
	add_child(instance)
	return instance

func _build_crop_rows() -> void:
	var crop_points: Array = []
	for district in layout.districts:
		if str(district.kind) == "crop":
			crop_points = district.points
			break
	crop_field = FieldStateSystem.new()
	crop_field.name = "BarleyFieldStateSystem"
	add_child(crop_field)
	crop_field.configure(crop_points)

func _build_orchard() -> void:
	var tree_positions := [
		Vector3(43,0,1),Vector3(52,0,-1),Vector3(62,0,1),Vector3(70,0,5),
		Vector3(41,0,10),Vector3(51,0,8),Vector3(61,0,10),Vector3(70,0,14),
		Vector3(45,0,18),Vector3(55,0,17),Vector3(64,0,19)
	]
	for pos in tree_positions: _add_tree(pos, 1.0)
	_add_pond(Vector3(74, 0, 20))

func _build_meadow_detail() -> void:
	for i in range(22):
		var x := -76.0 + float((i * 13) % 37)
		var z := -1.0 + float((i * 17) % 39)
		_add_flower_patch(Vector3(x, 0.18, z), i)
	for i in range(13):
		var x := -62.0 + float((i * 11) % 48)
		var z := -52.0 + float((i * 7) % 29)
		_add_grass_tuft(Vector3(x, 0.22, z))

func _record_hedge_edges(points: Array, edges: Dictionary) -> void:
	for index in range(points.size()):
		var a := Vector2(float(points[index][0]), float(points[index][1]))
		var next_index := (index + 1) % points.size()
		var b := Vector2(float(points[next_index][0]), float(points[next_index][1]))
		var first := a if a.x < b.x or (is_equal_approx(a.x, b.x) and a.y <= b.y) else b
		var second := b if first == a else a
		var key := "%.2f,%.2f|%.2f,%.2f" % [first.x, first.y, second.x, second.y]
		if not edges.has(key): edges[key] = [a, b]

func _add_hedge_segment(a: Vector2, b: Vector2, prefix: String) -> void:
	_add_boundary_segment(HEDGE_STRAIGHT, a, b, prefix)

func _add_wall_segment(a: Vector2, b: Vector2, prefix: String) -> void:
	_add_boundary_segment(WALL_STRAIGHT, a, b, prefix)

func _add_boundary_segment(asset: PackedScene, a: Vector2, b: Vector2, prefix: String) -> void:
	var delta := b - a
	var count := maxi(1, int(ceil(delta.length() / BOUNDARY_MODULE_LENGTH)))
	for i in range(count):
		var piece_a := a.lerp(b, float(i) / float(count))
		var piece_b := a.lerp(b, float(i + 1) / float(count))
		var midpoint := (piece_a + piece_b) * 0.5
		if _near_gate(midpoint): continue
		var boundary := _add_authored_environment(
			asset,
			prefix + "Module%d" % i,
			Vector3(midpoint.x, 0.08, midpoint.y),
			rad_to_deg(atan2(-delta.y, delta.x)),
			1.0
		)
		boundary.scale.x = piece_a.distance_to(piece_b) / BOUNDARY_MODULE_LENGTH

func _is_west_yard_stone_boundary(a: Vector2, b: Vector2) -> bool:
	return (a.is_equal_approx(Vector2(-25, -10)) and b.is_equal_approx(Vector2(-25, 17))) \
		or (b.is_equal_approx(Vector2(-25, -10)) and a.is_equal_approx(Vector2(-25, 17)))

func _near_gate(point: Vector2) -> bool:
	for gate in FIELD_GATE_GAPS:
		var gate_position: Vector2 = gate.position
		if point.distance_to(gate_position) < float(gate.width) * 0.5 + 3.2: return true
	return false

func _add_road_segment(prefix: String, a: Vector2, b: Vector2, width: float, color: Color) -> void:
	var delta := b - a
	var midpoint := (a + b) * 0.5
	var road := _add_box(prefix, Vector3(midpoint.x, 0.09, midpoint.y), Vector3(width, 0.12, delta.length()), color)
	road.rotation.y = atan2(delta.x, delta.y)

func _add_polygon(node_name: String, source_points: Array, y: float, color: Color, kind := "") -> void:
	var polygon := PackedVector2Array()
	var vertices := PackedVector3Array()
	var uvs := PackedVector2Array()
	for point in source_points:
		var p := Vector2(float(point[0]), float(point[1]))
		polygon.append(p)
		vertices.append(Vector3(p.x, y, p.y))
		uvs.append((p + Vector2(90, 65)) / Vector2(180, 130))
	var indices := Geometry2D.triangulate_polygon(polygon)
	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.material_override = _terrain_material(color, kind)
	add_child(instance)

func _terrain_material(color: Color, kind: String) -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
		shader_type spatial;
		render_mode diffuse_burley;
		uniform vec4 base_color : source_color;
		uniform float detail_strength = 0.10;
		uniform float row_strength = 0.0;
		void fragment() {
			float broad = sin(UV.x * 88.0 + sin(UV.y * 31.0) * 1.8) * 0.5 + 0.5;
			float fleck = sin(UV.x * 413.0 + UV.y * 277.0) * 0.5 + 0.5;
			float rows = smoothstep(0.33, 0.48, abs(fract(UV.x * 46.0) - 0.5));
			vec3 tint = base_color.rgb * (0.91 + broad * detail_strength + fleck * 0.025);
			tint = mix(tint, tint * 0.74, rows * row_strength);
			ALBEDO = tint;
			ROUGHNESS = 0.96;
		}
	"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("base_color", color)
	material.set_shader_parameter("detail_strength", 0.15 if kind in ["yard", "loading", "delivery"] else 0.10)
	material.set_shader_parameter("row_strength", 0.22 if kind == "crop" else 0.04 if kind in ["pasture", "hay"] else 0.0)
	return material

func _add_tree(position: Vector3, scale_factor: float) -> void:
	_add_box("TreeTrunk", position + Vector3(0, 1.5 * scale_factor, 0), Vector3(0.7, 3.0, 0.7) * scale_factor, Color("#61472f"))
	_add_sphere("TreeCrown", position + Vector3(-0.5, 3.7, 0), 2.05 * scale_factor, Color("#4b7845"))
	_add_sphere("TreeCrown", position + Vector3(1.0, 3.5, 0.25), 1.75 * scale_factor, Color("#5a884e"))
	_add_sphere("TreeCrown", position + Vector3(0.25, 4.5, -0.4), 1.65 * scale_factor, Color("#638f51"))

func _add_sheep(position: Vector3) -> void:
	_add_sphere("SheepBody", position + Vector3(0, 0.8, 0), 0.72, Color("#f2ead8"))
	_add_sphere("SheepHead", position + Vector3(0, 0.82, -0.72), 0.36, Color("#3f3a34"))
	for offset in [Vector3(-0.38,0.3,-0.25),Vector3(0.38,0.3,-0.25),Vector3(-0.38,0.3,0.28),Vector3(0.38,0.3,0.28)]:
		_add_box("SheepLeg", position + offset, Vector3(0.14,0.6,0.14), Color("#454039"))

func _add_hive(position: Vector3) -> void:
	_add_box("HiveStand", position + Vector3(0,0.18,0), Vector3(1.5,0.22,1.1), Color("#5b4430"))
	_add_box("Beehive", position + Vector3(0,0.72,0), Vector3(1.25,0.95,0.95), Color("#d8a53f"))
	_add_box("HiveRoof", position + Vector3(0,1.28,0), Vector3(1.5,0.18,1.15), Color("#8c6340"))

func _add_combine(position: Vector3) -> void:
	_add_box("CombineBody", position + Vector3(0,1.15,0), Vector3(4.2,2.3,5.8), Color("#d8a928"))
	_add_box("CombineCab", position + Vector3(0,2.5,-0.8), Vector3(3.2,1.6,2.5), Color("#7caaa5"))
	_add_box("CombineHeader", position + Vector3(0,0.65,-4.0), Vector3(6.5,0.55,1.5), Color("#bd8524"))
	for x in [-1.75,1.75]:
		_add_wheel(position + Vector3(x,0.65,-1.4), 0.9)
		_add_wheel(position + Vector3(x,0.52,1.7), 0.65)

func _add_trailer(position: Vector3) -> void:
	_add_box("Trailer", position + Vector3(0,1.15,0), Vector3(3.0,1.7,5.5), Color("#5f8259"))
	for x in [-1.4,1.4]: _add_wheel(position + Vector3(x,0.5,1.35), 0.55)

func _add_van(position: Vector3) -> void:
	_add_box("DeliveryVan", position + Vector3(0,1.25,0), Vector3(3.0,2.5,5.2), Color("#eee7d7"))
	_add_box("VanScreen", position + Vector3(0,1.7,-2.62), Vector3(2.4,0.8,0.08), Color("#7da6a5"))
	for x in [-1.35,1.35]: _add_wheel(position + Vector3(x,0.48,1.45), 0.5)

func _add_wheel(position: Vector3, radius: float) -> void:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.45
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees.z = 90
	instance.material_override = _material(Color("#292c29"))
	add_child(instance)

func _add_pond(position: Vector3) -> void:
	var pond := _add_box("DuckPond", position + Vector3(0,0.08,0), Vector3(9,0.12,6), Color("#66a9b4"))
	pond.rotation_degrees.y = -18

func _add_flower_patch(position: Vector3, index: int) -> void:
	var colors := [Color("#f0d56a"),Color("#e8e1d2"),Color("#d99982")]
	_add_sphere("Wildflower", position, 0.17, colors[index % colors.size()])

func _add_grass_tuft(position: Vector3) -> void:
	var tuft := _add_box("GrassTuft", position, Vector3(0.12,0.45,0.6), Color("#4f7c43"))
	tuft.rotation_degrees.y = 25

func _add_silo(structure: Dictionary) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = str(structure.id)
	var mesh := CylinderMesh.new()
	mesh.top_radius = float(structure.radius)
	mesh.bottom_radius = float(structure.radius)
	mesh.height = float(structure.height)
	mesh_instance.mesh = mesh
	mesh_instance.position = Vector3(float(structure.x), float(structure.height) / 2.0, float(structure.z))
	mesh_instance.material_override = _material(Color("#95a39e"))
	add_child(mesh_instance)
	var roof := MeshInstance3D.new()
	var cone := CylinderMesh.new()
	cone.top_radius = 0.15
	cone.bottom_radius = float(structure.radius) + 0.2
	cone.height = 2.0
	roof.mesh = cone
	roof.position = Vector3(float(structure.x), float(structure.height) + 1.0, float(structure.z))
	roof.material_override = _material(Color("#6e7773"))
	add_child(roof)

func _add_disc(position: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.12
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	add_child(instance)
	return instance

func _add_sphere(node_name: String, position: Vector3, radius: float, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 1.8
	mesh.radial_segments = 12
	mesh.rings = 6
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	add_child(instance)

func _add_box(node_name: String, position: Vector3, size: Vector3, color: Color, collision := false, parent: Node = self) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = position
	instance.material_override = _material(color)
	parent.add_child(instance)
	if collision:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var box_shape := BoxShape3D.new()
		box_shape.size = size
		shape.shape = box_shape
		body.add_child(shape)
		instance.add_child(body)
	return instance

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material

func _district_color(kind: String) -> Color:
	var colors := {
		"yard": Color("#c5a473"), "hay": Color("#93ae62"), "pasture": Color("#73a65f"),
		"crop": Color("#a7b853"), "orchard": Color("#779b5d"), "meadow": Color("#88ad69"), "loading": Color("#b99b72"),
		"delivery": Color("#9b9586")
	}
	return colors.get(kind, Color("#78965b"))

func _structure_color(kind: String) -> Color:
	var colors := {
		"workshop": Color("#b98d67"), "shed": Color("#6f8a76"), "barn": Color("#a98258"),
		"canopy": Color("#718a7a"), "intake": Color("#59615d")
	}
	return colors.get(kind, Color("#857c6d"))
