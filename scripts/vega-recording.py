"""Prepare an isolated Vega gameplay route and collect timing markers for OBS footage.
No desktop capture or Mac simulation. Run `prepare`, then `serve` in another terminal.
"""
from pathlib import Path
import sys, shutil, json, subprocess, re
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/demo-vega';RAW=OUT/'raw';RAW.mkdir(parents=True,exist_ok=True)
JS=ROOT/'scripts/vega-recorder.js'
def install_recorder(folder,mode):
 shutil.copy2(JS,folder/'vega-recorder.js')
 p=folder/'index.html';s=p.read_text().replace('</body>',f'<script>window.FARM_RECORDING_MODE="{mode}";</script><script src="vega-recorder.js"></script></body>');p.write_text(s)
if len(sys.argv)>1 and sys.argv[1]=='prepare':
 live=ROOT/'build/web/vega-record-live';shutil.copytree(ROOT/'build/web/vega-gles2',live,dirs_exist_ok=True);install_recorder(live,'live')
 src=ROOT/'build/vega-record-source';shutil.copytree(ROOT/'build/vega-gles2-source',src,dirs_exist_ok=True)
 for name in ['test_solo_playthrough','test_coop_playthrough']:
  p=src/f'scripts/{name}.gd';s=p.read_text()
  s=s.replace('Engine.iterations_per_second=600','Engine.iterations_per_second=60').replace('Engine.time_scale=10','Engine.time_scale=1').replace('Engine.target_fps=0','Engine.target_fps=60')
  s=re.sub(r'(?<![\w.])quit\(', '_finish(',s)
  if name=='test_solo_playthrough':
   s+='''
func _finish(code=0):
 if OS.has_feature("JavaScript"):
  JavaScript.eval("window.finishFarmRecording("+to_json({"success":code==0,"errors":errors,"simulated_seconds":simulated_seconds})+")")
 else:quit(code)
'''
  else:
   s=s.replace('session.sound_enabled=false','''if OS.has_feature("JavaScript"):
\t\tJavaScript.eval("window.__brackenridgeDemoReady=true")
\t\twhile not JavaScript.eval("window.__farmRecordingActive===true"):
\t\t\tyield(self,"idle_frame")
\tsession.sound_enabled=false''')
   # Marks use real elapsed capture time; the route itself is unchanged.
   s=s.replace('var route_seed = 1731','var route_seed = 1731\nvar last_record_state=""')
   s=s.replace('simulated_seconds+=DT','''simulated_seconds+=DT
\tvar record_state="%s:%d"%[session.phase,int(host.world_root.crop_field.stage)]
\tif record_state!=last_record_state:
\t\tlast_record_state=record_state
\t\t_record_mark(record_state)''')
   a=s.index('func capture_view(');b=s.index('\nfunc verify()',a)
   s=s[:a]+'''func capture_view(label):
 _record_mark(label)
 yield(self,"idle_frame")

func _record_mark(label):
 if OS.has_feature("JavaScript"):
  JavaScript.eval("window.farmDemoMark("+to_json({"label":label,"simulated_seconds":simulated_seconds,"phase":session.phase,"crop_stage":int(host.world_root.crop_field.stage),"private_facts":host.mission_facts})+")")
'''+s[b:]
   s=s.replace('companion_hold=false\n\tsession.restart(1732)','companion_hold=false\n\tyield(FarmCompat.wait(hold_for(6)),"completed")\n\tsession.restart(1732)')
  p.write_text(s)
 cfg=src/'export_presets.cfg';s=cfg.read_text().replace('exclude_filter="scripts/test_*"','exclude_filter=""').replace('../web/vega-gles2/index.html','../web/vega-record-coop/index.html');cfg.write_text(s)
 coop=ROOT/'build/web/vega-record-coop';coop.mkdir(exist_ok=True)
 editor=ROOT/'.tools/godot3/Godot.app/Contents/MacOS/Godot'
 with (OUT/'export.log').open('w') as log:
  result=subprocess.run([str(editor),'--path',str(src),'--no-window','--export','HTML5'],stdout=log,stderr=subprocess.STDOUT,timeout=180)
 text=(OUT/'export.log').read_text()
 if result.returncode or re.search('SCRIPT ERROR:|Parse Error:|ERROR:',text):raise SystemExit(text[-6000:])
 html=coop/'index.html';s=html.read_text().replace('"args":[]','"args":["--script","res://scripts/test_coop_playthrough.gd"]');html.write_text(s);install_recorder(coop,'coop')
 print('Prepared live and automated co-op recording routes. Runtime game unchanged.')
elif len(sys.argv)>1 and sys.argv[1]=='serve':
 class Handler(BaseHTTPRequestHandler):
  def log_message(self,*args):pass
  def headers_ok(self):
   self.send_header('Access-Control-Allow-Origin','http://127.0.0.1:8787')
   self.send_header('Access-Control-Allow-Methods','POST, OPTIONS')
   self.send_header('Access-Control-Allow-Headers','Content-Type')
  def do_OPTIONS(self):
   self.send_response(204);self.headers_ok();self.end_headers()
  def do_POST(self):
   parts=self.path.split('?',1)[0].strip('/').split('/')
   if len(parts)!=2 or parts[0] not in ['live','coop'] or parts[1] not in ['start','chunk','event']:
    self.send_error(404);return
   size=int(self.headers.get('Content-Length','0'))
   if size>16*1024*1024:self.send_error(413);return
   mode,kind=parts;data=self.rfile.read(size)
   if kind=='start':
    (RAW/f'{mode}.webm').write_bytes(b'');(RAW/f'{mode}-events.jsonl').write_text('')
   elif kind=='chunk':
    with (RAW/f'{mode}.webm').open('ab') as f:f.write(data)
   else:
    event=json.loads(data)
    with (RAW/f'{mode}-events.jsonl').open('a') as f:f.write(json.dumps(event)+'\n')
    print(mode,event.get('kind'),event.get('label',''),event.get('elapsed',0),flush=True)
   self.send_response(200);self.headers_ok();self.end_headers();self.wfile.write(b'OK')
 print('Recording collector: localhost:8790; reverse 8790 into Vega.',flush=True)
 ThreadingHTTPServer(('127.0.0.1',8790),Handler).serve_forever()
else:raise SystemExit('Use prepare or serve')
