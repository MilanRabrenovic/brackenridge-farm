extends Node3D

@export var turn_speed := 9.0
@export var animation_blend := 0.16

var animation_player: AnimationPlayer
var motion_direction := Vector3.ZERO
var motion_amount := 0.0
var carrying := false
var action_time := 0.0
var locomotion_clip := ""

func _ready() -> void:
	animation_player = _find_animation_player(self)
	if animation_player:
		_play_clip("Idle", 0.0)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var match := _find_animation_player(child)
		if match:
			return match
	return null

func set_motion(direction: Vector3, amount: float) -> void:
	motion_direction = direction
	motion_amount = clampf(amount, 0.0, 1.0)

func play_interact() -> void:
	_play_one_shot("Interact")

func play_farm_action(action_name: String) -> void:
	var clips := {
		"harvest": "Farm_Harvest",
		"plant": "Farm_PlantSeed",
		"water": "Farm_Watering",
		"repair": "Fixing_Kneeling",
		"chop": "TreeChopping",
		"throw": "OverhandThrow",
		"pickup": "PickUp_Table",
		"dance": "Dance",
	}
	if clips.has(action_name):
		_play_one_shot(String(clips[action_name]))

func set_carrying(enabled: bool) -> void:
	carrying = enabled

func has_animation(clip_name: String) -> bool:
	return animation_player != null and animation_player.has_animation(clip_name)

func get_animation_player() -> AnimationPlayer:
	return animation_player

func _play_one_shot(clip_name: String) -> void:
	if not has_animation(clip_name):
		return
	action_time = animation_player.get_animation(clip_name).length
	animation_player.play(clip_name, animation_blend)

func _play_clip(clip_name: String, blend := animation_blend) -> void:
	if not has_animation(clip_name):
		return
	locomotion_clip = clip_name
	animation_player.play(clip_name, blend)

func _process(delta: float) -> void:
	if not animation_player:
		return
	if motion_direction.length() > 0.06:
		var target_heading := atan2(motion_direction.x, motion_direction.z)
		rotation.y = lerp_angle(rotation.y, target_heading, minf(1.0, delta * turn_speed))
	if action_time > 0.0:
		action_time = maxf(0.0, action_time - delta)
		if action_time > 0.0:
			return
	var next_clip := "Idle"
	var playback_speed := 1.0
	if motion_amount > 0.08:
		if carrying:
			next_clip = "Walk_Carry"
			playback_speed = lerpf(0.72, 1.12, motion_amount)
		elif motion_amount > 0.82:
			next_clip = "Jog_Fwd"
			playback_speed = lerpf(0.82, 1.15, motion_amount)
		else:
			next_clip = "Walk"
			playback_speed = lerpf(0.62, 1.08, motion_amount)
	if next_clip != locomotion_clip or not animation_player.is_playing():
		_play_clip(next_clip)
	animation_player.speed_scale = playback_speed
