class_name FarmVBoxContainer
extends VBoxContainer
var position setget set_position_alias,get_position_alias
var size setget set_size_alias,get_size_alias
var custom_minimum_size setget set_min_size_alias,get_min_size_alias
var offset_left setget set_left_alias,get_left_alias
var offset_right setget set_right_alias,get_right_alias
var offset_top setget set_top_alias,get_top_alias
var offset_bottom setget set_bottom_alias,get_bottom_alias
func set_position_alias(v):rect_position=v
func get_position_alias():return rect_position
func set_size_alias(v):rect_size=v
func get_size_alias():return rect_size
func set_min_size_alias(v):rect_min_size=v
func get_min_size_alias():return rect_min_size
func set_left_alias(v):margin_left=v
func get_left_alias():return margin_left
func set_right_alias(v):margin_right=v
func get_right_alias():return margin_right
func set_top_alias(v):margin_top=v
func get_top_alias():return margin_top
func set_bottom_alias(v):margin_bottom=v
func get_bottom_alias():return margin_bottom
func set_anchors_and_offsets_preset(preset):set_anchors_and_margins_preset(preset)
func add_theme_font_size_override(_key,value):add_font_override("font",FarmCompat.font(value).duplicate())
func add_theme_color_override(key,value):add_color_override(key,value)
func add_theme_constant_override(key,value):add_constant_override(key,value)
func add_theme_stylebox_override(key,value):add_stylebox_override(key,value)
