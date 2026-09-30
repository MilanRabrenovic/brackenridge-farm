class_name FieldStateSystem
extends Node3D

const STATES := ["untouched", "cultivated", "seedbed", "seeded", "growing", "mature", "harvested", "protected", "damaged"]

var state_index := 5
var field_points := PackedVector2Array()
var crop_rows: MultiMeshInstance3D
var status_marker: Label3D

func configure(points: Array) -> void:
	field_points.clear()
	for point in points:
		field_points.append(Vector2(float(point[0]), float(point[1])))
	_build_rows()
	_build_status_marker()
	_apply_state()

func cycle_state() -> String:
	state_index = (state_index + 1) % STATES.size()
	_apply_state()
	return STATES[state_index]

func set_state(next_state: String) -> void:
	var found := STATES.find(next_state)
	if found >= 0:
		state_index = found
		_apply_state()

func get_state() -> String:
	return STATES[state_index]

func _build_rows() -> void:
	crop_rows = MultiMeshInstance3D.new()
	crop_rows.name = "BarleyRowsWithTramlines"
	var row_mesh := BoxMesh.new()
	row_mesh.size = Vector3(1.25, 0.72, 2.6)
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = row_mesh
	var min_x := 100000.0
	var max_x := -100000.0
	var min_z := 100000.0
	var max_z := -100000.0
	for point in field_points:
		min_x = minf(min_x, point.x)
		max_x = maxf(max_x, point.x)
		min_z = minf(min_z, point.y)
		max_z = maxf(max_z, point.y)
	var transforms: Array[Transform3D] = []
	var column := 0
	var x := min_x + 1.2
	while x <= max_x - 1.2:
		var tramline := column % 12 in [5, 6]
		var z := min_z + 3.5
		while z <= max_z - 3.5:
			var sample := Vector2(x, z)
			if not tramline and Geometry2D.is_point_in_polygon(sample, field_points):
				var angle := sin(x * 0.19 + z * 0.11) * 0.025
				transforms.append(Transform3D(Basis(Vector3.UP, angle), Vector3(x, 0.45, z)))
			z += 2.85
		x += 1.55
		column += 1
	multimesh.instance_count = transforms.size()
	for index in range(transforms.size()):
		multimesh.set_instance_transform(index, transforms[index])
	crop_rows.multimesh = multimesh
	add_child(crop_rows)

func _build_status_marker() -> void:
	status_marker = Label3D.new()
	status_marker.name = "FieldStateMarker"
	status_marker.position = Vector3(40, 1.4, -48)
	status_marker.font_size = 34
	status_marker.outline_size = 8
	status_marker.modulate = Color("#fff0b2")
	status_marker.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	status_marker.no_depth_test = true
	add_child(status_marker)

func _apply_state() -> void:
	if not crop_rows:
		return
	var state: String = str(STATES[state_index])
	var material := StandardMaterial3D.new()
	material.roughness = 0.96
	var height_scale := 1.0
	crop_rows.visible = true
	match state:
		"untouched":
			crop_rows.visible = false
			material.albedo_color = Color("#77985d")
		"cultivated":
			height_scale = 0.08
			material.albedo_color = Color("#6f4b35")
		"seedbed":
			height_scale = 0.05
			material.albedo_color = Color("#987052")
		"seeded":
			height_scale = 0.12
			material.albedo_color = Color("#7ba24e")
		"growing":
			height_scale = 0.55
			material.albedo_color = Color("#86aa48")
		"mature":
			height_scale = 1.0
			material.albedo_color = Color("#d2a93f")
		"harvested":
			height_scale = 0.16
			material.albedo_color = Color("#aa7f3f")
		"protected":
			height_scale = 0.92
			material.albedo_color = Color("#cba23e")
		"damaged":
			height_scale = 0.38
			material.albedo_color = Color("#806d42")
	crop_rows.scale.y = height_scale
	crop_rows.material_override = material
	status_marker.text = "BARLEY · %s" % state.to_upper()
