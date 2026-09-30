extends Node3D

const BARN := preload("res://scenes/buildings/stone_barn.tscn")
const TRACTOR := preload("res://scenes/vehicles/tractor.tscn")
const OAK := preload("res://assets/environment/english_oak.glb")
const HEDGE := preload("res://assets/environment/hawthorn_hedge.glb")
const WALL := preload("res://assets/environment/dry_stone_wall.glb")

var items: Array[Node3D] = []
var selected := 0
var names := ["STONE BARN", "RED TRACTOR", "ENGLISH OAK", "HAWTHORN HEDGE", "DRYSTONE WALL"]
var sizes := [16.5, 6.5, 10.5, 6.3, 6.2]
var targets := [Vector3(0, 2.2, 0), Vector3(0, 1.5, 0), Vector3(0, 3.7, 0), Vector3(0, 0.9, 0), Vector3(0, 0.65, 0)]

func _ready() -> void:
	var stage := MeshInstance3D.new()
	stage.name = "ReviewMeadowStage"
	var stage_mesh := BoxMesh.new()
	stage_mesh.size = Vector3(34.0, 0.10, 25.0)
	stage.mesh = stage_mesh
	stage.position.y = -0.08
	var stage_material := StandardMaterial3D.new()
	stage_material.albedo_color = Color("#52624f")
	stage_material.roughness = 0.98
	stage.material_override = stage_material
	add_child(stage)

	_add_item(BARN.instantiate(), 0.0)
	_add_item(TRACTOR.instantiate(), 0.0)
	_add_item(OAK.instantiate(), 0.0)
	_add_item(HEDGE.instantiate(), -12.0)
	_add_item(WALL.instantiate(), -12.0)
	show_asset(0)

func _add_item(item: Node3D, rotation_y: float) -> void:
	item.rotation_degrees.y = rotation_y
	items.append(item)
	add_child(item)

func show_asset(index: int) -> void:
	selected = clampi(index, 0, items.size() - 1)
	for item_index in range(items.size()):
		items[item_index].visible = item_index == selected

func get_review_label() -> String:
	return "STORYBOOK ASSET REVIEW · %s · 1–5 SWITCH ASSET · IN PLAYABLE MAP · REVISION REVIEW" % names[selected]

func get_camera_size() -> float:
	return sizes[selected]

func get_camera_target() -> Vector3:
	return targets[selected]
