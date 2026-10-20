from pathlib import Path
import re
ROOT=Path(__file__).resolve().parents[2];OUT=ROOT/'build/vega-gles2-source'
def first_delim(text,delim):
 quote=None;depth=0;escape=False
 for i,c in enumerate(text):
  if quote:
   if escape:escape=False
   elif c=='\\':escape=True
   elif c==quote:quote=None
  elif c in '\"\'':quote=c
  elif c=='#':break
  elif c in '([{':depth+=1
  elif c in ')]}':depth-=1
  elif c==delim and depth==0:return i
 return -1

def expand(text,indent):
 parts=[]
 while True:
  j=first_delim(text,';')
  if j<0:parts.append(text.strip());break
  parts.append(text[:j].strip());text=text[j+1:]
 result=[];level=indent
 for part in parts:
  j=first_delim(part,':')
  if j>=0 and (re.match(r'(if |elif |else:|for |while |match |(?:static )?func )',part) or part.startswith(('"',"'")) or re.match(r'(?:[A-Z]\w*\.[A-Z_]+|_):',part)):
   result.append(level+part[:j+1]);body=part[j+1:].strip()
   if body:
    level+='\t';result+=expand(body,level)
  else:result.append(level+part)
 return result
for p in (OUT/'scripts').glob('*.gd'):
 text=p.read_text();text=re.sub(r'([\w.]+) not in ',r'not \1 in ',text)
 lines=[]
 for line in text.splitlines():
  if not line.strip() or line.lstrip().startswith('#'):lines.append(line);continue
  raw_indent=line[:len(line)-len(line.lstrip())]
  indent='\t'*(raw_indent.count('\t')+raw_indent.count(' '))
  lines+=expand(line.strip(),indent)
 p.write_text('\n'.join(lines)+'\n')
# Explicit class registry keeps command-line builds deterministic after regeneration.
import json
classes=[]
for p in (OUT/'scripts').glob('*.gd'):
 s=p.read_text();c=re.search(r'^class_name (\w+)',s,re.M);b=re.search(r'^extends (\w+)',s,re.M)
 if c and b:classes.append({'base':b[1],'class':c[1],'language':'GDScript','path':'res://scripts/'+p.name})
p=OUT/'project.godot';s=p.read_text();s=s.replace('config_version=4','config_version=4\n_global_script_classes='+json.dumps(classes)+'\n_global_script_class_icons={}');p.write_text(s)
