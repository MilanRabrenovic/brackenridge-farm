extends StaticBody3D

const GRAIN_STORE_MODEL := preload("res://assets/buildings/bracken_grain_store.glb")

func _ready() -> void:
	var model := GRAIN_STORE_MODEL.instantiate()
	model.name = "AuthoredGrainStoreModel"
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
	# The grain-hall door and straight-through intake lane stay completely open.
	_add_collision("HallRearWallCollision", Vector3(-6.0, 3.0, -6.9), Vector3(14.0, 6.0, 0.35))
	_add_collision("HallLeftWallCollision", Vector3(-12.9, 3.0, 0), Vector3(0.35, 6.0, 14.0))
	_add_collision("HallRightWallCollision", Vector3(0.9, 3.0, 0), Vector3(0.35, 6.0, 14.0))
	for x in [1.55, 10.45]:
		for z in [-6.6, 6.6]:
			_add_collision("CanopyPostCollision", Vector3(x, 3.25, z), Vector3(0.55, 6.5, 0.55))
