# September 30 candidate review

Reviewed native mission/camera screens, directional tractor, rear-wall cutaway furnishing and fresh browser startup/controller interaction.

- `arrival.png`, `weather.png`, `dispatch.png`, `results.png`: deliberately staged native visual captures; not human completion evidence.
- `tractor-phone.png`: real exported-browser session at 390×780; upright tractor mode retained through mission changes; quick tap entered and EXIT restored latest role clue.
- `browser-ready.png`: final fresh exported browser lobby, left open with no errors observed.
- `browser-gameplay.png`: live browser/phone paused mission review.
- `../2026-09-28-cohesive/release-*.png`: current native yard, overview, crop, shared/split, interior and repair review. Earlier files in that folder remain historical.
- `../2026-09-28-cohesive/tractor-{down,up,left,right}.png`: current upright directional native review.

Found/fixed: lost short action tap, overlapping objective/sign label, stale vehicle collision on replay, phone bypass of disconnect pause, test falsely returning success after an assertion failure, rear interior furnishing reducing route connectivity. Final map check: 468 samples and all destinations reachable.

Presentation is coherent at local gameplay scale. Repeated foliage, baked perspectives, compact cutaways and absent dedicated work/animal animation frames remain quality limits. No Fire TV/device performance or final user art approval is inferred from this review. Read root PROJECT_STATE for current verification and SUBMISSION for the remaining qualifying steps.

## Vega startup correction

September 30: WebView HTTP policy and Godot secure-context requirements prevented the initial LAN route. The configured host is now allowlisted explicitly; simulator development uses VDA reverse forwarding to trusted loopback. `vega-startup-http.log` records engine/PCK/WASM/worklet downloads on an isolated relay, whose health endpoint reported one Godot room. Final normal-port package produced a second room alongside the Mac browser room. SDK framebuffer capture hung and its zero-byte image was removed from evidence. The forwarded Debug inspector returned an empty response. Startup is proven; full rendering, controls, cooperative play and qualifying footage are not.
