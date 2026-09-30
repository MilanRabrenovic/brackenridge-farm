extends StaticBody3D

const SHED_MODEL := preload("res://assets/buildings/bracken_machinery_shed.glb")

func _ready() -> void:
	var model := SHED_MODEL.instantiate()
	model.name = "AuthoredMachineryShedModel"
	add_child(model)
	_build_collision()

func _add_collision(name: String, position: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	shape.name = name
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = position
	add_child(shape)

func _build_collision() -> void:
	# The complete front remains open. Collision follows the rear, sides,
	# enclosed parts room, and exposed portal posts.
	_add_collision("RearWallCollision", Vector3(0, 2.4, -5.65), Vector3(24.0, 4.8, 0.35))
	_add_collision("LeftWallCollision", Vector3(-11.9, 2.4, 0), Vector3(0.35, 4.8, 11.5))
	_add_collision("RightWallCollision", Vector3(11.9, 2.4, 0), Vector3(0.35, 4.8, 11.5))
	_add_collision("PartsRoomCollision", Vector3(9.0, 2.05, -2.4), Vector3(5.4, 4.1, 6.2))
	for x in [-12.0, -6.0, 0.3, 6.1, 12.0]:
		_add_collision("FrontPostCollision", Vector3(x, 2.35, 5.60), Vector3(0.42, 4.7, 0.46))

