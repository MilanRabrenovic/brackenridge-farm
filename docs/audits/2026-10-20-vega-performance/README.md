# Vega responsiveness pass — October 20, 2026

## Result and scope

The official SDK 0.24.12112 emulator's **host OpenGL backend** (`--gpu host`) renders the local WebGL1 game and responds substantially faster than the software alternatives. Guest serial remained `amazon-835a951bf5d61cec`. Launcher log confirms `library_mode host gpu mode host`. The previous Metal ANGLE crash does not apply as a successful result to this different backend; its failure is retained separately.

Actual observed controller samples:

| Setup | Median / p95 acknowledgement |
|---|---|
| Previous SwANGLE before this pass | 276 / 668 ms during short movement sample |
| Static-terrain bake, SwANGLE | 167 / 293 ms short sample; later full bake 168 / 419 ms |
| Host OpenGL, first solo movement | 39 / 65 ms |
| Host OpenGL, second farmer in split view | 39 / 79 ms |
| Host OpenGL, crop-side walking | 37 / 126 ms |
| Host OpenGL, tractor dashboard parked / driving | 35 / 54 and 43 / 100 ms |
| Host OpenGL, short field drive | 71 / 278 ms |

These are rolling phone-controller acknowledgement samples, not pooled benchmarks or display latency/FPS. Input was provided through ordinary browser controller UI and official TV Select admission, not actor placement. Short spikes remain; no 60-fps guarantee.

Debug-only startup samples visibly showed 44 fps / 40 ms p95 frame interval and 53.1 fps / 37 ms. Samples measure engine process-frame intervals for five seconds each, twelve samples during the first minute. The final value remains visible after sampling ends: the retained split/tractor Debug captures therefore **must not be described as a live split/field FPS measurement**. Final wrapper text explicitly says “Startup sample”; Release hides diagnostics. Only counts/durations are reported locally; no room/input/private facts are included.

## Implementation

- Bake the unchanged static terrain material once at build time, at 2040×1440. Keep the animated water in an independent shader clipped to its authored channel bounds.
- Bake the existing five-sample extraction cleanup into six individual building textures. Preserve straight RGBA with blending disabled during export. Buildings stay separate sprites, with unchanged collisions, entrances, reveal/cutaway behavior and sorting.
- Cache derived assets by source/shader/layout digest. The exporter's complete import path is used before tests; editor `--quit` aborted new-resource scanning and was replaced.
- Preserve all crop growth stages, separate objects/actors, shadows, foliage motion, phone protocol and simulation. Original Godot 4 game/art source is unchanged by this pass.
- Add bounded local startup frame timings and a Debug-only native display. Numeric reports never mark startup ready or hide errors; regression added.
- Simulator launcher now supports/defaults to SDK `host`; software fallback remains available. No image/SDK/system security setting was modified.

## Verification

Strict Godot 3 mission, map/movement/animation, full solo and full co-op input/physics routes passed, including outcomes/results/replay. WebGL1 export passed. Wrapper lint, TypeScript, five tests/two suites, Debug and Release all three architectures passed. Python syntax checks passed. Retained text logs accompany this README.

Actual host-backend guest inspection: two independent private controllers, walking, split and merged cameras/minimap, sheep event, building cutaway, tractor entry/dashboard/upright travel and crop-side rendering. Actual mission timer advanced from arrival through sheep failure/planning into repair during this technical session. This was a responsiveness test, not a successful full human cooperative weekend.

`host-split-debug.png` and `host-tractor-debug.png` retain actual guest/Inspector context. Final Release captures/handoff and simulator duration are recorded in PROJECT_STATE. No revised public video, GitHub release or Devpost correction is implied by these files. Human fun/pacing and physical hardware behavior are not tested by this pass.

## Earlier failed checks corrected

The first timing Node inherited an irrelevant generic CanvasItem alias and failed to parse; it is now excluded from that alias. Newly baked structures initially lacked completed engine import resources because `--editor --quit` exited too early; using completed export/import fixed all six. Strict reruns passed after both corrections. A lint redirection from the wrong directory failed before running; the correct wrapper commands passed. Initial sandboxed native baking lacked graphics-service access; normal local graphics permission was used.

## Next

Record genuine Vega Release gameplay with English captions/original music and refresh the public candidate/submission accurately. Keep the distinction between observed simulator checks, full automated Mac routes and human playtesting.

Final local candidate refresh: aarch64 Release 156,118 bytes, Web ZIP 34,299,533 bytes, CRC and SHA-256 checks passed with current licence notices. Host backend mixed session exceeded 15 minutes without observed crash. Final Release two-controller split view and disconnect/reconnect pause/resume inspected; captures `release-disconnect-paused.png` and `release-reconnected.png`. No successful full human/guest weekend or hardware-wide stability guarantee is inferred. Public artifacts/video/submission remain unchanged.

Handoff verified: final Release is running at a fresh zero-player QR lobby with no Debug strip (`final-release-lobby.png` in the performance audit); temporary controllers closed. Keep simulator launcher and relay running, scan the live QR and press TV Select/Enter to admit. Recommended next task remains genuine platform demo/public submission correction.

Final liveness observation: the host-mode launcher/emulator session remained alive at 22:02 elapsed, without observed crash, across the mixed Release/Debug checks. This is a 22-minute mixed technical session, not 22 minutes of continuous successful cooperative play.
