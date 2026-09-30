extends Node3D

const OAK := preload("res://assets/environment/english_oak.glb")
const OAK_BASE := preload("res://assets/environment/boundary_kit/oak_courtyard_base.glb")
const HEDGE_STRAIGHT := preload("res://assets/environment/boundary_kit/hawthorn_straight.glb")
const HEDGE_CURVE := preload("res://assets/environment/boundary_kit/hawthorn_curve.glb")
const HEDGE_CORNER := preload("res://assets/environment/boundary_kit/hawthorn_corner.glb")
const HEDGE_END := preload("res://assets/environment/boundary_kit/hawthorn_end.glb")
const HEDGE_GATE := preload("res://assets/environment/boundary_kit/hawthorn_gate.glb")
const WALL_STRAIGHT := preload("res://assets/environment/boundary_kit/drystone_straight.glb")
const WALL_CURVE := preload("res://assets/environment/boundary_kit/drystone_curve.glb")
const WALL_CORNER := preload("res://assets/environment/boundary_kit/drystone_corner.glb")
const WALL_END := preload("res://assets/environment/boundary_kit/drystone_end.glb")
const WALL_GATE := preload("res://assets/environment/boundary_kit/drystone_gate.glb")

var groups: Array[Node3D] = []
var selected := 0
var names := ["CONNECTED HAWTHORN KIT", "DRYSTONE WALL AND GATE KIT", "NATURAL OAK COURTYARD BASE"]

func _ready() -> void:
	var stage := MeshInstance3D.new()
	stage.name = "BoundaryKitReviewMeadow"
	var stage_mesh := BoxMesh.new()
	stage_mesh.size = Vector3(56.0, 0.12, 32.0)
	stage.mesh = stage_mesh
	stage.position.y = -0.08
	var stage_material := StandardMaterial3D.new()
	stage_material.albedo_color = Color("#70845a")
	stage_material.roughness = 0.98
	stage.material_override = stage_material
	add_child(stage)

	var hedges := _group("HawthornKit")
	_add(hedges, HEDGE_END, Vector3(-19.0, 0, -2.0), 180.0)
	_add(hedges, HEDGE_STRAIGHT, Vector3(-11.0, 0, -2.0))
	_add(hedges, HEDGE_GATE, Vector3(0.0, 0, -2.0))
	_add(hedges, HEDGE_STRAIGHT, Vector3(11.0, 0, -2.0))
	_add(hedges, HEDGE_END, Vector3(19.0, 0, -2.0))
	_add(hedges, HEDGE_CURVE, Vector3(-7.0, 0, 7.0))
	_add(hedges, HEDGE_CORNER, Vector3(8.0, 0, 7.0))

	var walls := _group("DrystoneKit")
	_add(walls, WALL_END, Vector3(-19.0, 0, -2.0), 180.0)
	_add(walls, WALL_STRAIGHT, Vector3(-11.0, 0, -2.0))
	_add(walls, WALL_GATE, Vector3(0.0, 0, -2.0))
	_add(walls, WALL_STRAIGHT, Vector3(11.0, 0, -2.0))
	_add(walls, WALL_END, Vector3(19.0, 0, -2.0))
	_add(walls, WALL_CURVE, Vector3(-7.0, 0, 7.0))
	_add(walls, WALL_CORNER, Vector3(8.0, 0, 7.0))

	var oak := _group("OakBaseKit")
	_add(oak, OAK_BASE, Vector3.ZERO)
	_add(oak, OAK, Vector3(0, 0.08, 0), 0.0, 0.88)
	show_kit(0)

func _group(group_name: String) -> Node3D:
	var value := Node3D.new()
	value.name = group_name
	groups.append(value)
	add_child(value)
	return value

func _add(owner: Node3D, scene: PackedScene, at: Vector3, rotation_y := 0.0, scale_factor := 1.0) -> void:
	var item := scene.instantiate()
	item.position = at
	item.rotation_degrees.y = rotation_y
	item.scale = Vector3.ONE * scale_factor
	owner.add_child(item)

func show_kit(index: int) -> void:
	selected = clampi(index, 0, groups.size() - 1)
	for group_index in range(groups.size()):
		groups[group_index].visible = group_index == selected

func get_review_label() -> String:
	return "BOUNDARY KIT REVIEW · %s · 1–3 SWITCH KIT · INTEGRATED" % names[selected]

func get_camera_size() -> float:
	return 13.0 if selected == 2 else 42.0

func get_camera_target() -> Vector3:
	return Vector3(0, 3.8, 0) if selected == 2 else Vector3(0, 0.8, 1.0)
