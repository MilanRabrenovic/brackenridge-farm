extends Node3D

const GRAIN_STORE := preload("res://scenes/buildings/grain_store.tscn")
const TRACTOR := preload("res://scenes/vehicles/tractor.tscn")

func _ready() -> void:
	var stage := MeshInstance3D.new()
	stage.name = "GrainStoreReviewMeadow"
	var stage_mesh := BoxMesh.new()
	stage_mesh.size = Vector3(42.0, 0.12, 34.0)
	stage.mesh = stage_mesh
	stage.position.y = -0.08
	var stage_material := StandardMaterial3D.new()
	stage_material.albedo_color = Color("#70845a")
	stage_material.roughness = 0.98
	stage.material_override = stage_material
	add_child(stage)

	var store := GRAIN_STORE.instantiate()
	store.name = "GrainStoreUnderReview"
	store.rotation_degrees.y = 180.0
	add_child(store)

	var tractor := TRACTOR.instantiate()
	tractor.name = "ScaleReferenceTractor"
	tractor.position = Vector3(-6.0, 0.15, 0.5)
	tractor.rotation_degrees.y = 180.0
	add_child(tractor)

	_add_trailer_reference(Vector3(-6.0, 0.15, 6.2))

func _add_trailer_reference(position: Vector3) -> void:
	var root := Node3D.new()
	root.name = "TrailerClearanceReference"
	root.position = position
	add_child(root)
	var bed := MeshInstance3D.new()
	var bed_mesh := BoxMesh.new()
	bed_mesh.size = Vector3(3.0, 2.1, 6.5)
	bed.mesh = bed_mesh
	bed.position.y = 1.45
	bed.material_override = _material(Color("#47784f"))
	root.add_child(bed)
	for x in [-1.42, 1.42]:
		for z in [-1.65, 1.65]:
			var wheel := MeshInstance3D.new()
			var wheel_mesh := CylinderMesh.new()
			wheel_mesh.top_radius = 0.62
			wheel_mesh.bottom_radius = 0.62
			wheel_mesh.height = 0.34
			wheel.mesh = wheel_mesh
			wheel.position = Vector3(x, 0.65, z)
			wheel.rotation_degrees.z = 90
			wheel.material_override = _material(Color("#1c2420"))
			root.add_child(wheel)

func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material
