"""Start one existing official Vega virtual-device instance with a selected GPU.
Uses only the SDK's bundled emulator/image. No SDK or disk-image edits.
"""
from pathlib import Path
import argparse,subprocess,socket,sys,os
ROOT=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--sdk-root',type=Path,required=True,help='Installed SDK version directory')
p.add_argument('--instance',type=Path,help='Existing virtual-device instance directory')
p.add_argument('--gpu',choices=['host','angle_indirect','swiftshader_indirect','swangle_indirect'],default='host')
a=p.parse_args();sdk=a.sdk_root.resolve()/'vvd'
instances=list((sdk/'instances').glob('*/userdata.qcow2'))
if a.instance:inst=a.instance.resolve()
elif len(instances)==1:inst=instances[0].parent
else:raise SystemExit('Pass --instance for an existing instance. Create it once with the official vega virtual-device start/stop commands.')
if not (inst/'userdata.qcow2').exists():raise SystemExit('Instance is missing userdata.qcow2')
with socket.socket() as probe:
 probe.settimeout(.4)
 if probe.connect_ex(('127.0.0.1',5555))==0:raise SystemExit('Device port 5555 is busy. Stop the current simulator first; never run two images on this port.')
agent=sdk/'images/tv/vmtools/agent';binary=agent/'emulator'
if not binary.exists():raise SystemExit('Official SDK emulator not found under --sdk-root')
args=[str(binary),'-avd-arch','arm64','-skindir',str(agent/'skins'),'-skin','tv-remote','-skin','1280x720','-ports','5554,5555','-dns-server','auto','-sysdir',str(inst),'-datadir',str(inst),'-data',str(inst/'userdata.qcow2'),'-gpu',a.gpu,'-keyboard-mapping','KEY_ESC:KEY_BACK,KEY_F1:KEY_HOMEPAGE,KEY_F2:KEY_MENU,KEY_F3:KEY_REWIND,KEY_F4:KEY_PLAYPAUSE,KEY_F5:KEY_FASTFORWARD','-qemu','-qmp','unix:/tmp/qmp-socket-5554.sock,server,nowait']
logs=ROOT/'.tools/vega-inspection';logs.mkdir(parents=True,exist_ok=True)
with (logs/'simulator-backend.log').open('w') as log:
 print('Starting official Vega image with',a.gpu,flush=True)
 print('Keep this terminal open. Ctrl+C stops only this owned simulator.',flush=True)
 child=subprocess.Popen(args,stdout=log,stderr=subprocess.STDOUT)
 try:code=child.wait()
 except KeyboardInterrupt:code=0
 finally:
  if child.poll() is None:
   child.terminate()
   try:child.wait(timeout=15)
   except subprocess.TimeoutExpired:child.kill();child.wait()
 sys.exit(code)
