"""Render a truthful narrated Mac-native preview from the recorded co-op route.
Requires ffmpeg/ffprobe, macOS say, and Pillow. Does not publish or imply TV proof.
"""
from pathlib import Path
import json, subprocess, textwrap, hashlib
from PIL import Image, ImageDraw, ImageFont, ImageFilter
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/demo'; RAW=OUT/'raw'; EDIT=OUT/'edit'; EDIT.mkdir(parents=True,exist_ok=True)
FONT='/System/Library/Fonts/Avenir Next.ttc'
BG='#10251d'; CREAM='#fff0c5'; MUTED='#bbd0ba'; GOLD='#e6bd67'
def run(args):
    subprocess.run([str(x) for x in args],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
def duration(p):
    return float(subprocess.check_output(['ffprobe','-v','error','-show_entries','format=duration','-of','csv=p=0',str(p)]))
def font(n):return ImageFont.truetype(FONT,n)
def wrapped(d,text,size,width):
    lines=[];line=''
    for w in text.split():
        if d.textlength((line+' '+w).strip(),font=font(size))>width and line:lines.append(line);line=w
        else:line=(line+' '+w).strip()
    if line:lines.append(line)
    return lines
marks=json.loads((RAW/'markers.json').read_text())
def at(label):return next(m['frame']/30 for m in marks if m['label']==label)
# Every moving excerpt is normal-speed recorded gameplay; gaps are edited out.
segments=[
 ('intro',6,'BRACKENRIDGE FARM','One farm. Two phones. Half the story each.', 'Brackenridge Farm. One farm. Two phones. Half the story each.',[(4,6)]),
 ('hook',9,'TOGETHER, WITH HALF THE STORY','A shared farm. Different jobs. Private information.', 'A cooperative farming weekend where both players share one farm, but each holds different information. Success starts with talking to your partner.',[(9,9)]),
 ('escape',11,'THE FLOCK HAS OTHER PLANS','The sheep escape. Split up, then work together.', 'The sheep jump the fence. One farmer guides the flock, while the other opens the gate. Rush too close, and the sheep scatter.',[(at('sheep:0')+.3,11)]),
 ('gate',9,'TWO ROLES, ONE GOAL','Guide the flock while your partner works the latch.', 'Keep the gate open and bring everyone home. When farmers separate, the camera splits. The minimap helps both players find their next job.',[(at('planning_gate:0')-10,9)]),
 ('repair',13,'COMMUNICATION IS THE MECHANIC','One diagnoses. One finds and fits the part.', 'The packing machine breaks down. The mechanic diagnoses the fault and balances pressure. Their partner finds the correct part, then fits it while the gauge stays green.',[(at('repair')-3,10),(at('weather:0')-3,3)]),
 ('clues',11,'DIFFERENT CLUES ON EACH PHONE','Private repair clues, reproduced from this recorded run.', 'One player knows which part is broken. The other knows where the spares are. Neither clue solves the problem alone. That is the heart of Brackenridge Farm.',[]),
 ('cultivate',11,'A FIELD THAT CHANGES AS YOU WORK','Prepare the soil. Engage the tool. Sow the field.', 'Climb into the tractor, prepare the soil, and deliberately engage the next field tool. Work the marked plots to turn unprepared ground into a growing crop.',[(at('weather:1')-12,11)]),
 ('grow',11,'FROM SEEDS TO HARVEST','Natural crop stages shown with edits between them.', 'Seeds become seedlings, then young plants and mature barley. These are the actual crop stages, edited together. Meanwhile, your partner seals storage and protects the apples.',[(at('weather:2')+1,2.5),(at('weather:3')+1,2.5),(at('weather:4')+1,2.5),(at('weather:5')+1,3.5)]),
 ('harvest',11,'BEAT THE WEATHER TOGETHER','Harvest barley and protect the farm’s supplies.', 'Harvest the barley and move it safely into storage. Different responsibilities keep both players useful, even when they are working on opposite sides of the farm.',[(at('weather:6')-12,7),(at('planning_machine:6')-6,4)]),
 ('dispatch',11,'FINISH AS A TEAM','Combine buyer and stock clues. Pack, then load together.', 'For the final delivery, combine buyer requirements with stock information. Pack both loads, meet at the van, and hold together to send the order on its way.',[(at('results:6')-11,11)]),
 ('results',8,'ONE WEEKEND. SHARED SUCCESS.','Play again with a new seed.', 'Results recognise the team’s work, with another seeded weekend ready to play. This preview was recorded on a Mac; Fire TV verification remains pending.',[(at('results:6')+.2,5.5)])
]
manifest={'platform':'Mac native Godot 4.7.2','input':'automated two-player input/physics route; no actor/crop teleports','qualifying_fire_tv_footage':False,'voice':'macOS Daniel synthetic English narration','music':'none','segments':[]}
SRT=[];clock=0
for idx,(key,length,title,caption,voice,clips) in enumerate(segments):
    print('Rendering',key,flush=True)
    aiff=EDIT/f'{key}.aiff'; speech=EDIT/f'{key}.txt'; speech.write_text(voice)
    run(['say','-v','Daniel','-r','175','-f',speech,'-o',aiff])
    spoken=duration(aiff)
    length=max(length,spoken+.65)
    panel=Image.new('RGBA',(1920,1080),BG);d=ImageDraw.Draw(panel)
    d.text((48,15),'BRACKENRIDGE FARM',font=font(30),fill=GOLD)
    label='MAC GAMEPLAY PREVIEW  •  AUTOMATED TWO-PLAYER INPUTS'
    d.text((1872-d.textlength(label,font=font(24)),22),label,font=font(24),fill=MUTED)
    if key not in ('intro','clues'):
        d.rounded_rectangle((188,60,1732,932),radius=8,fill=GOLD)
        d.rectangle((192,64,1728,928),fill=(0,0,0,0))
        d.text((192,944),f'{idx:02d}  /  {title}',font=font(33),fill=GOLD)
        for n,line in enumerate(wrapped(d,caption,34,1536)):d.text((192,993+n*40),line,font=font(34),fill=CREAM)
    elif key=='intro':
        d.text((170,180),'A COOPERATIVE FARMING WEEKEND',font=font(32),fill=GOLD)
        d.text((160,290),'Brackenridge',font=font(120),fill=CREAM)
        d.text((160,420),'Farm',font=font(140),fill=CREAM)
        d.text((170,660),'One farm. Two phones.',font=font(56),fill=GOLD)
        d.text((170,744),'Half the story each.',font=font(56),fill=CREAM)
        d.text((170,970),'Original illustrated farm • asymmetric co-op',font=font(30),fill=MUTED)
    else:
        d.text((115,135),'COMMUNICATION IS THE MECHANIC',font=font(57),fill=CREAM)
        d.text((115,220),'Private clues reproduced from the recorded session',font=font(30),fill=MUTED)
        for x,role,headline,lines in [
            (115,'PLAYER 1 · RUNNER','Where are the spares?', ['Feed store → belt','Workshop → gasket','Ask your partner which part is needed.']),
            (990,'PLAYER 2 · MECHANIC','What is broken?', ['Diagnosis: a belt is needed.','Hold to build pressure; release to cool.','Keep 40–75% GREEN while your partner fits.'])]:
            d.rounded_rectangle((x,330,x+815,835),radius=24,fill='#203c2c',outline=GOLD,width=3)
            d.text((x+38,375),role,font=font(27),fill=GOLD)
            d.text((x+38,447),headline,font=font(43),fill=CREAM)
            y=550
            for line in lines:
                for l in wrapped(d,line,33,735):d.text((x+38,y),l,font=font(33),fill=CREAM);y+=47
                y+=15
        d.text((115,937),'The answer lives between the two players.',font=font(44),fill=GOLD)
    overlay=EDIT/f'{key}-panel.png';panel.save(overlay)
    out=EDIT/f'{idx:02d}-{key}.mp4'
    # Create a source montage before the deterministic overlay and narration.
    footage=EDIT/f'{key}-footage.mp4'
    if clips:
        chunks=[]
        for ci,(start,seconds) in enumerate(clips):
            chunk=EDIT/f'{key}-{ci}.mp4'
            run(['ffmpeg','-hide_banner','-loglevel','error','-y','-ss',start,'-i',RAW/'co-op-native.avi','-t',seconds,'-an','-vf','fps=30','-c:v','libx264','-preset','veryfast','-crf','20',chunk]);chunks.append(chunk)
        listing=EDIT/f'{key}-list.txt';listing.write_text(''.join(f"file '{p}'\n" for p in chunks))
        run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',listing,'-c','copy',footage])
        if key=='intro':
            # Cropped real farm image as a quiet background on the title's right.
            graph='[0:v]tpad=stop_mode=clone:stop_duration=120,scale=1920:1080,boxblur=8:1,colorchannelmixer=rr=.34:gg=.42:bb=.34[bg];[bg][1:v]overlay=0:0,format=yuv420p[v]'
        else:
            graph='[0:v]tpad=stop_mode=clone:stop_duration=120,scale=1536:864,pad=1920:1080:192:64:color=0x10251d[bg];[bg][1:v]overlay=0:0,format=yuv420p[v]'
        cmd=['ffmpeg','-hide_banner','-loglevel','error','-y','-i',footage,'-loop','1','-i',overlay,'-i',aiff,'-filter_complex',graph,'-map','[v]','-map','2:a','-af',f'apad,afade=t=out:st={length-.25}:d=0.25','-t',length,'-r','30','-c:v','libx264','-preset','veryfast','-crf','20','-c:a','aac','-b:a','192k','-ar','48000','-ac','2','-movflags','+faststart',out]
    else:
        cmd=['ffmpeg','-hide_banner','-loglevel','error','-y','-loop','1','-i',overlay,'-i',aiff,'-map','0:v','-map','1:a','-af','apad','-t',length,'-r','30','-c:v','libx264','-preset','veryfast','-crf','20','-pix_fmt','yuv420p','-c:a','aac','-b:a','192k','-ar','48000','-ac','2','-movflags','+faststart',out]
    run(cmd)
    # Divide the narration into readable sentence captions with proportional timing.
    sentences=[v.strip()+'.' for v in voice.rstrip('.').split('. ') if v.strip()]
    cursor=clock;total=sum(len(s) for s in sentences)
    for sentence in sentences:
        sec=spoken*len(sentence)/total
        SRT.append((cursor,cursor+sec,sentence));cursor+=sec
    manifest['segments'].append({'key':key,'title':title,'start':clock,'seconds':length,'narration':voice,'source_clips':clips,'speech_seconds':spoken,'file':str(out.relative_to(ROOT))});clock+=length
    if clock>120:raise RuntimeError(f'Video exceeds two minutes ({clock})')
def tc(t):
    ms=round(t*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
srt=OUT/'brackenridge-farm-demo.en.srt';srt.write_text(''.join(f'{i+1}\n{tc(a)} --> {tc(b)}\n{text}\n\n' for i,(a,b,text) in enumerate(SRT)))
listing=EDIT/'final-list.txt';listing.write_text(''.join(f"file '{ROOT/s['file']}'\n" for s in manifest['segments']))
final=OUT/'brackenridge-farm-demo-en.mp4'
run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',listing,'-i',srt,'-map','0:v','-map','0:a','-map','1:0','-c:v','copy','-c:a','copy','-c:s','mov_text','-metadata:s:s:0','language=eng','-metadata:s:a:0','language=eng','-metadata','title=Brackenridge Farm — Cooperative Gameplay Preview','-movflags','+faststart',final])
manifest.update(duration_seconds=duration(final),bytes=final.stat().st_size,sha256=hashlib.file_digest(final.open('rb'),'sha256').hexdigest())
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
(OUT/'narration.txt').write_text('\n\n'.join(s['narration'] for s in manifest['segments'])+'\n')
assert manifest['duration_seconds']<=120
print('DONE',final,manifest['duration_seconds'],flush=True)
