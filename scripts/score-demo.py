"""Replace demo narration with an original quiet instrumental; also export silent.
All notes are synthesized locally. No stock audio, samples, vocals or voice mix.
Requires numpy, ffmpeg and the completed render-demo.py output.
"""
from pathlib import Path
import math, wave, subprocess, json, hashlib
import numpy as np
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'artifacts/demo'
source=OUT/'brackenridge-farm-demo-en.mp4'
meta=json.loads((OUT/'manifest.json').read_text());length=meta['duration_seconds']
SR=44100;N=round(length*SR);mix=np.zeros((N,2),dtype=np.float64)
def hz(midi):return 440*2**((midi-69)/12)
def add(midi,start,seconds,gain=.1,pan=0,kind='pluck'):
    a=round(start*SR);size=min(round(seconds*SR),N-a)
    if size<=0:return
    t=np.arange(size,dtype=np.float64)/SR;f=hz(midi)
    if kind=='pad':
        env=(1-np.exp(-t/0.4))*np.exp(-t/(seconds*.65));s=np.zeros(size)
        for ratio,weight in [(1,.8),(2,.12),(3,.03)]:s+=weight*np.sin(2*np.pi*f*ratio*t)
        s*=env
    elif kind=='bass':
        env=(1-np.exp(-t/.015))*np.exp(-t/.65)
        s=(np.sin(2*np.pi*f*t)+.15*np.sin(4*np.pi*f*t))*env
    else:
        env=(1-np.exp(-t/.006))*np.minimum(1,(seconds-t)/.08)
        s=np.zeros(size)
        # Warm string-like harmonics, with upper partials decaying fastest.
        for k in range(1,9):
            s+=(.8**(k-1)/k)*np.sin(2*np.pi*(f*k)*(1+.0002*k)*t)*np.exp(-t/(1.8/(1+.4*k)))
        s*=env
    mix[a:a+size,0]+=s*gain*math.sqrt((1-pan)/2)
    mix[a:a+size,1]+=s*gain*math.sqrt((1+pan)/2)
beat=60/88;bar=4*beat
# Gadd9 / D / Em7 / Cadd9, two distinct voicings over eight bars.
chords=[(43,[55,59,62,69]),(38,[54,57,62,66]),(40,[55,59,62,67]),(36,[55,60,64,67]),
        (43,[55,62,67,69]),(38,[54,57,62,69]),(40,[55,59,64,67]),(36,[55,60,64,74])]
# Short original pentatonic motifs, spaced out over the gentle arpeggio.
motifs=[[74,71,69,67],[69,66,64,62],[67,71,74,76],[76,74,71,67],
        [79,76,74,71],[74,69,66,69],[71,67,64,67],[69,67,64,62]]
for b in range(math.ceil(length/bar)):
    root,notes=chords[b%8];start=b*bar
    for i,pitch in enumerate(notes):add(pitch,start,bar+.6,.018,(-.45+.3*i),kind='pad')
    add(root,start,2.5,.085,-.08,kind='bass');add(root+12,start+2*beat,1.8,.042,.08,kind='bass')
    for j,index in enumerate([0,2,1,3,2,1,3,2]):
        add(notes[index],start+j*beat/2,2.2,.06 if j%2==0 else .043,(-.32 if j%2==0 else .32))
    if b>=2:
        for j,pitch in enumerate(motifs[b%8]):
            add(pitch,start+j*beat+.12,2,.042 if j!=3 else .03,.1)
# A restrained stereo room tail, no harsh rhythm or sudden changes.
for delay,gain in [(.079,.11),(.151,.075),(.293,.045)]:
    n=round(delay*SR);mix[n:]+=mix[:-n,::-1]*gain
fade=np.minimum(1,np.arange(N)/SR/2)*np.minimum(1,(N-np.arange(N))/SR/4)
mix*=fade[:,None]
# -9 dBFS peak leaves ample headroom; this is a quiet background bed.
mix*=10**(-9/20)/max(np.max(np.abs(mix)),1e-9)
score=OUT/'original-farm-instrumental.wav'
with wave.open(str(score),'wb') as w:
    w.setnchannels(2);w.setsampwidth(2);w.setframerate(SR);w.writeframes((np.clip(mix,-1,1)*32767).astype('<i2').tobytes())
def run(args):subprocess.run([str(x) for x in args],check=True,stdout=subprocess.DEVNULL,stderr=subprocess.PIPE)
def tc(t):
    ms=round(t*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02},{ms%1000:03}'
explanations=[
 'Brackenridge Farm. One farm. Two phones. Half the story each.',
 'Players share one farm, but each receives different private information.',
 'The sheep escape. One farmer guides; their partner opens the gate.',
 'Work together to return the flock. Cameras split when farmers separate.',
 'One player diagnoses and balances pressure. The other fetches and fits the part.',
 'Private clues from this recorded run: the mechanic needs a belt; the runner knows where to find it.',
 'Enter the tractor, cultivate the soil, then engage the field tool to sow.',
 'Seeds, seedlings, young plants, then mature barley. Edited between real growth stages.',
 'Harvest the barley while your partner protects supplies and prepares storage.',
 'Combine buyer and stock clues. Pack both loads, then hold together at the van.',
 'Shared results and seeded replay. Mac-native gameplay preview; Fire TV verification remains pending.'
]
srt=OUT/'brackenridge-farm-demo-music.en.srt'
srt.write_text(''.join(f'{i+1}\n{tc(s["start"])} --> {tc(min(length,s["start"]+s["seconds"]))}\n{explanations[i]}\n\n' for i,s in enumerate(meta['segments'])))
final=OUT/'brackenridge-farm-demo-music.mp4'
run(['ffmpeg','-v','error','-y','-i',source,'-i',score,'-i',srt,'-map','0:v:0','-map','1:a:0','-map','2:0','-c:v','copy','-c:a','aac','-b:a','192k','-c:s','mov_text','-metadata:s:s:0','language=eng','-metadata','title=Brackenridge Farm — Music-only Gameplay Preview','-t',length,'-movflags','+faststart',final])
silent=OUT/'brackenridge-farm-demo-silent.mp4'
run(['ffmpeg','-v','error','-y','-i',final,'-map','0:v:0','-map','0:s:0','-c','copy','-an','-metadata','title=Brackenridge Farm — Silent Gameplay Preview','-movflags','+faststart',silent])
meta.update(voice='none',audio='Original locally synthesized gentle instrumental; no narration or vocals',music={'composer':'Original project composition by Codex','tempo_bpm':88,'sources':'synthesized sine partials; no external recordings or samples','license':'MIT, same as project source'},caption_type='English explanatory captions, not a speech transcript',music_video={'file':str(final.relative_to(ROOT)),'bytes':final.stat().st_size,'sha256':hashlib.file_digest(final.open('rb'),'sha256').hexdigest()},silent_video={'file':str(silent.relative_to(ROOT)),'bytes':silent.stat().st_size,'sha256':hashlib.file_digest(silent.open('rb'),'sha256').hexdigest()},superseded_narration='Original voice version retained locally and as an unpublished YouTube draft only')
(OUT/'music-manifest.json').write_text(json.dumps(meta,indent=2)+'\n')
print(final);print(silent)
