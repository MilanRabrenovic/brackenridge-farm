from pathlib import Path
import re,shutil
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'build/vega-gles2-source'
for p in (ROOT/'platform/vega-gles2/compat').glob('*.gd'):shutil.copy2(p,OUT/'scripts'/p.name)
for p in (OUT/'scripts').glob('*.gd'):
 s=p.read_text()
 if p.name.startswith('farm_') and p.name not in ['farm_minimap.gd','farm_guidance.gd']:continue
 s=s.replace('RectangleShape2D','FarmRectangle').replace('.move_and_slide()','.step_motion()').replace('ImageTexture.create_from_image(image)','FarmCompat.texture(image)').replace('OS.has_feature("web")','OS.has_feature("JavaScript")').replace('"JavaScript"','"JavaScript"')
 s=s.replace('extends Node2D\n','extends YSort\n') if p.name=='production_world_2d.gd' else s
 s=re.sub(r'([\w.]+)\.assign\(([^\n]+?)\)',r'\1=\2',s)
 s=s.replace('var file=FileAccess.open("user://last_weekend.json",FileAccess.WRITE)','var file=File.new();file.open("user://last_weekend.json",File.WRITE)')
 s=s.replace('error_string(error)','str(error)').replace('ceil(time_left)%60','int(ceil(time_left))%60')
 s=s.replace('draw_circle(point,7,Color(1,.9,.6,.85),false,2)','draw_arc(point,7,0,TAU,48,Color(1,.9,.6,.85),2,true)')
 s=re.sub(r'\bseed\b','noise_seed',s) if p.name=='crop_field_2d.gd' else s
 s=s.replace('var query=PhysicsShapeQueryParameters2D.new()','var query=Physics2DShapeQueryParameters.new()').replace('query.shape=shape','query.set_shape(shape)').replace('query.collision_mask=1','query.collision_layer=1')
 # Class connections without a dotted receiver.
 s=re.sub(r'\b([a-z_]+)\.connect\((_[a-z_]+)\)',r'connect("\1",self,"\2")',s)
 if p.name=='main_2d.gd':
  s=s.replace('NOTIFICATION_WM_SIZE_CHANGED','100000').replace('func _ready() -> void:', 'func _ready() -> void:\n\tget_viewport().connect("size_changed",self,"_apply_view_layout")')
  s=s.replace('camera.enabled = true','camera.current = true').replace('camera.zoom = Vector2(1.34, 1.34)','camera.zoom = Vector2(1.0/1.34, 1.0/1.34)').replace('Vector2(zoom_value, zoom_value)','Vector2(1.0/zoom_value, 1.0/zoom_value)')
 if p.name=='production_world_2d.gd':
  s=s.replace('panel.visibility_changed.connect(func(): pointer.visible = panel.visible)','panel.connect("visibility_changed",self,"_marker_visibility",[panel,pointer])')
  a=s.index('\tinterior.body_entered.connect(func(body):');b=s.index('\tif not label_text.empty():',a)
  s=s[:a]+'''\tinterior.connect("body_entered",self,"_interior_entered",[occupants,sprite,floor])
\tinterior.connect("body_exited",self,"_interior_exited",[occupants,sprite,floor])
'''+s[b:]
  a=s.index('\treveal.body_entered.connect(func(body_entered):');b=s.index('\nfunc _build_boundaries()',a)
  s=s[:a]+'''\treveal.connect("body_entered",self,"_tree_entered",[occupants,sprite])
\treveal.connect("body_exited",self,"_tree_exited",[occupants,sprite])
'''+s[b:]
  s+='''
func _marker_visibility(panel,pointer):pointer.visible=panel.visible
func _interior_entered(body,occupants,sprite,floor):
 if str(body.name).begins_with("Player"):
  occupants.count+=1;sprite.modulate.a=.12;floor.visible=true
func _interior_exited(body,occupants,sprite,floor):
 if str(body.name).begins_with("Player"):
  occupants.count=max(0,occupants.count-1);sprite.modulate.a=.12 if occupants.count>0 else 1.0;floor.visible=occupants.count>0
func _tree_entered(body,occupants,sprite):
 if str(body.name).begins_with("Player"):occupants.count+=1;sprite.modulate.a=.56
func _tree_exited(body,occupants,sprite):
 if str(body.name).begins_with("Player"):occupants.count=max(0,occupants.count-1);sprite.modulate.a=.56 if occupants.count>0 else 1.0
'''
 if p.name=='weekend_session_2d.gd':
  s=s.replace('replay_button.pressed.connect(func(): restart(seed_value+1))','replay_button.connect("pressed",self,"_replay_pressed")')
  s=s.replace('results_panel.resized.connect(func(): results_panel.position=(host.get_viewport().get_visible_rect().size-results_panel.size)*.5)','results_panel.connect("resized",self,"_centre_results")')
  s+='\nfunc _replay_pressed():restart(seed_value+1)\nfunc _centre_results():results_panel.position=(host.get_viewport().get_visible_rect().size-results_panel.size)*.5\n'
 p.write_text(s)
# Use one packed vector set through separate uniforms: GLES2 disallows uniform arrays.
p=OUT/'scripts/crop_field_2d.gd';s=p.read_text();s=s.replace('edge_material.set_shader_param("edge_points",padded_points)','\n\tfor i in range(16):edge_material.set_shader_param("edge_point%d"%i,padded_points[i])');p.write_text(s)
p=OUT/'shaders/crop_surface.shader';s=p.read_text().replace('uniform vec2 edge_points[16];','\n'.join('uniform vec2 edge_point%d;'%i for i in range(16)))
a=s.index(' for(int i=0;');b=s.index(' float noise=',a)
s=s[:a]+''.join(' if(point_count>%d){vec2 a=edge_point%d,b=edge_point%d;vec2 ab=b-a;float t=clamp(dot(ground_position-a,ab)/max(.001,dot(ab,ab)),0.0,1.0);d=min(d,length(ground_position-a-t*ab));}\n'%(i,i,(i+1)%8) for i in range(8))+s[b:]
# Actual field polygon closes at point_count, so replace last endpoint safely.
s=s.replace('b=edge_point7','b=(point_count==7?edge_point0:edge_point7)').replace('b=edge_point0;vec2 ab','b=edge_point0;vec2 ab')
p.write_text(s)

p=OUT/"scripts/production_world_2d.gd";p.write_text(re.sub(r"\bfloor\b","interior_floor",p.read_text()))
for p in (OUT/'scripts').glob('*.gd'):
 if p.name.startswith('farm_') and p.name not in ['farm_minimap.gd','farm_guidance.gd']:continue
 s=p.read_text()
 s=re.sub(r'Farm(Control|Label|ColorRect|PanelContainer|MarginContainer|VBoxContainer|HBoxContainer|Button|TextureRect|ViewportContainer)\.([A-Z_]+)',lambda m:m[0] if m[2]=='EXPAND_IGNORE_SIZE' else m[1]+'.'+m[2],s)
 s=s.replace('discovery.bind(','discovery.listen(').replace('; ring.closed = true','')
 s=s.replace('bytes.encode_s16(i*2,value)','bytes[i*2]=value & 255;bytes[i*2+1]=(value >> 8) & 255')
 p.write_text(s)
for p in (OUT/'scripts').glob('farm_*.gd'):
 if p.name in ['farm_minimap.gd','farm_guidance.gd','farm_compat.gd','farm_body.gd','farm_socket.gd','farm_rectangle.gd','farm_performance.gd']:continue
 s=p.read_text()+'\nvar z_index=0 setget set_z_alias\nfunc set_z_alias(value):\n z_index=value;VisualServer.canvas_item_set_z_index(get_canvas_item(),value)\n'
 p.write_text(s)
for p in (OUT/'scripts').glob('*.gd'):
 s=p.read_text().replace('Control.PRESET_FULL_RECT','Control.PRESET_WIDE').replace('as FarmControl','as Control')
 p.write_text(s)
for p in (OUT/'scripts').glob('*.gd'):
 s=p.read_text().replace('BoxContainer.ALIGNMENT_CENTER','BoxContainer.ALIGN_CENTER')
 p.write_text(s)
(OUT/'fonts').mkdir(exist_ok=True)
for p in (ROOT/'platform/vega-gles2/fonts').glob('*'):shutil.copy2(p,OUT/'fonts'/p.name)
# Godot 3 template doesn't expose Godot 4's readiness flag: report from real room creation.
p=OUT/'scripts/main_2d.gd';s=p.read_text().replace('print("PROBE_ROOM=%s" % room)','''print("PROBE_ROOM=%s" % room)
\t\t\tif OS.has_feature("JavaScript"):
\t\t\t\tJavaScript.eval("window.ReactNativeWebView && window.ReactNativeWebView.postMessage(JSON.stringify({source:'farm-startup',kind:'canvas',ready:true,canvas:[1280,720],bounds:[1280,720],visibility:'visible'}))")''');p.write_text(s)
# Preserve outlined TV labels using DynamicFont's Godot 3 outline properties.
for p in (OUT/'scripts').glob('farm_*.gd'):
 if 'func add_theme_color_override' not in p.read_text():continue
 s=p.read_text().replace('func add_theme_color_override(key,value):add_color_override(key,value)','''func add_theme_color_override(key,value):
 if key=="font_outline_color":
  var f=get_font("font");f.outline_color=value
 else:add_color_override(key,value)''').replace('func add_theme_constant_override(key,value):add_constant_override(key,value)','''func add_theme_constant_override(key,value):
 if key=="outline_size":
  var f=get_font("font");f.outline_size=value
 else:add_constant_override(key,value)''')
 p.write_text(s)
p=OUT/'scripts/test_weekend.gd';s=p.read_text().replace('repair.required_part.to_upper() not in host.latest_clues[2]','not repair.required_part.to_upper() in host.latest_clues[2]').replace('"DIAGNOSIS" not in host.latest_clues[1]','not "DIAGNOSIS" in host.latest_clues[1]');p.write_text(s)
p=OUT/'scripts/animal_incident_2d.gd';s=p.read_text().replace('var seconds = ceil(time_left)','var seconds = int(ceil(time_left))');p.write_text(s)
# Exact polygon closure with statically named uniforms; no GLES2 array indexing.
p=OUT/'shaders/crop_surface.shader';s=p.read_text();a=s.index(' if(point_count>');b=s.index(' float noise=',a)
s=s[:a]+''.join(' if(point_count>%d){vec2 a=edge_point%d,b=(point_count==%d?edge_point0:edge_point%d);vec2 ab=b-a;float t=clamp(dot(ground_position-a,ab)/max(.001,dot(ab,ab)),0.0,1.0);d=min(d,length(ground_position-a-t*ab));}\n'%(i,i,i+1,(i+1)%16) for i in range(16))+s[b:];p.write_text(s)
for p in (OUT/'scripts').glob('*.gd'):
 s=p.read_text().replace('.orthogonal()','.tangent()').replace('.clamped(','.limit_length(')
 p.write_text(s)
for name in ['test_solo_playthrough','test_coop_playthrough']:
 p=OUT/('scripts/'+name+'.gd');s=p.read_text().replace('res://tests/test_solo_playthrough.gd','res://scripts/test_solo_playthrough.gd')
 s=s.replace('Engine.physics_ticks_per_second','Engine.iterations_per_second').replace('Engine.max_fps','Engine.target_fps').replace('OS.get_cmdline_user_args()','OS.get_cmdline_args()').replace('RenderingServer.frame_post_draw','VisualServer.frame_post_draw').replace('await VisualServer.frame_post_draw','yield(VisualServer,"frame_post_draw")').replace('.get_image()','.get_data()')
 s=s.replace('DirAccess.make_dir_recursive_absolute','FarmCompat.make_dir')
 s=s.replace('PhysicsShapeQueryParameters2D','Physics2DShapeQueryParameters').replace('q.shape=shape','q.set_shape(shape)').replace('q.collision_mask','q.collision_layer')
 # Wrap function awaits, preserving same-frame release/action semantics.
 lines=[]
 for line in s.splitlines():
  while 'await ' in line:
   start=line.index('await ');a=start+6;depth=0;quote=None;end=None
   for i in range(a,len(line)):
    c=line[i]
    if quote:
     if c==quote and line[i-1]!='\\':quote=None
    elif c in '\"\'':quote=c
    elif c=='(':depth+=1
    elif c==')':
     depth-=1
     if depth==0:end=i+1;break
   if end is None:raise ValueError(line)
   line=line[:start]+'yield(FarmCompat.wait('+line[a:end]+'),"completed")'+line[end:]
  lines.append(line)
 p.write_text('\n'.join(lines)+'\n')
for name in ['test_solo_playthrough','test_coop_playthrough']:
 p=OUT/('scripts/'+name+'.gd');s=p.read_text()
 s=s.replace('host.world_root.crop_field.stage_changed.connect(func(_label):stages[int(host.world_root.crop_field.stage)]=true)','host.world_root.crop_field.connect("stage_changed",self,"_record_crop_stage",[stages])')
 if name=='test_solo_playthrough':s+='\nfunc _record_crop_stage(_label,stages):stages[int(host.world_root.crop_field.stage)]=true\n'
 p.write_text(s)
p=OUT/'scripts/test_solo_playthrough.gd';s=p.read_text().replace('host.world_root.crop_field.stage_changed.connect(func(_label):observed_stages[int(host.world_root.crop_field.stage)]=true)','host.world_root.crop_field.connect("stage_changed",self,"_record_crop_stage",[observed_stages])');p.write_text(s)
for name in ['test_solo_playthrough','test_coop_playthrough']:
 p=OUT/('scripts/'+name+'.gd');s=p.read_text().replace('root.size=Vector2(1280,720)','root.set_size(Vector2(1280,720))');p.write_text(s)
# Godot 3 bypasses setget for bare inherited member access in child scripts.
for name in ['farm_minimap','farm_guidance','repair_pressure_gauge']:
 p=OUT/('scripts/'+name+'.gd');s=p.read_text()
 for old,new in [('size','rect_size'),('position','rect_position'),('custom_minimum_size','rect_min_size')]:
  s=re.sub(r'(?<![.\w])'+old+r'\b',new,s)
 p.write_text(s)
# Avoid rendering a covered full-map root pass and a hidden second camera.
p=OUT/'scripts/main_2d.gd';s=p.read_text().replace('func _build_render_views() -> void:', 'func _build_render_views() -> void:\n\tget_viewport().canvas_transform=Transform2D(0,Vector2(10000,10000))')
s=s.replace('func _apply_view_layout() -> void:', 'func _apply_view_layout() -> void:\n\tif right_camera:right_camera.get_viewport().render_target_update_mode=Viewport.UPDATE_ALWAYS if split_screen else Viewport.UPDATE_DISABLED')
p.write_text(s)

p=OUT/'scripts/main_2d.gd';p.write_text(p.read_text().replace('window.ReactNativeWebView && window.ReactNativeWebView.postMessage','window.__brackenridgeStarted=true;window.ReactNativeWebView && window.ReactNativeWebView.postMessage'))
# Godot 3 parses eight-digit HTML strings as ARGB; Godot 4 uses RGBA.
for p in (OUT/'scripts').glob('*.gd'):
 s=re.sub(r'Color\("#([0-9a-fA-F]{6})([0-9a-fA-F]{2})"\)',lambda m:'Color("#'+m[2]+m[1]+'")',p.read_text());p.write_text(s)
# Precompute the unchanged static terrain; retain a separate animated water layer.
p=OUT/'scripts/production_world_2d.gd';s=p.read_text()
a=s.index('\tvar ground = Sprite.new(); ground.name = "BlendedCountryside"')
b=s.index('\tfor district in layout.districts:',a)
s=s[:a]+'''\tvar ground=Sprite.new();ground.name="BlendedCountryside"
\tground.texture=load("res://assets/2d/production/vega_baked_ground.png")
\tground.centered=false;ground.position=Vector2(-170,-120);ground.z_index=-100;add_child(ground)
\tvar water=Sprite.new();water.name="AnimatedRiverSurface"
\twater.texture=load("res://assets/2d/production/cohesive_ground_mask.png")
\twater.centered=false;water.scale=Vector2(2.4,2.4);water.position=ground.position;water.z_index=-99
\tvar water_material=ShaderMaterial.new();water_material.shader=load("res://shaders/water_surface.shader")
\twater_material.set_shader_param("water_tex",load("res://assets/2d/production/cohesive_water.png"))
\twater.material=water_material
	var water_bounds=parse_json(FarmCompat.read_text("res://data/vega_water_bounds.json"))
	water.region_enabled=true;water.region_rect=Rect2(water_bounds[0],water_bounds[1],water_bounds[2],water_bounds[3])
	water.position+=water.region_rect.position*2.4;add_child(water)
'''+s[b:]
p.write_text(s)
shutil.copy2(ROOT/'platform/vega-gles2/water_surface.shader',OUT/'shaders/water_surface.shader')
shutil.copy2(ROOT/'platform/vega-gles2/bake_ground.gd',OUT/'bake_ground.gd')
p=OUT/'scripts/main_2d.gd';s=p.read_text().replace('func _ready() -> void:','func _ready() -> void:\n\tadd_child(preload("res://scripts/farm_performance.gd").new())');p.write_text(s)

# Alpha-fleck cleanup is static; bake it once instead of sampling five textures
# per building pixel on every frame. Individual sprites/cutaways stay separate.
p=OUT/'scripts/production_world_2d.gd';s=p.read_text()
s=s.replace('"res://assets/2d/production/%s.png" % building.asset','"res://assets/2d/production/vega_clean_%s.png" % building.asset')
s=s.replace('art.material = clean','art.material = null')
p.write_text(s)
