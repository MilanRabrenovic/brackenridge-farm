extends Node3D

const PIP := preload("res://scenes/characters/pip.tscn")

var pip: Node3D
var elapsed := 0.0
var last_phase := -1

func _ready() -> void:
	var stage := MeshInstance3D.new()
	stage.name = "CharacterReviewMeadow"
	var stage_mesh := BoxMesh.new()
	stage_mesh.size = Vector3(7.5, 0.12, 5.2)
	stage.mesh = stage_mesh
	stage.position.y = -0.08
	var stage_material := StandardMaterial3D.new()
	stage_material.albedo_color = Color("#70845a")
	stage_material.roughness = 0.98
	stage.material_override = stage_material
	add_child(stage)
	pip = PIP.instantiate()
	add_child(pip)

func _process(delta: float) -> void:
	elapsed += delta
	if not pip:
		return
	pip.set_motion(Vector3.ZERO, 0.0)
	var phase := fmod(elapsed, 12.0)
	var phase_index := 0
	if phase < 2.2:
		pass
	elif phase < 4.8:
		phase_index = 1
		pip.set_motion(Vector3(0, 0, 1), 0.72)
	elif phase < 7.0:
		phase_index = 2
	elif phase < 9.4:
		phase_index = 3
	else:
		phase_index = 4
	if phase_index != last_phase:
		last_phase = phase_index
		if phase_index == 2:
			pip.play_interact()
		elif phase_index == 3:
			pip.play_farm_action("harvest")
		elif phase_index == 4:
			pip.play_farm_action("dance")

func get_review_label() -> String:
	return "NEW CHARACTER REVIEW · PIP PUDDLEBOOTS · WALK / WORK / CELEBRATE"

func get_camera_target() -> Vector3:
	return Vector3(0, 0.92, 0)

func get_camera_size() -> float:
	return 2.35
