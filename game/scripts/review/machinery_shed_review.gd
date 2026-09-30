extends Node3D

const MACHINERY_SHED := preload("res://scenes/buildings/machinery_shed.tscn")
const TRACTOR := preload("res://scenes/vehicles/tractor.tscn")

func _ready() -> void:
	var apron := MeshInstance3D.new()
	apron.name = "ReviewApron"
	var apron_mesh := BoxMesh.new()
	apron_mesh.size = Vector3(32.0, 0.12, 21.0)
	apron.mesh = apron_mesh
	apron.position = Vector3(0, -0.08, 0)
	var apron_material := StandardMaterial3D.new()
	apron_material.albedo_color = Color("#7f8669")
	apron_material.roughness = 0.98
	apron.material_override = apron_material
	add_child(apron)

	var shed := MACHINERY_SHED.instantiate()
	shed.name = "MachineryShedUnderReview"
	add_child(shed)

	var tractor := TRACTOR.instantiate()
	tractor.name = "ScaleReferenceTractor"
	tractor.position = Vector3(-8.8, 0.12, 1.3)
	tractor.rotation_degrees.y = 176.0
	add_child(tractor)

