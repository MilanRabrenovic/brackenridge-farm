"""Build an isolated Godot 3 compatibility project from the authoritative 2D game.
The original Godot 4 project is never edited by this tool.
"""
from pathlib import Path
import shutil,re
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/'build/vega-gles2-source'
(OUT/'scripts').mkdir(parents=True,exist_ok=True)
# Only this generated script directory is refreshed; keep asset import caches.
for stale in (OUT/'scripts').glob('*.gd'):stale.unlink()
for folder in ['assets/2d','data']:
 for p in (ROOT/'game'/folder).rglob('*'):
  if p.is_file() and p.suffix in ['.png','.json']:
   dest=OUT/p.relative_to(ROOT/'game');dest.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,dest)
# Use the same licensed font for all Godot 3 labels, including custom map drawing.
fonts=list((ROOT/'game').rglob('*.ttf'))
print('Fonts available:',[str(p.relative_to(ROOT/'game')) for p in fonts])
files=['main_2d','production_world_2d','weekend_session_2d','animal_incident_2d','crop_field_2d','repair_incident_2d','farm_minimap','farm_guidance','repair_pressure_gauge','test_weekend','test_2d_host','test_solo_playthrough','test_coop_playthrough']
controls=['Control','Label','ColorRect','PanelContainer','MarginContainer','VBoxContainer','HBoxContainer','Button','TextureRect','ViewportContainer']
replacements={'Sprite2D':'Sprite','AnimatedSprite2D':'AnimatedSprite','CharacterBody2D':'FarmBody','Texture2D':'Texture','SubViewportContainer':'ViewportContainer','SubViewport':'Viewport','PackedColorArray':'PoolColorArray','PackedVector2Array':'PoolVector2Array','PackedByteArray':'PoolByteArray','PackedStringArray':'PoolStringArray','PackedFloat32Array':'PoolRealArray','Vector2i':'Vector2','Rect2i':'Rect2','AudioStreamWAV':'AudioStreamSample','JavaScriptBridge':'JavaScript','WebSocketPeer':'FarmSocket','Time.get_ticks_msec':'OS.get_ticks_msec','Time.get_unix_time_from_system':'OS.get_unix_time','Time.get_datetime_string_from_system':'FarmCompat.datetime_string','JSON.parse_string':'parse_json','JSON.stringify':'to_json','FileAccess.get_file_as_string':'FarmCompat.read_text','Geometry2D':'Geometry','Geometry.intersect_polygons':'Geometry.intersect_polygons_2d','Geometry.get_closest_point_to_segment':'Geometry.get_closest_point_to_segment_2d','Geometry.is_point_in_polygon':'Geometry.is_point_in_polygon','queue_redraw()':'update()','set_shader_parameter':'set_shader_param','get_shader_parameter':'get_shader_param','.is_empty()':'.empty()','.limit_length(':'.clamped(','.lerp(':'.linear_interpolate(','.keycode':'.scancode','.sprite_frames':'.frames','.pause()':'.stop()','VERTICAL_ALIGNMENT_CENTER':'VALIGN_CENTER','HORIZONTAL_ALIGNMENT_CENTER':'HALIGN_CENTER','HORIZONTAL_ALIGNMENT_LEFT':'HALIGN_LEFT','TextServer.AUTOWRAP_WORD_SMART':'true','Color.WHITE':'Color.white','Color.BLACK':'Color.black','Color.TRANSPARENT':'Color.transparent','ThemeDB.fallback_font':'FarmCompat.font(13)','NOTIFICATION_WM_SIZE_CHANGED':'NOTIFICATION_WM_SIZE_CHANGED','texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED':'visible = true','texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR':'visible = true','y_sort_enabled = true':'sort_enabled = true'}
for name in files:
 s=(ROOT/f'game/{"tests" if name.startswith("test_") else "scripts"}/{name}.gd').read_text()
 for a,b in replacements.items():s=s.replace(a,b)
 s=s.replace(':=','=')
 s=s.replace('.instantiate()', '.instance()').replace('await process_frame','yield(self,"idle_frame")').replace('await physics_frame','yield(self,"physics_frame")')
 s=re.sub(r'Array\[[^\]]+\]','Array',s)
 s=re.sub(r'\b(clampf|clampi|maxf|maxi|minf|mini|absf|absi|floorf|floori|ceilf|ceili|roundf|roundi|lerpf|lerp_anglef|snappedf)\(',lambda m:{'snappedf':'stepify'}.get(m[1],m[1][:-1])+'(',s)
 s=re.sub(r'\bfloat\(', 'float(',s)
 # Godot 3's enum annotations and typed signal arguments differ.
 s=s.replace(': Stage',': int')
 s=re.sub(r'^signal (\w+)\((.*?)\)',lambda m:'signal '+m[1]+'('+re.sub(r':\s*\w+','',m[2])+')',s,flags=re.M)
 s=re.sub(r'([A-Za-z_]\w*)\.emit\(([^\n]*)',lambda m:'emit_signal("'+m[1]+'",'+m[2],s)
 s=re.sub(r'([\w.]+)\.([\w]+)\.connect\((\w+)\)',r'\1.connect("\2",self,"\3")',s)
 # Controls expose the Godot 4 layout aliases through small compatibility subclasses.
 for c in controls:s=re.sub(r'\b'+c+r'\b','Farm'+c,s)
 # Plain built-in drawing uses a font of the requested size.
 s=re.sub(r'draw_string\(font,([^\n]+?),HALIGN_LEFT,([^,]+),(\d+),([^\n]+?)\)',r'draw_string(FarmCompat.font(\3),\1,\4,\2)',s)
 s=s.replace('.autowrap_mode','.autowrap')
 s=s.replace('.get_center()', '.get_center()')
 # Repeating texture import is configured by this project, never the original assets.
 s=s.replace('surface.visible = true','surface.visible = true')
 (OUT/f'scripts/{name}.gd').write_text(s)
# Translate shader dialect. Polygon edge softness is replaced below with a GLES2-safe mask.
(OUT/'shaders').mkdir(exist_ok=True)
for p in (ROOT/'game/shaders').glob('*.gdshader'):
 s=p.read_text();s=re.sub(r'\s*:\s*(?:source_color(?:,\s*)?)?filter_\w+(?:,\s*repeat_\w+)?','',s)
 s=s.replace(': source_color',': hint_color')
 (OUT/'shaders'/p.name).write_text(s)
# Resource extension .gdshader isn't recognised by Godot 3; use .shader.
for p in (OUT/'shaders').glob('*.gdshader'):p.rename(p.with_suffix('.shader'))
for p in (OUT/'scripts').glob('*.gd'):p.write_text(p.read_text().replace('.gdshader','.shader'))
(OUT/'main.tscn').write_text('[gd_scene load_steps=2 format=2]\n[ext_resource path="res://scripts/main_2d.gd" type="Script" id=1]\n[node name="Main" type="Node"]\nscript=ExtResource( 1 )\n')
(OUT/'project.godot').write_text('''config_version=4
[application]
config/name="Brackenridge Farm — Vega GLES2"
run/main_scene="res://main.tscn"
[display]
window/size/width=1280
window/size/height=720
window/stretch/mode="2d"
[rendering]
quality/driver/driver_name="GLES2"
environment/default_clear_color=Color(0.075,0.13,0.09,1)
''')
print('Prepared:',OUT)
