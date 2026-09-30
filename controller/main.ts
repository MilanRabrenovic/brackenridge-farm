import { PROTOCOL, type Input } from '../shared/protocol.ts';

const $ = <T extends HTMLElement>(id: string) => document.getElementById(id) as T;
const roomInput = $<HTMLInputElement>('room');
const join = $('join'), controller = $('controller');
const status = $('joinStatus'), connection = $('connection');
const stick = $('stick'), knob = $('knob'), action = $('action');
const queryRoom = new URLSearchParams(location.search).get('room');
if (queryRoom) roomInput.value = queryRoom.toUpperCase();

let socket: WebSocket | null = null;
let tractorMode = false;
let playerId = 0, seq = 0, admitted = false, actionDown = false;
let vector = { x: 0, y: 0 }, activePointer: number | null = null;
const sentAt = new Map<number, number>();
const samples: number[] = [];
const wsUrl = `${location.protocol === 'https:' ? 'wss' : 'ws'}://${location.host}/ws`;

function connect() {
  const room = roomInput.value.trim().toUpperCase();
  if (!/^[A-Z2-9]{6}$/.test(room)) { status.textContent = 'Enter the six-character code from the TV.'; return; }
  status.textContent = 'Connecting to the farm…';
  socket?.close(); socket = new WebSocket(wsUrl);
  const liveSocket = socket;
  socket.onopen = () => socket?.send(JSON.stringify({ type:'join', room, token:localStorage.getItem(`farm-token:${room}`), version:PROTOCOL }));
  socket.onmessage = event => {
    const message = JSON.parse(event.data as string);
    if (message.type === 'joined') {
      playerId = message.playerId; localStorage.setItem(`farm-token:${room}`, message.token);
      join.hidden = true; controller.hidden = false;
      $('playerNumber').textContent = String(playerId);
      $('role').textContent = playerId === 1 ? 'Grower' : 'Mechanic';
      admitted = message.admission === 'admitted'; setState(admitted ? 'Connected' : 'Waiting for TV');
    } else if (message.type === 'admitted') { admitted = true; setState('Connected'); }
    else if (message.type === 'private') { $('privateText').textContent = message.text; $('privateCard').hidden = false; }
    else if (message.type === 'mode') {
      tractorMode = message.title === 'TRACTOR';
      controller.classList.toggle('tractor-mode', tractorMode);
      $('tractorDash').hidden = !tractorMode;
      stick.setAttribute('aria-label', tractorMode ? 'Tractor direction control: drag to drive, release to stop' : 'Movement control');
      resetInput();
      $('role').textContent = message.title;
      action.textContent = message.actionLabel;
      $('packetState').textContent = message.hint || 'Controls updated';
    }
    else if (message.type === 'frame_ack') measure(Number(message.seq));
    else if (message.type === 'error' || message.type === 'ended') { status.textContent = message.message; join.hidden = false; controller.hidden = true; }
  };
  socket.onclose = () => { if (socket !== liveSocket) return; admitted = false; setState('Reconnecting…'); resetInput(); setTimeout(()=>{if(socket===liveSocket) connect();},1500); };
  socket.onerror = () => { status.textContent = 'Could not reach the farm. Confirm both devices are on the same network.'; };
}
function setState(text: string) { connection.textContent = text; connection.classList.toggle('online', admitted); }
function sendInput() {
  if (!admitted || socket?.readyState !== WebSocket.OPEN) return;
  const packet: Input = { type:'input', seq:++seq, x:vector.x, y:vector.y, action:actionDown };
  sentAt.set(seq, performance.now());
  while (sentAt.size > 200) sentAt.delete(sentAt.keys().next().value!);
  socket.send(JSON.stringify(packet));
  if (tractorMode) {
    const power = Math.round(Math.hypot(vector.x,vector.y)*100);
    $('drivePower').textContent = power + '%';
    $('driveState').textContent = power > 5 ? 'DRIVING' : 'PARKED';
    $('powerFill').style.width = power + '%';
    stick.style.setProperty('--wheel-angle', (vector.x*60) + 'deg');
  }
  $('packetState').textContent = Math.hypot(vector.x,vector.y) > .05 || actionDown ? `Input #${seq}` : 'Input neutral';
}
function measure(ackSeq: number) {
  const at = sentAt.get(ackSeq); if (at === undefined) return;
  const delay = performance.now() - at; samples.push(delay); if (samples.length > 120) samples.shift();
  for (const key of sentAt.keys()) if (key <= ackSeq) sentAt.delete(key);
  const sorted = [...samples].sort((a,b)=>a-b), median=sorted[Math.floor(sorted.length*.5)], p95=sorted[Math.floor(sorted.length*.95)];
  $('latency').textContent = `Frame ack ${median.toFixed(0)} ms median · ${p95.toFixed(0)} ms p95`;
}
function updateStick(clientX: number, clientY: number) {
  const r=stick.getBoundingClientRect(), dx=clientX-(r.left+r.width/2), dy=clientY-(r.top+r.height/2), radius=r.width*.32;
  const scale=Math.min(1,radius/Math.max(1,Math.hypot(dx,dy))), nx=dx*scale/radius, ny=dy*scale/radius;
  vector={x:nx,y:ny}; knob.style.transform=`translate(${nx*72}%,${ny*72}%)`; sendInput();
}
function resetInput() { vector={x:0,y:0}; actionDown=false; knob.style.transform='translate(0,0)'; action.classList.remove('pressed'); sendInput(); }
$('joinButton').addEventListener('click', connect);
roomInput.addEventListener('keydown', e => { if (e.key === 'Enter') connect(); });
stick.addEventListener('pointerdown', e => { activePointer=e.pointerId; stick.setPointerCapture(e.pointerId); updateStick(e.clientX,e.clientY); });
stick.addEventListener('pointermove', e => { if (e.pointerId===activePointer) updateStick(e.clientX,e.clientY); });
for (const type of ['pointerup','pointercancel'] as const) stick.addEventListener(type, e => { if(e.pointerId===activePointer){activePointer=null;resetInput();} });
action.addEventListener('pointerdown', e => { action.setPointerCapture(e.pointerId); actionDown=true; action.classList.add('pressed'); sendInput(); });
for (const type of ['pointerup','pointercancel'] as const) action.addEventListener(type,()=>{actionDown=false;action.classList.remove('pressed');sendInput();});
document.addEventListener('visibilitychange',()=>{if(document.hidden)resetInput();});
setInterval(()=>{ if(admitted) sendInput(); }, 100);
if (queryRoom) requestAnimationFrame(connect);

for (const [id,command] of [['pinClue','pin'],['dropItem','drop'],['pauseGame','pause']]) {
  $(id).addEventListener('click',()=>{resetInput();if(admitted&&socket?.readyState===WebSocket.OPEN)socket.send(JSON.stringify({type:'command',command}));});
}
