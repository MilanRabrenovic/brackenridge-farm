class_name FarmRectangle
extends RectangleShape2D
var size setget set_size,get_size
func set_size(value):extents=value*.5
func get_size():return extents*2
