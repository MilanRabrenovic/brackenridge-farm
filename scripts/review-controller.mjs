// Local-only controller presentation fixture; no gameplay changes.
import WebSocket from 'ws';
const ws=new WebSocket('ws://127.0.0.1:8787/ws');
ws.on('open',()=>ws.send(JSON.stringify({type:'create',version:1})));
ws.on('message',raw=>{const m=JSON.parse(raw);if(m.type==='created')console.log('REVIEW_ROOM='+m.room);
 if(m.type==='roster')for(const p of m.players){if(p.admission==='pending')ws.send(JSON.stringify({type:'admit',playerId:p.id}));else {
 ws.send(JSON.stringify({type:'mode',playerId:p.id,title:'TRACTOR',actionLabel:'EXIT',hint:'Drag toward your destination'}));
 ws.send(JSON.stringify({type:'private',playerId:p.id,text:'FIELD WORK: drive across the soil to cultivate. Further passes seed; mature crops can be harvested.'}));}}
 if(m.type==='input' && m.action)ws.send(JSON.stringify({type:'mode',playerId:m.playerId,title:'GROWER',actionLabel:'INTERACT',hint:'Walk to equipment'}));
});
setTimeout(()=>ws.close(),180000);
