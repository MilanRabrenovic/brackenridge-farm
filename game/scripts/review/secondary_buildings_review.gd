extends Node3D

const WORKSHOP := preload("res://scenes/buildings/workshop.tscn")
const FEED_STORE := preload("res://scenes/buildings/feed_store.tscn")

var items: Array[Node3D] = []
var selected := 0
var names := ["REPAIR WORKSHOP", "FEED STORE"]
var sizes := [19.0, 15.0]
var targets := [Vector3(0, 2.7, 0), Vector3(0, 2.3, -1.2)]

func _ready() -> void:
	var stage := MeshInstance3D.new()
	stage.name = "SecondaryBuildingsReviewMeadow"
	var stage_mesh := BoxMesh.new()
	stage_mesh.size = Vector3(38.0, 0.12, 29.0)
	stage.mesh = stage_mesh
	stage.position.y = -0.08
	var stage_material := StandardMaterial3D.new()
	stage_material.albedo_color = Color("#70845a")
	stage_material.roughness = 0.98
	stage.material_override = stage_material
	add_child(stage)

	_add_item(WORKSHOP.instantiate(), 180.0)
	_add_item(FEED_STORE.instantiate(), 90.0)
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
	return "SECONDARY BUILDING REVIEW · %s · 1–2 SWITCH ASSET" % names[selected]

func get_camera_size() -> float:
	return sizes[selected]

func get_camera_target() -> Vector3:
	return targets[selected]
