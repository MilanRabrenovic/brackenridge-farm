# Vega eligibility investigation — October 20, 2026

## Result

**Later same-day result: a WebGL1 port visibly runs actual gameplay/input inside the newer Vega guest. Sustained responsive play remains open. No replacement video was recorded/published and Devpost was not edited.** See `../2026-10-20-vega-port/README.md`. The following investigation notes preserve earlier failures. The user reports submission and receipt of an organizer eligibility warning. The existing music-only video is a Mac preview.

## Evidence collected

- Official CLI reports SDK 0.24.12112 as latest installed/default; no newer main-channel SDK offered (`sdk-versions.txt`).
- Official aarch64 Release package installed/launched successfully; VDA reverse forwarding on 8787 succeeded.
- `device-list.txt` confirms the official aarch64 TV virtual device; `components.txt` records the farm component VISIBLE and WebView renderer READY after restart.
- Installed Amazon's official VS Code Marketplace extension `amazon-devices.kepler-studio` 0.24.1. In a separate `platform/vega` window, Vega Studio recognized the existing SDK and started VirtualDevice:Tv. This did not provide an inspectable simulator window through the available desktop inventory.
- The fresh emulator error log repeatedly reports texture validation failures and shader compilation failure: GLSL version 310 unsupported / atomic_uint syntax errors. A scoped excerpt is retained. These errors are a diagnostic lead, **not a proven explanation of the Godot surface**; some appear during startup before game launch.
- Available desktop-control APIs do not resolve the emulator's unbundled process as an application. User was asked whether the separate window is visible directly. That answer remains necessary to distinguish tool visibility from a missing window.

## Limits

Sandboxed `vega device list` falsely returned no devices while the normal-permission CLI found the running simulator. Use normal local device/socket permissions. A reported boot or VISIBLE component does not prove farm pixels, phone control, sustained performance or eligibility. No unsupported framebuffer capture was repeated. No graphics/security setting was weakened, no OS/SDK downgrade was applied, and no game code or art was changed.

## Sources

- [Hackathon rules](https://amazonappdev2026.devpost.com/rules): actual Fire TV/qualifying simulator video required; deadline October 23, 2026 at noon PDT.
- [Official launch guide](https://www.developer.amazon.com/docs/vega/0.24/run-apps): CLI and Vega Studio GUI launch supported.
- [VVD troubleshooting](https://www.developer.amazon.com/docs/vega/0.24/kvd-issues): Apple Silicon supports WebView testing. Disabling GL acceleration is documented for Ubuntu only in the launch guide, so it was not applied on this Mac.

Next: establish a directly visible working simulator/Fire TV display, then record actual gameplay. See `../../TV_ELIGIBILITY.md` for the correction and recording checklist.

## User-supplied display evidence / home-screen isolation

The user subsequently supplied `Screenshot 2026-10-20 at 12.20.48.png`, showing the actual simulator title bar and an entirely black display. The window exists; absence from desktop-control inventory was a tooling visibility issue. No gameplay pixels were visible. The original screenshot remains in the user's Desktop and was not copied into public evidence because it also includes surrounding desktop/chat content.

Launched Amazon's installed home component through `vega device launch-app --appName com.amazon.keplerlauncherapp.main`. Component listing confirmed home VISIBLE and the farm NOT_VISIBLE. Asked the user whether home renders or remains black; visual result pending. Do not infer a simulator-wide failure until that observation arrives.

## Local graphics isolation — later October 20

The supported Appium Inspector now produces successful fresh screenshots when the emulator is launched with bundled alternative backends. Native launcher and game HTML loading page render. The actual Godot game still fails WebGL2 availability. Retained evidence: `docs/audits/2026-10-20-tv-eligibility/webgl2-error-inspector.png`, `webgl2-message-fixed.png`, and `graphics-probe-swangle.png` (paths relative to repository root). These are failure/diagnostic images, not qualifying gameplay.

The isolated `graphics-probe.html` reports secure context true, Chromium 144, WebGL1 true and WebGL2 false with `BindToCurrentSequence failed` on Mesa/virgl. Direct host EGL probes measured bundled ANGLE Metal GLES 3.0 / shader 3.00 and bundled Vulkan/SwiftShader GLES 3.1 / shader 3.10. Host capabilities did not establish guest capabilities. Tested SwiftShader, ANGLE Metal, SwANGLE, explicit Vulkan selection and dynamic GLES negotiation did not produce a working game. The original simulator config.ini was restored; process-local driver-selection experiments are diagnostic tools only.

The wrapper now identifies the specific missing-WebGL2 failure instead of blaming the laptop. Lint, TypeScript, four Jest tests/two suites and all three Release builds passed, and the corrected message was inspected. Use the full npm build command to rebundle changed JavaScript; direct native `vega build` reused stale JS in the first attempt. Stop the current app before relaunching an updated package to ensure it loads the new bundle/URL.

The user explicitly requires hardware-free execution entirely inside Vega; borrowing hardware and a streamed Mac backend are not the agreed solution. Side-by-side official SDK 0.24.9914 installation is underway while 0.24.12112 remains active. Older-image behavior is not yet known. No qualifying footage, public release update or Devpost correction resulted yet.

## Superseding port result

WebGL1 compatibility port now runs actual local farm gameplay/input in confirmed SDK 0.24.12112. Farm/QR, TV admission, two private controllers, walking/sheep event and tractor/dashboard/drive inspected. Software backends slow; faster Metal later host-crashed. Full strict Mac GLES2 routes passed, not full guest acceptance. See `../2026-10-20-vega-port/README.md`. Earlier older-SDK observations overlapped device ports and do not establish a version fix.
