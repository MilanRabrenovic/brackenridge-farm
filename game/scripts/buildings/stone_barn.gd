extends Node3D

const BARN_MODEL := preload("res://assets/buildings/bracken_stone_barn.glb")

func _ready() -> void:
	var model := BARN_MODEL.instantiate()
	model.name = "AuthoredStoneBarnModel"
	# The imported facade faces +Z, toward the central yard from this plot.
	add_child(model)
	_build_collision()

func _add_wall_collision(name: String, position: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	shape.name = name
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = position
	add_child(shape)

func _build_collision() -> void:
	# Four shell sections leave the central double-door entrance genuinely open.
	_add_wall_collision("BackWallCollision", Vector3(0, 2.0, -4.0), Vector3(14.0, 4.0, 0.45))
	_add_wall_collision("LeftWallCollision", Vector3(-7.0, 2.0, 0), Vector3(0.45, 4.0, 8.0))
	_add_wall_collision("RightWallCollision", Vector3(7.0, 2.0, 0), Vector3(0.45, 4.0, 8.0))
	_add_wall_collision("FrontLeftCollision", Vector3(-4.65, 2.0, 4.0), Vector3(4.7, 4.0, 0.45))
	_add_wall_collision("FrontRightCollision", Vector3(4.65, 2.0, 4.0), Vector3(4.7, 4.0, 0.45))
