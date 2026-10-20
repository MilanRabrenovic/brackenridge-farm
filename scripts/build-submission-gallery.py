"""Compose Devpost gallery cards from actual native-route frames; no invented gameplay."""
from pathlib import Path
import subprocess, json
from PIL import Image, ImageDraw, ImageFont
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'artifacts/submission/gallery-v1';OUT.mkdir(parents=True,exist_ok=True)
SRC=ROOT/'source_assets/2d/marketing/gallery-v1';SRC.mkdir(parents=True,exist_ok=True)
RAW=ROOT/'artifacts/demo/raw/co-op-native.avi'
FONT='/System/Library/Fonts/Avenir Next.ttc'
BG='#10251d';CREAM='#fff0c5';GOLD='#e6bd67';MUTED='#c4d9c0'
def f(n):return ImageFont.truetype(FONT,n)
def wrap(d,text,size,width):
 lines=[];s=''
 for word in text.split():
  if s and d.textlength(s+' '+word,font=f(size))>width:lines.append(s);s=word
  else:s=(s+' '+word).strip()
 if s:lines.append(s)
 return lines
cards=[
 ('01-family-teamwork',28,'Family teamwork. One shared farm.','Guide the flock while your partner keeps the gate open.'),
 ('02-private-clues',110,'Different clues. One shared repair.','Players combine private information and complementary actions.'),
 ('03-farming-together',271,'Prepare. Sow. Grow. Harvest.','Drive the tractor while your partner protects supplies and prepares storage.'),
 ('04-shared-results',351,'A weekend you finish together.','Two-player co-op today. Four-player family play is planned.')
]
manifest=[]
for name,t,title,sub in cards:
 frame=SRC/(name+'-gameplay.png')
 subprocess.run(['ffmpeg','-v','error','-y','-ss',str(t),'-i',str(RAW),'-frames:v','1',str(frame)],check=True)
 im=Image.new('RGB',(1536,1024),BG);d=ImageDraw.Draw(im)
 d.text((30,10),'BRACKENRIDGE FARM',font=f(21),fill=GOLD)
 d.text((30,36),title,font=f(39),fill=CREAM)
 d.text((30,86),sub,font=f(23),fill=MUTED)
 scene=Image.open(frame).convert('RGB')
 if name=='02-private-clues':
  scene=scene.resize((1024,576),Image.Resampling.LANCZOS);im.paste(scene,(24,246))
  d=ImageDraw.Draw(im)
  d.rounded_rectangle((1072,166,1512,520),radius=15,fill='#24452e',outline=GOLD,width=2)
  d.rounded_rectangle((1072,544,1512,913),radius=15,fill='#24452e',outline=GOLD,width=2)
  for y,role,headline,body in [(188,'PLAYER 1 · RUNNER','Where are the spares?','Feed store: belt. Workshop: gasket. Ask your partner which part is needed.'),(566,'PLAYER 2 · MECHANIC','What is broken?','Diagnosis: a belt is needed. Hold to build pressure; release to cool. Keep the gauge green while your partner fits.')]:
   d.text((1094,y),role,font=f(21),fill=GOLD)
   cursor=y+46
   for line in wrap(d,headline,28,396):d.text((1094,cursor),line,font=f(28),fill=CREAM);cursor+=38
   cursor+=15
   for line in wrap(d,body,25,396):d.text((1094,cursor),line,font=f(25),fill=CREAM);cursor+=37
  d.text((24,860),'Private repair clues reproduced from the recorded session.',font=f(23),fill=MUTED)
 else:
  scene=scene.resize((1488,837),Image.Resampling.LANCZOS);im.paste(scene,(24,132))
 d=ImageDraw.Draw(im)
 d.text((30,987),'ACTUAL MAC GAMEPLAY  ·  AUTOMATED TWO-PLAYER INPUTS  ·  FIRE TV VERIFICATION PENDING',font=f(19),fill=MUTED)
 output=OUT/(name+'.jpg');im.save(output,quality=94,optimize=True,subsampling=0)
 assert output.stat().st_size<5_000_000
 with Image.open(output) as check:assert check.size==(1536,1024);check.verify()
 manifest.append({'file':str(output.relative_to(ROOT)),'bytes':output.stat().st_size,'source_frame_seconds':t,'title':title,'source':str(frame.relative_to(ROOT))})
 print(output.name,output.stat().st_size)
(OUT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
contact=Image.new('RGB',(1536,1024),BG)
for i,c in enumerate(manifest):
 im=Image.open(ROOT/c['file']);im.thumbnail((768,512));contact.paste(im,((i%2)*768,(i//2)*512))
contact.save(OUT/'review-contact-sheet.jpg',quality=92)
