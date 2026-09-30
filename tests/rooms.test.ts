import assert from 'node:assert/strict';
import test from 'node:test';
import { once } from 'node:events';
import WebSocket from 'ws';
import jsQR from 'jsqr';
import { PNG } from 'pngjs';
import { createRelay } from '../server/main.ts';
import { PROTOCOL } from '../shared/protocol.ts';

const decodeQR = jsQR as unknown as (data: Uint8ClampedArray, width: number, height: number) => { data: string } | null;

async function message(socket: WebSocket): Promise<any> {
  return JSON.parse(String((await once(socket, 'message'))[0]));
}
async function connect(port: number) {
  const socket = new WebSocket(`ws://127.0.0.1:${port}/ws`);
  await once(socket, 'open'); return socket;
}
test('host admits two players and receives only sequenced, normalized input', async t => {
  const relay=createRelay(); relay.server.listen(0,'127.0.0.1'); await once(relay.server,'listening');
  t.after(()=>relay.close());
  const port=(relay.server.address() as {port:number}).port;
  const host=await connect(port); host.send(JSON.stringify({type:'create',version:PROTOCOL}));
  const created=await message(host); assert.match(created.room,/^[A-Z2-9]{6}$/);
  const p1=await connect(port); p1.send(JSON.stringify({type:'join',room:created.room,version:PROTOCOL}));
  const joined1=await message(p1); assert.equal(joined1.admission,'pending'); await message(host);
  const p2=await connect(port); p2.send(JSON.stringify({type:'join',room:created.room,version:PROTOCOL}));
  const joined2=await message(p2); assert.equal(joined2.playerId,2); await message(host);
  host.send(JSON.stringify({type:'admit',playerId:1})); assert.equal((await message(p1)).type,'admitted'); await message(host);
  host.send(JSON.stringify({type:'mode',playerId:1,title:'TRACTOR',actionLabel:'EXIT',hint:'Steer with the movement pad'}));
  const mode=await message(p1); assert.deepEqual(mode,{type:'mode',title:'TRACTOR',actionLabel:'EXIT',hint:'Steer with the movement pad'});
  p1.send(JSON.stringify({type:'command',command:'pin',playerId:2}));
  assert.deepEqual(await message(host),{type:'command',command:'pin',playerId:1});
  p1.send(JSON.stringify({type:'input',seq:1,x:1,y:1,action:false}));
  const input=await message(host); assert.equal(input.playerId,1); assert.ok(Math.abs(input.x-.7071)<.001);
  p1.send(JSON.stringify({type:'input',seq:1,x:-1,y:0,action:false}));
  host.send(JSON.stringify({type:'frame_ack',playerId:1,seq:1,phase:'simulated',position:[1,2]}));
  const ack=await message(p1); assert.deepEqual(ack.position,[1,2]);
  host.close(); p1.close(); p2.close();
});

test('reconnect token restores a slot and resets host input', async t => {
  const relay=createRelay(); relay.server.listen(0,'127.0.0.1'); await once(relay.server,'listening');
  t.after(()=>relay.close()); const port=(relay.server.address() as {port:number}).port;
  const host=await connect(port); host.send(JSON.stringify({type:'create',version:PROTOCOL})); const created=await message(host);
  const first=await connect(port); first.send(JSON.stringify({type:'join',room:created.room,version:PROTOCOL})); const joined=await message(first); await message(host);
  const disconnectNotice=message(host); first.close(); await once(first,'close');
  assert.equal((await disconnectNotice).type,'reset_input');
  const second=await connect(port); second.send(JSON.stringify({type:'join',room:created.room,token:joined.token,version:PROTOCOL}));
  const hostReset=message(host), restored=await message(second); assert.equal(restored.playerId,joined.playerId);
  assert.equal((await hostReset).type,'reset_input');
  host.close(); second.close();
});

test('room QR is a PNG that uses the phone-reachable controller origin', async t => {
  const relay=createRelay({controllerOrigin:'http://192.168.50.20:8787'});
  relay.server.listen(0,'127.0.0.1'); await once(relay.server,'listening');
  t.after(()=>relay.close()); const port=(relay.server.address() as {port:number}).port;
  const host=await connect(port); host.send(JSON.stringify({type:'create',version:PROTOCOL})); const created=await message(host);
  const response=await fetch(`http://127.0.0.1:${port}/qr?room=${created.room}`);
  assert.equal(response.status,200); assert.equal(response.headers.get('content-type'),'image/png');
  const bytes=new Uint8Array(await response.arrayBuffer());
  assert.deepEqual([...bytes.slice(0,8)],[137,80,78,71,13,10,26,10]);
  const png=PNG.sync.read(Buffer.from(bytes));
  const decoded=decodeQR(new Uint8ClampedArray(png.data),png.width,png.height);
  assert.equal(decoded?.data,`http://192.168.50.20:8787/?room=${created.room}`);
  host.close();
});
