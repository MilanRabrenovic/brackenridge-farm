extends SceneTree

const GROWER := preload("res://scenes/characters/grower.tscn")
const MECHANIC := preload("res://scenes/characters/mechanic.tscn")
const MILO := preload("res://scenes/characters/milo.tscn")
const PIP := preload("res://scenes/characters/pip.tscn")
const REQUIRED_CLIPS := [
	"Idle",
	"Walk",
	"Jog_Fwd",
	"Interact",
	"Driving",
	"Fixing_Kneeling",
	"Farm_Harvest",
	"Farm_PlantSeed",
	"Farm_Watering",
	"Walk_Carry",
	"Dance",
]

func _initialize() -> void:
	call_deferred("_run")

func _fail(message: String) -> void:
	push_error(message)
	quit(1)

func _count_class(node: Node, class_name_to_find: StringName) -> int:
	var count := 1 if node.is_class(class_name_to_find) else 0
	for child in node.get_children():
		count += _count_class(child, class_name_to_find)
	return count

func _run() -> void:
	var grower := GROWER.instantiate()
	var mechanic := MECHANIC.instantiate()
	var milo := MILO.instantiate()
	var pip := PIP.instantiate()
	get_root().add_child(grower)
	get_root().add_child(mechanic)
	get_root().add_child(milo)
	get_root().add_child(pip)
	await process_frame
	for visual in [grower, mechanic, milo, pip]:
		if _count_class(visual, &"Skeleton3D") != 1:
			_fail("%s must contain exactly one Skeleton3D" % visual.name)
			return
		if _count_class(visual, &"MeshInstance3D") < 6:
			_fail("%s is missing its authored skinned character pieces" % visual.name)
			return
		var player: AnimationPlayer = visual.get_animation_player()
		if not player:
			_fail("%s is missing its AnimationPlayer" % visual.name)
			return
		for clip in REQUIRED_CLIPS:
			if not player.has_animation(clip):
				_fail("%s is missing required animation %s" % [visual.name, clip])
				return
		player.play("Walk")
		player.advance(0.2)
		if player.current_animation_position <= 0.0:
			_fail("%s walk animation did not advance" % visual.name)
			return
	grower.set_motion(Vector3(1, 0, 0), 1.0)
	for _frame in range(6):
		grower._process(0.1)
	if absf(grower.rotation.y - PI * 0.5) > 0.35:
		_fail("Grower did not turn toward the requested movement direction")
		return
	mechanic.play_farm_action("repair")
	if mechanic.get_animation_player().current_animation != "Fixing_Kneeling":
		_fail("Mechanic did not enter the requested repair animation")
		return
	milo.play_farm_action("dance")
	if milo.get_animation_player().current_animation != "Dance":
		_fail("Milo did not enter the requested dance animation")
		return
	pip.play_farm_action("dance")
	if pip.get_animation_player().current_animation != "Dance":
		_fail("Pip did not enter the requested celebration dance")
		return
	print("Character visual test passed: four rigs, required clips, turning, repair and character dances verified")
	quit(0)
