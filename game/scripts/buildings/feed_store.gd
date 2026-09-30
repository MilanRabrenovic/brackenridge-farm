extends StaticBody3D

const FEED_STORE_MODEL := preload("res://assets/buildings/bracken_feed_store.glb")

func _ready() -> void:
	var model := FEED_STORE_MODEL.instantiate()
	model.name = "AuthoredFeedStoreModel"
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
	_add_collision("RearWallCollision", Vector3(0, 2.05, 3.45), Vector3(11.2, 4.1, 0.4))
	_add_collision("LeftWallCollision", Vector3(-5.45, 2.05, 0), Vector3(0.4, 4.1, 7.2))
	_add_collision("RightWallCollision", Vector3(5.45, 2.05, 0), Vector3(0.4, 4.1, 7.2))
	_add_collision("LeftFrontPierCollision", Vector3(-4.85, 2.05, -3.45), Vector3(1.6, 4.1, 0.4))
	_add_collision("RightFrontPierCollision", Vector3(4.85, 2.05, -3.45), Vector3(1.6, 4.1, 0.4))
	for x in [-4.4, 4.4]:
		_add_collision("PorchPostCollision", Vector3(x, 2.0, -6.45), Vector3(0.46, 4.0, 0.46))
