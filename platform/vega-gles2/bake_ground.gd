extends SceneTree

# Build-time render of the existing terrain, not a flattened gameplay map.
func _init():
 call_deferred("bake")

func bake():
 var view=Viewport.new()
 view.size=Vector2(2040,1440)
 view.own_world=true
 view.usage=Viewport.USAGE_2D
 view.render_target_update_mode=Viewport.UPDATE_ALWAYS
 root.add_child(view)
 var sprite=Sprite.new()
 sprite.texture=load("res://assets/2d/production/cohesive_ground_mask.png")
 sprite.centered=false
 sprite.scale=Vector2(2.4,2.4)
 var material=ShaderMaterial.new()
 var shader=Shader.new()
 var f=File.new()
 assert(f.open("res://shaders/cohesive_ground.shader",File.READ)==OK)
 var source=f.get_as_text()
 f.close()
 # Water is rendered independently at runtime; bake everything underneath it.
 source=source.replace("ground=mix(ground,water,smoothstep(.24,.92,masks.b));","")
 shader.code=source
 material.shader=shader
 material.set_shader_param("wear_tex",load("res://assets/2d/production/cohesive_wear_mask.png"))
 material.set_shader_param("meadow_tex",load("res://assets/2d/production/reference_meadow.png"))
 for key in ["grass","earth","yard","water"]:
  material.set_shader_param(key+"_tex",load("res://assets/2d/production/cohesive_%s.png"%key))
 sprite.material=material
 view.add_child(sprite)
 yield(VisualServer,"frame_post_draw")
 yield(VisualServer,"frame_post_draw")
 var image=view.get_texture().get_data()
 image.flip_y()
 var error=image.save_png("res://assets/2d/production/vega_baked_ground.png")
 if error!=OK:
  push_error("Terrain bake failed: %s"%error)
  quit(1)
 else:
  print("BAKED_GROUND=2040x1440")
  view.queue_free()
  # Restrict river shading to the authored water channel's bounding rectangle.
  var mask=load("res://assets/2d/production/cohesive_ground_mask.png").get_data()
  mask.lock()
  var low=Vector2(mask.get_width(),mask.get_height())
  var high=Vector2.ZERO
  for y in range(mask.get_height()):
   for x in range(mask.get_width()):
    if mask.get_pixel(x,y).b>.20:
     low.x=min(low.x,x);low.y=min(low.y,y)
     high.x=max(high.x,x);high.y=max(high.y,y)
  mask.unlock()
  # Shader UV maps the 2040x1440 padded terrain onto the 1700x1200 world.
  var region=Rect2((Vector2(170,120)+low*2-Vector2(4,4))/2.4,((high-low)*2+Vector2(10,10))/2.4)
  var output=File.new()
  output.open("res://data/vega_water_bounds.json",File.WRITE)
  output.store_string(to_json([region.position.x,region.position.y,region.size.x,region.size.y]))
  output.close()
  var layout_file=File.new()
  layout_file.open("res://data/world_layout.json",File.READ)
  var layout=parse_json(layout_file.get_as_text())
  layout_file.close()
  for building in layout.structures:
   var clean_view=Viewport.new()
   clean_view.transparent_bg=true
   clean_view.own_world=true
   clean_view.usage=Viewport.USAGE_2D
   clean_view.render_target_update_mode=Viewport.UPDATE_ALWAYS
   root.add_child(clean_view)
   var art=Sprite.new()
   art.texture=load("res://assets/2d/production/%s.png"%building.asset)
   art.centered=false
   clean_view.size=art.texture.get_size()
   var clean=ShaderMaterial.new()
   var clean_shader=Shader.new()
   var clean_file=File.new()
   clean_file.open("res://shaders/clean_sprite.shader",File.READ)
   # Keep straight RGBA in the PNG; framebuffer blending would premultiply edges.
   clean_shader.code=clean_file.get_as_text().replace("shader_type canvas_item;","shader_type canvas_item;\nrender_mode blend_disabled;")
   clean_file.close()
   clean.shader=clean_shader
   art.material=clean
   clean_view.add_child(art)
   yield(VisualServer,"frame_post_draw")
   yield(VisualServer,"frame_post_draw")
   var cleaned=clean_view.get_texture().get_data()
   cleaned.flip_y()
   var result=cleaned.save_png("res://assets/2d/production/vega_clean_%s.png"%building.asset)
   if result!=OK:
    push_error("Structure bake failed")
    quit(1)
    return
   clean_view.queue_free()
  print("BAKED_STRUCTURE_CLEANUP=%s"%layout.structures.size())
  quit()
