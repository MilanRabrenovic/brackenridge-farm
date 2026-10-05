# Vega wrapper candidate

Amazon's official `vegaWebview` template hosts the exported Godot game inside a Vega TV WebView. The laptop relay remains required; this is not an offline standalone package.

## Build

Install the official Vega SDK (tested SDK 0.24.12112) and activate its environment. From the project root:

```sh
npm install
npm run build:controller
npm run export:web
node scripts/configure-vega.mjs http://127.0.0.1:8787/host/
npm run dev
```

In another terminal:

```sh
cd platform/vega
vega exec npm install
vega exec npm run lint
vega exec npx tsc --noEmit
vega exec npm test -- --runInBand
vega exec npm run build:release
vega virtual-device start --display-res 1280,720
vega exec vda reverse tcp:8787 tcp:8787
vega run-app build/aarch64-release/brackenridgefarm_aarch64.vpkg
```

Keep the terminal that starts the virtual device open. In agent-supervised execution the simulator's child process was stopped when its launching shell ended; retaining that shell kept the simulator connected.

Use `vega device info` to select the correct architecture for another device. Same Wi-Fi phones join using the game's QR. TV SELECT/Enter admits players. The host owns the same simulation as the browser.

## Evidence and remaining verification

September 30: debug and release packages built for armv7, aarch64 and x86_64; lint, TypeScript and template render test passed. aarch64 package installed/launched on a Vega TV simulator, OS 1.2 (TV Ship/102282480). The initial LAN-HTTP route could not start Godot: WebView 4.0.2+ blocks HTTP by default and Godot requires a secure context. The configuration script now creates a cleartext exception for the configured host only. For simulator development, use the documented reverse-port forwarding above so the game loads at trusted loopback. After this correction, the simulator fetched HTML, engine JavaScript, PCK, WASM and audio worklets and created a Godot room on an isolated relay. This proves simulation startup, not a complete gameplay/platform pass. The native inspection tool did not expose its window; the SDK framebuffer capture remained running and produced an empty file, which was removed from review evidence. Startup diagnostics forward load/error status to app logs. No qualifying footage exists yet.

The SDK dependency install reported 27 vulnerabilities (14 moderate, 13 high) in its template dependency tree. No force-upgrade was applied across Amazon SDK compatibility constraints. Review the dependency audit before public hosting/distribution.

The SDK and simulator are developer tools under Amazon's Program Materials terms and are excluded from the source archive. Dependency licences are retained with packages; the project licence does not relicense Amazon materials.

## Deployment distinction

The packaged candidate uses `http://127.0.0.1:8787/host/` and requires reverse forwarding plus the laptop relay. This is a developer/simulator route, not a standalone Vega release. A production remote host must use trusted HTTPS/WSS; LAN HTTP is not a viable Godot host origin. Phones still receive the laptop LAN QR URL from the relay.

Optional file-request tracing: `FARM_HTTP_DIAGNOSTICS=1 npm run dev` prints host resource paths/status only, without request queries or phone tokens.

## Inspector attempt

The documented debug route (`vega exec vda forward tcp:9229 tcp:9229`, then Chrome inspection) was attempted after rebuilding/installing Debug. The forwarded inspector URL returned an empty response. It did not provide rendered-game or remote-input evidence. Do not count this attempt as a successful platform test.

## Phone-only inactivity

The wrapper requests a 30-minute component inactivity timeout through the supported `useSetTimeoutCallback` hook. Phone events do not count as TV remote input. Debug/release builds, lint, TypeScript and the template render test passed; the SDK reported the component still running >2 minutes after launch. This does not prove a full 15-minute game, prevent hardware sleep, or verify rendering/remote controls.

Final acceptance blocker: with the component active, the documented framebuffer capture again remained running without an image and was cancelled after the diagnostic deadline. The inspector endpoint returned an empty response. No physical Fire OS device is connected and no two-human full device run or qualifying footage exists. These external verification gates remain unresolved across three goal turns; the finish goal is blocked, not complete. Resume once a usable device/view and playtest evidence are available.

## October 5 supported Inspector investigation

The blocked entry above is historical; the finish goal has resumed. Amazon's [VDA reference](https://developer.amazon.com/docs/vega/0.24/vda-tools) explicitly states that `gwsi-tool-screenshooter` is unsupported on VVD. Do not repeat that capture route or alter simulator filesystem permissions. The supported alternative is [Appium Inspector](https://developer.amazon.com/docs/vega/0.24/appium-inspector).

Installed locally under `.tools/vega-inspection/`: Appium 2.2.2, Amazon Kepler driver 3.30.0 and official Appium Inspector 2026.9.2 macOS ARM. The ZIP SHA-256 matched the official release: `87ca4fcdec4c36165870e42748ecfe6cc32f4506f8a776875b00e8b1315edfa2`. Tools remain excluded from submission source; server binds only to loopback.

From the repository root, enable the toolkit on the disposable simulator before app launch and start Appium with SDK ARM Node 18.20.4:

```sh
.tools/vega-sdk/vega-sdk/main/0.24.12112/bin/tools/vda shell touch /tmp/automation-toolkit.enable
APPIUM_HOME="$PWD/.tools/vega-inspection/appium-home" PATH="$PWD/.tools/vega-sdk/vega-sdk/main/0.24.12112/runtimes/node/bin:$PWD/.tools/vega-sdk/vega-sdk/main/0.24.12112/bin/tools:$PATH" .tools/vega-inspection/node_modules/.bin/appium --address 127.0.0.1 --port 4723 --log .tools/vega-inspection/server.log
```

Native Inspector GUI capabilities:

```json
{"platformName":"Kepler","appium:automationName":"automation-toolkit/JSON-RPC","kepler:device":"vda://default"}
```

Session creation passed. Initial screenshot/source stalled while the game component was absent. After `vda shell vlcm list` confirmed it had stopped, install/launch succeeded: game VISIBLE (PID 9223), WebView renderer READY (PID 9296). Inspector returned a 1280×720 window and black screenshot. A GUI UP input received a driver HTTP 200 response, without verified visible response. Later refresh again remained pending. `docs/audits/2026-10-05-tv-inspection/inspector-pending.png` records pending UI, not completed gameplay. Logs contained repeated `GWSI_LOG: Render state for buffer` entries. These do not establish the cause: capture limitation and actual rendering failure remain possible. No full TV gameplay or qualifying footage was obtained.

Use lower-level component listing when `vega device is-app-running` reports incomplete dev-shell lookup. Retain live handles while requests are pending; do not restart solely on observation timeout. Next: gather fresh wrapper/startup diagnostics alongside a supported capture to distinguish loading, rendering and capture failure.

## Startup diagnostics and failure handling — October 5

The wrapper now observes canvas backing/visible dimensions, Godot startup-overlay removal, context loss/restoration and page failures, without acquiring a WebGL context. State is sampled for up to 45 seconds; only changed/first/final samples are forwarded. No room, phone token or private mission fact is collected. Loading/connection/error messages are friendly native text; development builds additionally expose the diagnostic strip. `ready=true` means nonzero canvas bounds and removal of Godot's startup overlay; it does not establish actual farm pixels, performance or audio.

Fresh debug launch logs reached a visible 1280×720 ready canvas approximately ten seconds after document load. `inspector-flat.png` shows the native diagnostic strip alongside a flat game surface; `startup-diagnostics.log` retains only six scoped startup records. A direct observation of the simulator window is pending to distinguish capture failure from actual rendering failure. The renderer service is already declared under `[wants]`; no missing-service fix was appropriate. Amazon's [current porting guidance](https://developer.amazon.com/docs/adbt/port-fire-os-app-to-vega) separately warns that its screenshot/performance tooling is unavailable on VVD; this is evidence of tooling limitations, not proof that our game renders correctly.

Lint, TypeScript, three tests/two suites and Debug/Release builds for aarch64/armv7/x86_64 passed. The aarch64 release candidate in `artifacts/` is refreshed. The temporary log collector ended. For tests without Watchman's outside-workspace cache:

```sh
vega exec npm test -- --runInBand --watchman=false
```

The actual injected script is regression-tested against zero canvas bounds and lost/restored contexts. Startup error states are component-tested; only the debug ready strip was visually inspected on the simulator inspection surface. Full TV acceptance remains open.

Late context recovery is now sampled immediately even after the 45-second polling window ends, so a restored context clears the native failure text. The actual injected-code regression covers this; final three tests, lint and TypeScript passed. Earlier ready-strip inspection remains valid startup evidence; late recovery was regression-tested rather than induced on the simulator.

Final late-recovery builds: Debug and Release completed successfully for aarch64, armv7 and x86_64. The retained aarch64 release candidate includes the recovery fix. Source handoff is refreshed with current diagnostics, tests and scoped inspection evidence; this remains a candidate, not a completed TV acceptance pass.
