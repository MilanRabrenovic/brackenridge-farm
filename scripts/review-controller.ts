// Isolated controller presentation fixture. Not a Godot playthrough or TV proof.
import { once } from 'node:events';
import WebSocket from 'ws';
import { createRelay } from '../server/main.ts';
import { PROTOCOL } from '../shared/protocol.ts';

const relay = createRelay({controllerOrigin:'http://127.0.0.1:8789'});
relay.server.listen(8789,'127.0.0.1');
await once(relay.server,'listening');
const host = new WebSocket('ws://127.0.0.1:8789/ws');
await once(host,'open');
host.on('message', raw => {
  const packet = JSON.parse(String(raw));
  if (packet.type === 'created') console.log(`Controller fixture: http://127.0.0.1:8789/?room=${packet.room}`);
  if (packet.type === 'roster') for (const player of packet.players) {
    if (player.admission === 'pending') host.send(JSON.stringify({type:'admit',playerId:player.id}));
    else if (player.connected) {
      host.send(JSON.stringify({type:'private',playerId:player.id,text:'DEVELOPMENT REVIEW: Weekend complete. Tap ready to review the next-weekend controller. This fixture does not run the farm.',clue:'DEVELOPMENT REVIEW: Controller presentation only.'}));
      host.send(JSON.stringify({type:'mode',playerId:player.id,title:'RESULTS',actionLabel:'READY',hint:'Controller fixture'}));
    }
  }
  if (packet.type === 'command' && packet.command === 'replay') {
    host.send(JSON.stringify({type:'mode',playerId:packet.playerId,title:'FARMHAND',actionLabel:'INTERACT',hint:'Development review'}));
    host.send(JSON.stringify({type:'private',playerId:packet.playerId,text:'DEVELOPMENT REVIEW: Walking controls restored. This is a presentation fixture, not a restarted mission.'}));
  }
});
host.send(JSON.stringify({type:'create',version:PROTOCOL}));
process.on('SIGINT',()=>{host.close();void relay.close().then(()=>process.exit(0));});
