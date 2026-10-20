"""Repeatable local WebGL1 compatibility build; requires verified Godot 3.6.3 tools."""
from pathlib import Path
import subprocess,sys,os,re,shutil,hashlib
ROOT=Path(__file__).resolve().parents[2]
EDITOR=Path(os.environ.get('GODOT3_BIN',str(ROOT/'.tools/godot3/Godot.app/Contents/MacOS/Godot')))
SOURCE=ROOT/'build/vega-gles2-source'
LOGS=ROOT/'.tools/godot3'
for name in ['prepare','patch','normalise']:
 subprocess.run([sys.executable,str(Path(__file__).with_name(name+'.py'))],cwd=ROOT,check=True)
SOURCE.joinpath('export_presets.cfg').write_text('''[preset.0]
name="HTML5"
platform="HTML5"
runnable=true
export_filter="all_resources"
include_filter="*.json,*.ttf"
exclude_filter="scripts/test_*"
export_path="../web/vega-gles2/index.html"
[preset.0.options]
custom_template/release="'''+os.environ.get('GODOT3_WEB_TEMPLATE',str(ROOT/'.tools/godot3/templates/webassembly_release.zip'))+'''"
html/export_icon=false
html/canvas_resize_policy=2
html/focus_canvas_on_start=true
vram_texture_compression/for_desktop=true
vram_texture_compression/for_mobile=false
''')
(ROOT/'build/web/vega-gles2').mkdir(exist_ok=True)
def run(name,args,timeout=300):
 env=os.environ.copy();env['FARM_RELAY_URL']='ws://127.0.0.1:8787/ws'
 with (LOGS/(name+'.log')).open('w') as log:
  result=subprocess.run([str(EDITOR),'--path',str(SOURCE),'--no-window']+args,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=timeout)
 text=(LOGS/(name+'.log')).read_text()
 if result.returncode or re.search(r'SCRIPT ERROR:|Parse Error:|Shader error:|ERROR:',text):
  print(text[-8000:]);raise SystemExit(name+' failed; see '+str(LOGS/(name+'.log')))
 print(name+': passed')
# Cache the exact terrain composite across test/export invocations.
hash_inputs=[ROOT/'game/shaders/cohesive_ground.gdshader',Path(__file__).with_name('bake_ground.gd')]
hash_inputs+=sorted((ROOT/'game/assets/2d/production').glob('cohesive_*.png'))
hash_inputs.append(ROOT/'game/assets/2d/production/reference_meadow.png')
hash_inputs.append(ROOT/'game/data/world_layout.json')
hash_inputs.append(ROOT/'game/shaders/clean_sprite.gdshader')
hash_inputs+=sorted((ROOT/'game/assets/2d/production').glob('reference_*.png'))
digest=hashlib.sha256(b''.join(p.read_bytes() for p in hash_inputs)).hexdigest()
stamp=SOURCE/'terrain-bake.sha256'
if not stamp.exists() or stamp.read_text()!=digest or not (SOURCE/'assets/2d/production/vega_baked_ground.png').exists():
 run('bake-import',['--export','HTML5'])
 run('bake-ground',['--script','res://bake_ground.gd'])
 run('bake-texture-import',['--export','HTML5'])
 stamp.write_text(digest)
if '--test' in sys.argv:
 for test in ['weekend','2d_host','solo_playthrough','coop_playthrough']:run('test-'+test,['--script','res://scripts/test_'+test+'.gd'])
if '--export' in sys.argv:
 run('port-export',['--export','HTML5'])
 notices=ROOT/'build/web/vega-gles2/licenses';notices.mkdir(exist_ok=True)
 for source in (ROOT/'platform/vega-gles2/licenses').glob('*.txt'):shutil.copy2(source,notices/source.name)
 shutil.copy2(ROOT/'platform/vega-gles2/fonts/OFL.txt',notices/'NotoSans-OFL.txt')
 shutil.copy2(ROOT/'THIRD_PARTY_NOTICES.md',ROOT/'build/web/vega-gles2/THIRD_PARTY_NOTICES.md')
