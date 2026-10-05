import {STARTUP_DIAGNOSTICS} from '../src/startup-diagnostics';

function executeDiagnostics(code: string, environment: Record<string, unknown>) {
  // Exercise our shipped injection string with explicit fake browser globals.
  // eslint-disable-next-line no-new-func
  const run = new Function(...Object.keys(environment), code);
  run(...Object.values(environment));
}

it('does not declare startup ready for a zero-size canvas or lost context', () => {
  const reports: Array<{kind: string; ready?: boolean}> = [];
  const events: Record<string, () => void> = {};
  const timers: Array<() => void> = [];
  let status: object | null = {};
  let visibleWidth = 0;
  const canvas = {
    width: 1280,
    height: 720,
    getBoundingClientRect: () => ({width: visibleWidth, height: 720}),
    getContext: () => {
      throw new Error('Diagnostics must not create a graphics context');
    },
  };
  executeDiagnostics(STARTUP_DIAGNOSTICS, {
    window: {
      ReactNativeWebView: {
        postMessage: (raw: string) => reports.push(JSON.parse(raw)),
      },
      addEventListener: (name: string, callback: () => void) => {
        events[name] = callback;
      },
      isSecureContext: true,
      WebAssembly: {},
    },
    document: {
      visibilityState: 'visible',
      querySelector: (selector: string) =>
        selector === '#canvas'
          ? canvas
          : selector === '#status'
          ? status
          : null,
    },
    setTimeout: (callback: () => void) => timers.push(callback),
  });
  events.load();
  expect(reports.at(-1)?.ready).toBe(false);
  status = null;
  timers.shift()?.();
  expect(reports.at(-1)?.ready).toBe(false);
  visibleWidth = 1280;
  timers.shift()?.();
  expect(reports.at(-1)?.ready).toBe(true);
  events.webglcontextlost();
  timers.shift()?.();
  expect(reports.at(-1)?.ready).toBe(false);
  events.webglcontextrestored();
  timers.shift()?.();
  expect(reports.at(-1)?.ready).toBe(true);
  // Context recovery must still clear the failure after startup polling ends.
  while (timers.length) {
    timers.shift()?.();
  }
  events.webglcontextlost();
  expect(reports.at(-1)?.ready).toBe(false);
  events.webglcontextrestored();
  expect(reports.at(-1)?.ready).toBe(true);
});
