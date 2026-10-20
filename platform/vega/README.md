# Vega wrapper candidate

Amazon's official `vegaWebview` template hosts the generated GLES2/WebGL1 game inside a Vega TV WebView. **Current route/limits:** see `../vega-gles2/README.md`; the historical investigation below is superseded by its actual guest rendering/input evidence. Sustained responsive play is not accepted. The laptop relay remains required; this is not an offline standalone package.

## Latest October 20 responsiveness result

The static-presentation optimized WebGL1 build now runs on the official emulator's host OpenGL backend with observed controller medians mostly 35–78 ms; startup frame samples showed 44–53.1 fps. These are scoped samples, not a full-game performance guarantee. Two private controllers, split/merge, cutaways and tractor driving were inspected in the guest. Use `--gpu host` (new launcher default); the earlier software-slowness/Metal-crash notes remain historical results for those different backends. Full strict Mac GLES2 routes and five wrapper tests/all Debug/Release targets passed. Evidence and exact limits: `docs/audits/2026-10-20-vega-performance/README.md` from project root. Genuine qualifying public footage, public candidate refresh and Devpost correction remain next.


## Start the simulator separately

From the project root, keep this terminal open. Do not run it alongside another instance:

```sh
python3 scripts/start-vega-simulator.py --sdk-root .tools/vega-sdk/vega-sdk/main/0.24.12112 --gpu host
```

## Build

Install the official Vega SDK (tested SDK 0.24.12112) and activate its environment. From the project root:

```sh
npm install
npm run build:controller
npm run export:vega-gles2
node scripts/configure-vega.mjs http://127.0.0.1:8787/host/vega-gles2/index.html
npm run dev
```

In another terminal:

```sh
cd platform/vega
vega exec npm install
vega exec npm run lint
vega exec npx tsc --noEmit
vega exec npm test -- --runInBand --watchman=false
vega exec npm run build:release
vega exec vda reverse tcp:8787 tcp:8787
vega run-app build/aarch64-release/brackenridgefarm_aarch64.vpkg
```

Keep the terminal that starts the virtual device open. In agent-supervised execution the simulator's child process was stopped when its launching shell ended; retaining that shell kept the simulator connected.

Use `vega device info` to select the correct architecture for another device. Same Wi-Fi phones join using the game's QR. TV SELECT/Enter admits players. The host owns the same simulation as the browser.

## Evidence and remaining verification

September 30: debug and release packages built for armv7, aarch64 and x86_64; lint, TypeScript and template render test passed. aarch64 package installed/launched on a Vega TV simulator, OS 1.2 (TV Ship/102282480). The initial LAN-HTTP route could not start Godot: WebView 4.0.2+ blocks HTTP by default and Godot requires a secure context. The configuration script now creates a cleartext exception for the configured host only. For simulator development, use the documented reverse-port forwarding above so the game loads at trusted loopback. After this correction, the simulator fetched HTML, engine JavaScript, PCK, WASM and audio worklets and created a Godot room on an isolated relay. This proves simulation startup, not a complete gameplay/platform pass. The native inspection tool did not expose its window; the SDK framebuffer capture remained running and produced an empty file, which was removed from review evidence. Startup diagnostics forward load/error status to app logs. No qualifying footage exists yet.

October 19 dependency fixes replace the historical install audit: 14 of the 16 GitHub findings are patched, including both critical Handlebars alerts. Two upstream advisories remain (braces and sprintf-js); do not treat the toolchain as vulnerability-free. Clean installation, lint, TypeScript, all three tests and Debug/Release builds for all three architectures passed. See [dependency evidence](../../docs/audits/2026-10-19-dependencies/README.md). Install with Node >=22.14.0 (verified with 24.19.0) to satisfy the existing Amazon package engine requirement; an SDK `vega exec` shell may select an older Node. No forced SDK downgrade was applied.

The SDK and simulator are developer tools under Amazon's Program Materials terms and are excluded from the source archive. Dependency licences are retained with packages; the project licence does not relicense Amazon materials.

## Deployment distinction

The packaged candidate uses `http://127.0.0.1:8787/host/vega-gles2/index.html` and requires reverse forwarding plus the laptop relay. This is a developer/simulator route, not a standalone Vega release. A production remote host must use trusted HTTPS/WSS; LAN HTTP is not a viable Godot host origin. Phones still receive the laptop LAN QR URL from the relay.

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
vega exec npm test -- --runInBand --watchman=false --watchman=false
```

The actual injected script is regression-tested against zero canvas bounds and lost/restored contexts. Startup error states are component-tested; only the debug ready strip was visually inspected on the simulator inspection surface. Full TV acceptance remains open.

Late context recovery is now sampled immediately even after the 45-second polling window ends, so a restored context clears the native failure text. The actual injected-code regression covers this; final three tests, lint and TypeScript passed. Earlier ready-strip inspection remains valid startup evidence; late recovery was regression-tested rather than induced on the simulator.

Final late-recovery builds: Debug and Release completed successfully for aarch64, armv7 and x86_64. The retained aarch64 release candidate includes the recovery fix. Source handoff is refreshed with current diagnostics, tests and scoped inspection evidence; this remains a candidate, not a completed TV acceptance pass.

## October 20 eligibility investigation

The user reports an organizer warning after submission. Existing Mac preview footage is insufficient under the current rules. The official SDK is still latest (0.24.12112). Release install/launch and VISIBLE/renderer READY were confirmed again with normal local device permissions; sandboxed device listing falsely returned empty. Amazon's official Vega Studio 0.24.1 extension was installed and its GUI start path also booted the simulator, but desktop-control tools still could not inspect its separate window. Fresh emulator logs contain GLSL 310 / atomic_uint shader compilation errors and texture validation errors; attribution to Godot is unproven. No qualifying capture or working graphics fix resulted. Do not substitute status/logs for visible game evidence.

See [investigation](../../docs/audits/2026-10-20-tv-eligibility/README.md) and [correction guide](../../docs/TV_ELIGIBILITY.md). Single next step: obtain a directly visible simulator/device display, verify play, then record and update the submission.

User-supplied screenshot now confirms the actual simulator window exists but its display is black. Amazon home was launched for isolation; lifecycle reports home VISIBLE and farm NOT_VISIBLE, but the home screen's visual result is pending. This is not yet evidence of whether the game or system rendering is responsible.

## Local graphics isolation — later October 20

The supported Appium Inspector now produces successful fresh screenshots when the emulator is launched with bundled alternative backends. Native launcher and game HTML loading page render. The actual Godot game still fails WebGL2 availability. Retained evidence: `docs/audits/2026-10-20-tv-eligibility/webgl2-error-inspector.png`, `webgl2-message-fixed.png`, and `graphics-probe-swangle.png` (paths relative to repository root). These are failure/diagnostic images, not qualifying gameplay.

The isolated `graphics-probe.html` reports secure context true, Chromium 144, WebGL1 true and WebGL2 false with `BindToCurrentSequence failed` on Mesa/virgl. Direct host EGL probes measured bundled ANGLE Metal GLES 3.0 / shader 3.00 and bundled Vulkan/SwiftShader GLES 3.1 / shader 3.10. Host capabilities did not establish guest capabilities. Tested SwiftShader, ANGLE Metal, SwANGLE, explicit Vulkan selection and dynamic GLES negotiation did not produce a working game. The original simulator config.ini was restored; process-local driver-selection experiments are diagnostic tools only.

The wrapper now identifies the specific missing-WebGL2 failure instead of blaming the laptop. Lint, TypeScript, four Jest tests/two suites and all three Release builds passed, and the corrected message was inspected. Use the full npm build command to rebundle changed JavaScript; direct native `vega build` reused stale JS in the first attempt. Stop the current app before relaunching an updated package to ensure it loads the new bundle/URL.

The user explicitly requires hardware-free execution entirely inside Vega; borrowing hardware and a streamed Mac backend are not the agreed solution. Side-by-side official SDK 0.24.9914 installation is underway while 0.24.12112 remains active. Older-image behavior is not yet known. No qualifying footage, public release update or Devpost correction resulted yet.

## Current WebGL1 result — supersedes earlier startup/failure notes

The maintained adapter now runs the actual farm locally inside Vega SDK 0.24.12112. Two-controller private admission, walking, sheep event and tractor boarding/dashboard/drive were inspected. Wrapper readiness now accepts Godot 3's explicit engine-started signal while retaining dimension/context-loss guards; it does not infer visual/performance acceptance. Lint, TypeScript, four Jest tests/two suites and all three Release targets passed. Direct native-only builds may retain stale JS: use the complete npm build.

Software backends are slow; faster Metal ANGLE later host-crashed. No sustained/full guest weekend, revised public demo or Devpost correction is claimed. The original Godot 4 browser host still requires WebGL2. Local candidate packages: `artifacts/vega-gles2/`. Evidence: `docs/audits/2026-10-20-vega-port/` from root. Use the new single-instance launcher; no VS Code requirement.