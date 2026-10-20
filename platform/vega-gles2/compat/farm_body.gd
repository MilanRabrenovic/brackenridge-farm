class_name FarmBody
extends KinematicBody2D
var velocity=Vector2.ZERO
var real_velocity=Vector2.ZERO
func step_motion():
 var start=position
 velocity=move_and_slide(velocity)
 real_velocity=(position-start)/max(.0001,get_physics_process_delta_time())
func get_real_velocity():return real_velocity
