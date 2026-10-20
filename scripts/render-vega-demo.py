"""Edit an OBS simulator-window recording. Never substitutes native Mac gameplay.
Requires Pillow, ffmpeg/ffprobe. Pass the completed OBS MOV as the first argument.
"""
from pathlib import Path
from datetime import datetime
import sys,json,subprocess,hashlib
from PIL import Image,ImageDraw,ImageFont
ROOT=Path(__file__).resolve().parents[1]; OUT=ROOT/'artifacts/demo-vega'; EDIT=OUT/'edit'; EDIT.mkdir(exist_ok=True)
raw=Path(sys.argv[1]).resolve()
marks=[json.loads(x) for x in (OUT/'raw/coop-events.jsonl').read_text().splitlines()]
result=next((m for m in marks if m.get('kind')=='result'),None)
assert result and result['success'] and not result['errors'], 'Completed successful guest route required'
info=json.loads(subprocess.check_output(['ffprobe','-v','error','-show_format','-of','json',str(raw)]))
creation=datetime.fromisoformat(info['format']['tags']['creation_time'].replace('Z','+00:00')).timestamp()
offset=marks[0]['epoch_ms']/1000-creation
assert 0<offset<90,offset
at=lambda label: next(m['elapsed'] for m in marks if m.get('label')==label)+offset
fontpath='/System/Library/Fonts/Avenir Next.ttc'
font=lambda n:ImageFont.truetype(fontpath,n)
BG='#10251d'; CREAM='#fff0c5'; GOLD='#e6bd67'; MUTED='#bbd0ba'
def run(args):
 p=subprocess.run([str(a) for a in args],stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
 if p.returncode:raise RuntimeError(p.stderr.decode()[-5000:])
def wrap(draw,text,size,width):
 lines=[];line=''
 for word in text.split():
  candidate=(line+' '+word).strip()
  if draw.textlength(candidate,font=font(size))>width and line:lines.append(line);line=word
  else:line=candidate
 if line:lines.append(line)
 return lines
segments=[
 ('intro',6,'BRACKENRIDGE FARM','A family co-op adventure. One farm. Two phones. Half the story each.',[(offset+1,6)],True),
 ('hook',8,'A SHARED FARM. DIFFERENT RESPONSIBILITIES.','Two players today, with a planned expansion to four.',[(at('arrival:0')+5,8)],False),
 ('sheep',10,'THE FLOCK HAS OTHER PLANS','Escaping sheep need a herder and a partner working the gate.',[(at('sheep:0')+.5,10)],False),
 ('gate',10,'SPLIT UP. WORK TOGETHER.','Keep the latch open while your partner guides the flock home.',[(at('planning_gate:0')-10,10)],False),
 ('repair',12,'COMMUNICATION IS THE MECHANIC','Diagnose the fault, find the right part, and balance pressure together.',[(at('repair')-3,9),(at('weather:0')-3,3)],False),
 ('clues',11,'NOBODY HAS THE WHOLE ANSWER','Private repair clues reproduced from this recorded run.',[],False),
 ('cultivate',11,'TURN SOIL INTO A HARVEST','Enter the tractor. Prepare the soil. Engage the next field tool.',[(at('weather:1')-12,11)],False),
 ('grow',12,'A FIELD THAT GROWS','Real crop stages, shown with cuts between stages.',[(at('weather:2')+.5,3),(at('weather:3')+.5,3),(at('weather:4')+.5,3),(at('weather:5')+.5,3)],False),
 ('harvest',11,'BEAT THE WEATHER AS A TEAM','Harvest the crop while your partner protects the farm’s supplies.',[(at('weather:6')-12,7),(at('planning_machine:6')-6,4)],False),
 ('dispatch',12,'ONE LAST DELIVERY','Combine buyer and stock clues. Pack both loads, then load together.',[(at('results:6')-12,12)],False),
 ('results',8,'ONE WEEKEND. SHARED SUCCESS.','Replay a new seeded weekend. Built for family fun on Fire TV.',[(at('results:6')+.2,5.5)],False),
]
manifest={'platform':'Official Vega Virtual Device, SDK 0.24.12112, host OpenGL','capture':'OBS window-only; camera/microphone/source audio muted','input':'Automated two-player inputs through existing host motors/collisions; no actor/crop teleports; not a human playtest','raw_file':str(raw),'raw_offset_seconds':offset,'guest_result':result,'audio':'Forest Ambience by TinyWorlds, CC0; quiet level/fades; no narration','segments':[]}
clock=0;srt=[]
for idx,(key,length,title,caption,clips,full) in enumerate(segments):
 print('Rendering',key,flush=True)
 panel=Image.new('RGBA',(1280,720),BG);d=ImageDraw.Draw(panel)
 d.text((24,9),'BRACKENRIDGE FARM',font=font(20),fill=GOLD)
 label='VEGA SIMULATOR • AUTOMATED 2-PLAYER INPUTS'
 d.text((1256-d.textlength(label,font=font(15)),12),label,font=font(15),fill=MUTED)
 d.line((24,41,1256,41),fill=GOLD,width=1)
 if clips:d.rectangle((128,44,1151,619),fill=(0,0,0,0))
 d.text((32,628),title,font=font(27),fill=GOLD)
 for j,line in enumerate(wrap(d,caption,20,1216)):d.text((32,669+j*25),line,font=font(20),fill=CREAM)
 if not clips:
  facts=next(m['private_facts'] for m in marks if m.get('label')=='repair')
  for player,x in [('1',32),('2',652)]:
   d.rounded_rectangle((x,110,x+596,573),radius=18,fill='#1d392c',outline=GOLD,width=2)
   d.text((x+24,133),'PLAYER '+player+' · PRIVATE CLUE',font=font(23),fill=GOLD)
   for j,line in enumerate(wrap(d,facts[player],23,548)):d.text((x+24,190+j*34),line,font=font(23),fill=CREAM)
  d.text((32,585),'Read your clue. Talk to your partner. Solve it together.',font=font(22),fill=MUTED)
 overlay=EDIT/f'{key}.png';panel.save(overlay);out=EDIT/f'{idx:02}-{key}.mp4'
 if clips:
  chunks=[]
  for ci,(start,seconds) in enumerate(clips):
   assert start>=0 and start+seconds<=float(info['format']['duration'])
   chunk=EDIT/f'{key}-{ci}.mp4';vf='fps=30'
   if not full:vf+=',crop=1188:668:46:52'
   vf+=',scale=1024:576:flags=lanczos,pad=1280:720:128:44:color=0x10251d'
   run(['ffmpeg','-v','error','-y','-ss',start,'-i',raw,'-t',seconds,'-an','-vf',vf,'-c:v','libx264','-preset','veryfast','-crf','18',chunk]);chunks.append(chunk)
  listing=EDIT/f'{key}-list.txt';listing.write_text(''.join(f"file '{p}'\n" for p in chunks));footage=EDIT/f'{key}-footage.mp4'
  run(['ffmpeg','-v','error','-y','-f','concat','-safe','0','-i',listing,'-c','copy',footage])
  run(['ffmpeg','-v','error','-y','-i',footage,'-loop','1','-i',overlay,'-filter_complex','[0:v]tpad=stop_mode=clone:stop_duration=8[bg];[bg][1:v]overlay=0:0,format=yuv420p[v]','-map','[v]','-t',length,'-r','30','-an','-c:v','libx264','-preset','veryfast','-crf','18',out])
 else:run(['ffmpeg','-v','error','-y','-loop','1','-i',overlay,'-t',length,'-r','30','-pix_fmt','yuv420p','-an','-c:v','libx264','-preset','veryfast','-crf','18',out])
 manifest['segments'].append({'key':key,'start':clock,'seconds':length,'title':title,'caption':caption,'source_clips':clips,'file':str(out.relative_to(ROOT))});srt.append((clock,clock+length,title+'. '+caption));clock+=length
assert clock<=120
listing=EDIT/'final-list.txt';listing.write_text(''.join(f"file '{ROOT/s['file']}'\n" for s in manifest['segments']))
silent=OUT/'brackenridge-farm-vega-silent.mp4'
run(['ffmpeg','-v','error','-y','-f','concat','-safe','0','-i',listing,'-c','copy','-movflags','+faststart',silent])
final=OUT/'brackenridge-farm-vega-demo.mp4'
run(['ffmpeg','-v','error','-y','-i',silent,'-stream_loop','-1','-i',ROOT/'source_assets/audio/demo/Forest_Ambience.mp3','-map','0:v','-map','1:a','-c:v','copy','-af',f'loudnorm=I=-25:TP=-3:LRA=7,afade=t=in:d=2,afade=t=out:st={clock-4}:d=4','-t',clock,'-c:a','aac','-b:a','160k','-ar','48000','-ac','2','-metadata','title=Brackenridge Farm — Vega Simulator Gameplay Demo','-movflags','+faststart',final])
def tc(t):
 ms=round(t*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
(OUT/'brackenridge-farm-vega-demo.en.srt').write_text(''.join(f'{i+1}\n{tc(a)} --> {tc(b)}\n{text}\n\n' for i,(a,b,text) in enumerate(srt)))
manifest.update(duration_seconds=clock,bytes=final.stat().st_size,sha256=hashlib.file_digest(final.open('rb'),'sha256').hexdigest())
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('DONE',final,clock,flush=True)
