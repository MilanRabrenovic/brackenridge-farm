# TV inspection evidence — October 5

`inspector-pending.png` records the native Appium Inspector waiting on a later source/screenshot refresh. Earlier UI observation returned a black 1280×720 view; that observation was not saved as a completed game frame. Do not treat this pending screenshot as game rendering, TV success or qualifying footage.

Appium 2.2.2, Amazon Kepler driver 3.30.0, Inspector 2026.9.2 ARM; official release ZIP SHA-256 verified. Initial session stalled while game absent. After confirmed stop/relaunch, component list showed game VISIBLE and renderer READY. Window/source access succeeded; screenshot black. GUI-issued UP accepted by driver, visible behavior unverified. Later refresh pending. Repeated GWSI buffer-state logs do not establish root cause. See platform/vega/README.md for supported setup and next diagnostic.

## Instrumented debug run

`startup-diagnostics.log` contains only six `farm-startup` canvas reports from the real fresh debug run, excluding system logs, room codes and phone tokens. Canvas changed from 300×150/not ready to visible 1280×720/ready approximately ten seconds later; secure context and WebAssembly were available, failure notice empty. Final sampled state remained ready.

`inspector-flat.png` records the native debug strip reporting that state alongside a flat-coloured game surface. It proves native diagnostic text was drawn in the capture; it does not show the farm or establish whether capture, compositor or actual game rendering failed. No qualifying footage. The readiness flag tests dimensions and Godot startup-overlay removal, not pixel output.
