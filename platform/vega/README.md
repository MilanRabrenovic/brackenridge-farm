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
