class_name FarmCompat
extends Reference
static func read_text(path):
 var file=File.new()
 if file.open(path,File.READ)!=OK:return ""
 var text=file.get_as_text();file.close();return text
static func font(size_value):
 var root_node=Engine.get_main_loop().root
 if not root_node.has_meta("farm_gles2_fonts"):root_node.set_meta("farm_gles2_fonts",{})
 var fonts=root_node.get_meta("farm_gles2_fonts")
 var key=int(size_value)
 if not fonts.has(key):
  var font=DynamicFont.new()
  font.font_data=load("res://fonts/NotoSans-Regular.ttf")
  font.size=key
  font.use_filter=true
  fonts[key]=font
 return fonts[key]
static func texture(image):
 var tex=ImageTexture.new();tex.create_from_image(image,0);return tex
static func datetime_string():
 return str(OS.get_datetime())
static func wait(state):
 if state is GDScriptFunctionState and state.is_valid():
  yield(state,"completed")
 else:
  yield(Engine.get_main_loop(),"idle_frame")
static func make_dir(path):
 var d=Directory.new();return d.make_dir_recursive(path)
