import { spawn } from 'node:child_process';
import { once } from 'node:events';
import WebSocket from 'ws';
import { createRelay } from '../server/main.ts';
import { PROTOCOL } from '../shared/protocol.ts';

function waitForMessage(socket: WebSocket, predicate: (message: any) => boolean, description: string, timeoutMs = 5000) {
  return new Promise<any>((resolve,reject)=>{
    const timer=setTimeout(()=>{socket.off('message',onMessage);reject(new Error(`Timed out waiting for ${description}`));},timeoutMs);
    const onMessage=(raw: WebSocket.RawData)=>{const message=JSON.parse(String(raw));if(predicate(message)){clearTimeout(timer);socket.off('message',onMessage);resolve(message);}};
    socket.on('message',onMessage);
  });
}

const relay=createRelay(); relay.server.listen(0,'127.0.0.1'); await once(relay.server,'listening');
const port=(relay.server.address() as {port:number}).port;
const godot=spawn('godot',['--headless','--path','game'],{env:{...process.env,FARM_RELAY_URL:`ws://127.0.0.1:${port}/ws`,FARM_AUTO_ADMIT:'1'}});
let stderr='', stdout=''; godot.stderr.on('data',d=>stderr+=d);
const room=await new Promise<string>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error(`Godot did not create a room.\nSTDOUT:\n${stdout}\nSTDERR:\n${stderr}`)),10000);
  godot.stdout.on('data',d=>{ stdout+=String(d); const match=stdout.match(/PROBE_ROOM=([A-Z2-9]{6})/); if(match){clearTimeout(timer);resolve(match[1]);} });
  godot.once('exit',code=>{clearTimeout(timer);reject(new Error(`Godot exited ${code}.\nSTDOUT:\n${stdout}\nSTDERR:\n${stderr}`));});
});
const player=new WebSocket(`ws://127.0.0.1:${port}/ws`); await once(player,'open');
player.send(JSON.stringify({type:'join',room,version:PROTOCOL}));
let admitted=false;
await new Promise<void>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error('Player was not auto-admitted')),5000);
  player.on('message',raw=>{const m=JSON.parse(String(raw));if(m.type==='admitted'){admitted=true;clearTimeout(timer);resolve();}});
});
if(!admitted) throw new Error('Admission failed');
const flockCluePromise=waitForMessage(player,m=>m.type==='private'&&String(m.text).startsWith('WELCOME:'),'player one flock clue');
const playerTwo=new WebSocket(`ws://127.0.0.1:${port}/ws`); await once(playerTwo,'open');
const playerTwoAdmission=waitForMessage(playerTwo,m=>m.type==='admitted','player two admission');
const gateCluePromise=waitForMessage(playerTwo,m=>m.type==='private'&&String(m.text).startsWith('WELCOME:'),'player two gate clue');
playerTwo.send(JSON.stringify({type:'join',room,version:PROTOCOL}));
await playerTwoAdmission;
const [flockClue,gateClue]=await Promise.all([flockCluePromise,gateCluePromise]);
if(flockClue.text===gateClue.text || !String(flockClue.text).includes('tractor') || !String(gateClue.text).includes('sheep gate') || !String(gateClue.text).includes('inspect'))
  throw new Error(`Private cooperative clues were incomplete: ${JSON.stringify({flockClue,gateClue})}`);
const started=performance.now(); player.send(JSON.stringify({type:'input',seq:1,x:1,y:0,action:false}));
const ack=await new Promise<any>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error('No Godot frame acknowledgement')),5000);
  player.on('message',raw=>{const m=JSON.parse(String(raw));if(m.type==='frame_ack'&&m.seq===1){clearTimeout(timer);resolve(m);}});
});
const latency=performance.now()-started;
if(!(ack.position[0]>-2 && Math.abs(ack.position[1]-7)<0.5)) throw new Error(`Screen-right input did not follow the 2D screen axis: ${JSON.stringify(ack.position)}`);
player.send(JSON.stringify({type:'input',seq:2,x:0,y:1,action:false}));
await new Promise<any>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error('No camera-down frame acknowledgement')),5000);
  player.on('message',raw=>{const m=JSON.parse(String(raw));if(m.type==='frame_ack'&&m.seq===2){clearTimeout(timer);resolve(m);}});
});
// Send a second sample in the same direction. The first acknowledgement can
// legitimately contain the final simulated frame of the previous input when
// idle WebSocket polling and the physics tick cross on the same frame.
player.send(JSON.stringify({type:'input',seq:3,x:0,y:1,action:false}));
const downAck=await new Promise<any>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error('No stable camera-down frame acknowledgement')),5000);
  player.on('message',raw=>{const m=JSON.parse(String(raw));if(m.type==='frame_ack'&&m.seq===3){clearTimeout(timer);resolve(m);}});
});
if(!(downAck.position[1]>ack.position[1]))
  throw new Error(`Screen-down input did not follow the 2D screen axis: ${JSON.stringify({before:ack.position,after:downAck.position})}`);
player.send(JSON.stringify({type:'input',seq:4,x:0,y:0,action:true}));
const tractorMode=await new Promise<any>((resolve,reject)=>{
  const timer=setTimeout(()=>reject(new Error('Nearby tractor interaction did not change the phone mode')),5000);
  player.on('message',raw=>{const m=JSON.parse(String(raw));if(m.type==='mode'&&m.title==='TRACTOR'){clearTimeout(timer);resolve(m);}});
});
if(tractorMode.actionLabel!=='EXIT') throw new Error(`Unexpected tractor action: ${JSON.stringify(tractorMode)}`);
console.log(`Godot relay integration passed: ${latency.toFixed(1)} ms frame acknowledgement; two-player private clues, screen axes and tractor phone mode verified`);
player.close(); playerTwo.close(); godot.kill('SIGTERM'); await once(godot,'exit'); await relay.close();
