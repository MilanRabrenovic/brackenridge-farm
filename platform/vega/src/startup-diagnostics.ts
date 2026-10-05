// Observe startup without creating/reconfiguring the engine's WebGL context.
// No URL, room code, phone token or private mission fact is collected.
export const STARTUP_DIAGNOSTICS = `(() => {
  const send = (kind, details = {}) => window.ReactNativeWebView.postMessage(
    JSON.stringify({source: 'farm-startup', kind, ...details}));
  let contextLost = false;
  let inspectLatest = () => {};
  window.addEventListener('error', event => send('error', {message: event.message}));
  window.addEventListener('unhandledrejection', event => send('error', {message: String(event.reason)}));
  window.addEventListener('webglcontextlost', () => {contextLost = true; send('context-lost'); inspectLatest();}, true);
  window.addEventListener('webglcontextrestored', () => {contextLost = false; send('context-restored'); inspectLatest();}, true);
  window.addEventListener('load', () => {
    let samples = 0;
    let previous = '';
    const inspect = () => {
      const canvas = document.querySelector('#canvas');
      const bounds = canvas ? canvas.getBoundingClientRect() : {width: 0, height: 0};
      const status = document.querySelector('#status');
      const notice = document.querySelector('#status-notice');
      const message = notice ? notice.textContent.trim().slice(0, 300) : '';
      const ready = !contextLost && !!canvas && canvas.width > 0 && canvas.height > 0 &&
        bounds.width > 0 && bounds.height > 0 && !status;
      const state = {ready, canvas: canvas ? [canvas.width, canvas.height] : null,
        bounds: [Math.round(bounds.width), Math.round(bounds.height)],
        visibility: document.visibilityState, secure: window.isSecureContext,
        wasm: !!window.WebAssembly, message};
      const encoded = JSON.stringify(state);
      if (encoded !== previous || samples === 0 || samples === 44) {
        send('canvas', state); previous = encoded;
      }
    };
    inspectLatest = inspect;
    const sample = () => {
      inspect(); samples += 1;
      if (samples < 45) setTimeout(sample, 1000);
    };
    sample();
  });
})(); true;`;
