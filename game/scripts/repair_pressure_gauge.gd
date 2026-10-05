extends Control
# Mission instrument UI. It never changes world art or collision.
var pressure:=0.0
func _draw()->void:
 var bounds:=Rect2(Vector2.ZERO,size)
 draw_style_box(_style(Color("#14261f")),bounds)
 draw_rect(Rect2(size.x*.4,2,size.x*.35,size.y-4),Color("#547f45"))
 var x:=clampf(pressure,0,1)*(size.x-4)
 draw_rect(Rect2(x,0,4,size.y),Color("#ffe4a0"))
func _style(colour:Color)->StyleBoxFlat:
 var style:=StyleBoxFlat.new();style.bg_color=colour;style.set_corner_radius_all(5)
 return style
