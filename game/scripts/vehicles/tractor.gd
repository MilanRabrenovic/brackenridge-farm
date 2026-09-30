extends CharacterBody3D

const TRACTOR_MODEL := preload("res://assets/vehicles/bracken_tractor.glb")

var wheel_pivots: Array[Node3D] = []
var steering_pivots: Array[Node3D] = []
var target_speed := 0.0
var target_steering := 0.0

func _ready() -> void:
	var model := TRACTOR_MODEL.instantiate()
	model.name = "AuthoredTractorModel"
	add_child(model)
	_collect_animation_nodes(model)
	_build_collision()

func _collect_animation_nodes(model: Node) -> void:
	for child in model.find_children("*SpinPivot", "Node3D", true, false):
		wheel_pivots.append(child as Node3D)
	for child in model.find_children("*SteeringPivot", "Node3D", true, false):
		steering_pivots.append(child as Node3D)

func _build_collision() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(3.25, 3.6, 5.1)
	shape.shape = box
	shape.position = Vector3(0, 1.75, 0)
	add_child(shape)

func set_vehicle_motion(speed: float, steering: float) -> void:
	target_speed = speed
	target_steering = clampf(steering, -1.0, 1.0)

func _process(delta: float) -> void:
	for pivot in wheel_pivots:
		pivot.rotate_x(target_speed * delta * 1.35)
	for pivot in steering_pivots:
		pivot.rotation.y = lerpf(pivot.rotation.y, target_steering * 0.48, minf(1.0, delta * 7.0))
