extends StaticBody3D

const WORKSHOP_MODEL := preload("res://assets/buildings/bracken_workshop.glb")

func _ready() -> void:
	var model := WORKSHOP_MODEL.instantiate()
	model.name = "AuthoredWorkshopModel"
	add_child(model)
	_build_collision()

func _add_collision(shape_name: String, position: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	shape.name = shape_name
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = position
	add_child(shape)

func _build_collision() -> void:
	_add_collision("RearWallCollision", Vector3(0, 2.45, 5.1), Vector3(15.5, 4.9, 0.4))
	_add_collision("LeftWallCollision", Vector3(-7.6, 2.45, 0), Vector3(0.4, 4.9, 10.5))
	_add_collision("RightWallCollision", Vector3(7.6, 2.45, 0), Vector3(0.4, 4.9, 10.5))
	_add_collision("OfficeFrontCollision", Vector3(3.7, 2.3, -5.1), Vector3(6.9, 4.6, 0.4))
	_add_collision("CentrePierCollision", Vector3(0, 2.45, -5.1), Vector3(0.75, 4.9, 0.45))
