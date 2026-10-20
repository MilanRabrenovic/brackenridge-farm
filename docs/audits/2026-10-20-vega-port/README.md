# Local Vega WebGL1 port — October 20, 2026

## What exists

A generated Godot 3.6.3 GLES2/WebGL1 build of the existing complete two-player game. All simulation/rendering runs inside the official Vega WebView. The Mac runs only static hosting and the input relay. Original Godot 4 source and normal browser route are retained. See `platform/vega-gles2/README.md` for reproduction.

## Retained evidence

- `vega-metal-gameplay.png`: actual 1280×720 guest game screenshot downloaded through Appium Inspector. Tractor driven upright to crop gate, live guidance and minimap. Metal backend later crashed; this is rendering/input evidence, not stability acceptance.
- `metal-tractor-inspector.png`: same platform test with Inspector context.
- `swangle-coop-inspector.png`: actual new SDK 0.24.12112 SwANGLE session, two admitted independent browser controllers, both farmers, sheep event and public guidance. Controller 1 uses 127.0.0.1 and controller 2 localhost, isolating reconnect storage. TV Select admitted through official driver command UI.
- Earlier lobby/software gameplay captures are in `../2026-10-20-tv-eligibility/`.
- `missions.txt`, `map-movement.txt`, `solo-physics.txt`, `coop-physics.txt`, `verification.txt`: final strict automated Mac GLES2 checks. Complete solo/co-op motor routes passed all jobs/results/replay, with no actor/crop teleports in the co-op route. They do not prove a complete actual Vega weekend.

## Findings

Official Godot 3.6.3 editor and export templates match official SHA-512 sums. Four strict suites and export passed. Wrapper lint/TypeScript, four Jest tests/two suites and all three Release builds passed using Node 24. A restricted Watchman attempt failed EPERM; disabling Watchman allowed the normal test runner. Original Godot 4 2D regression/Web export passed after fixing a stale solo banner when the second player joins; two existing Godot 4 ObjectDB exit warnings remain.

Actual guest: newer SDK serial amazon-835a951bf5d61cec. Older/newer images initially overlapped on shared device ports; all such ambiguous observations are excluded. Clean single-image tests established the newer identity. Old SDK installation is not a verified fix.

| Backend | Actual result | Limit |
|---|---|---|
| swiftshader_indirect | QR/admission/farmer walking/sheep event rendered | Slow, roughly 270–400 ms median acknowledgements in observed samples |
| angle_indirect | Two controllers, tractor dashboard/boarding and upright drive rendered | Roughly 50–66 ms median sample; later entire host emulator SIGSEGV, exit 245; unsuitable stable default |
| swangle_indirect | Two-controller admission/private facts, movement and sheep event rendered | Roughly 300–400 ms median, p95 sometimes above one second; short check only |

Acknowledgements include input/frame/network scheduling and are not FPS. Software backends are functional troubleshooting fallbacks; responsive sustained play remains unresolved. No full guest weekend, physical hardware, human fun approval or replacement qualifying video/public release/Devpost update is claimed. Existing Mac video remains a Mac preview.

## Next

Improve/establish sustained simulator performance before claiming a finished qualifying platform build. Then capture genuine Vega gameplay with English captions/original music and update the submission. Do not replace local execution with Mac streaming or require hardware: the user rejected both.

Handoff: SwANGLE simulator and normal relay left running; app restarted and a fresh zero-player QR lobby visually verified (`final-lobby-inspector.png` in the port audit). Temporary browser controllers closed. Use the live QR, never a saved room code.
