// Isolated demo event markers. OBS records the official simulator window.
(() => {
  const mode=window.FARM_RECORDING_MODE;
  const endpoint=`http://127.0.0.1:8790/${mode}`;
  let started=0;
  const post=(kind,data)=>fetch(`${endpoint}/${kind}`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(data)});
  const mark=data=>post('event',{...data,epoch_ms:Date.now(),elapsed:started?(performance.now()-started)/1000:0});
  window.farmDemoMark=data=>mark({kind:'mark',...data});
  window.finishFarmRecording=data=>mark({kind:'result',...data});
  const boot=setInterval(async()=>{
    if(!(mode==='coop'?window.__brackenridgeDemoReady:window.__brackenridgeStarted))return;
    clearInterval(boot);window.__brackenridgeStarted=true;await post('start',{});started=performance.now();
    await mark({kind:'started',capture:'official simulator window via OBS'});
    window.__farmRecordingActive=true;
  },200);
})();
