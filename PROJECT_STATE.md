# Current project state

Updated September 30, 2026. Active game: **Brackenridge Farm**, original 2D two-player cooperative weekend. This is a playable release candidate with completed scripted routes; **hackathon submission readiness is not yet established**. Previous status entries are preserved in `docs/history/2026-09-30/PROJECT_STATE.md` and are historical.

## September 30 completed implementation pass

- Added host-owned `WeekendSession2D`: arrival/tutorial, sheep guide-and-gate, two £20 planning decisions, asymmetric repair/supply, timed rain/harvest/storage protection, buyer/stock dispatch, outcomes/contributions/balance and replay.
- Normal cooperative deadlines total roughly 14–15 minutes; successful jobs advance immediately. Failure continues with reserve apples rather than trapping the run. Seed variants affect timing/order; not a full adaptive AI Director.
- First phone launches a full assisted solo test weekend with normal mission deadlines. Gate holder, repair diagnosis/helper and loading assistance are provided; harvest starts unprepared and requires the entire crop lifecycle. Second phone admitted during arrival promotes to co-op; after arrival restart with R to choose two-player mode.
- Phone buttons share the current clue on TV, return held cargo/part, pause/resume. Automatic token reconnect restores slot/clues/mode. Missing required farmer (including solo) pauses clocks/crops; manual resume cannot bypass that pause.
- Quick action down/up packets are buffered through the next simulation tick. Keyboard E/slash also buffer taps. Host still owns movement and input sequencing.
- Integrated matching four-direction tractor under the user's explicit finish-game instruction, without inventing separate final visual approval. No whole-image rotation. Side wheel art rotates independently; suspension responds to actual movement. Safe exit checks open nearby space and restores farmer collision. Replay clears vehicle/cargo/input state.
- Existing walk sheets use directional animation, foot anchoring and idle breathing. Existing crate art shows carrying. Dedicated carry/repair/boarding animation sheets remain absent.
- Retained coherent reference-led farm: measured layout v5, connected lanes/yard, reusable layered art, structural/tree/boundary/river collisions, foreground reveal, crop lifecycle and close shared/split cameras. Dressed rear interior walls with existing props; moved them off an access point found by clearance tests. Furnishings anchor against structural collision; no new corridor-blocking collision was retained.
- Added rain shader/overcast transition, original synthesized objective bell/mute, green/cream mission/results UI, raised objective waypoints to avoid sign overlap, original barn icon and stone-barn launch splash.
- Added weekend regression and corrected the host test to exit nonzero after failed assertions. Updated relay test for the arrival stage and verified command player identity comes from the connection.
- Prepared signed Fire OS debug APK, Web export, source packaging script, run instructions, provenance and `docs/SUBMISSION.md`. No GitHub/video/Devpost publication performed.

## Verification evidence

| Check | Recorded result |
|---|---|
| TypeScript | `npm run typecheck` passed |
| Node relay/layout/QR tests | Nine tests passed using ARM Node; socket tests require normal local socket permissions |
| Real relay → Godot | Passed; latest recorded frame acknowledgement 25.7 ms; two private welcome cards, screen-axis input and tractor mode |
| 2D host | Passed with corrected failure exit; crop states, collision/occlusion, walk animation, admission and adaptive cameras |
| Map | 468 road/vehicle-envelope samples, zero blocked; all ten interaction destinations connected through actual physics space |
| Repair | Passed diagnosis, wrong/correct parts, joint hold, timeout and two-occupant cutaway |
| Weekend | Three complete scripted successful routes, rejected goods, joint loading, failed jobs continuing, solo repair, pause/drop/replay, quick-tap buffer; 1000 repeated seeds stable within three variants |
| Tractor | Four upright direction-selection assertions/native review captures passed; wheels inspected in side view |
| Native art/UI | Mission, results, split, yard/map and cutaway inspected. `docs/audits/2026-09-30-release/` and `docs/audits/2026-09-28-cohesive/release-*.png` |
| Browser | Fresh exported game visibly reached QR lobby and admitted phone; pause worked, quick ACTION entered tractor, dashboard rendered, EXIT restored latest walking clue. No browser errors observed; final fresh lobby left open for joining (`browser-ready.png`). 390×780 controller had no horizontal overflow |
| Web packaging | Export passed and actual exported PCK startup smoke passed; scripts/rain included |
| Source packaging | Source ZIP passed CRC/required-file checks; cache, environment and signing-key entries excluded; SHA-256 manifest written |
| Vega wrapper | Official WebView template, configurable host URL, full-screen sizing and startup diagnostics. Debug/release builds passed; lint, TypeScript and one template render test passed. Install/launch and loopback startup passed: simulator downloaded PCK/WASM/worklets and created a Godot room; **full gameplay/rendering/remote not verified** |
| Fire OS packaging | Signed debug APK exported; v2/v3 signature verification passed. Execution on Fire TV **not tested** |

Scripted tests move actors directly for some interactions; they do not establish full human playability, fun, typical duration, or Fire TV performance. Native mission/results captures are staged visual review, not live completion footage. A small ObjectDB exit warning remains in the host test; no gameplay failure was observed from it. Restricted shell runs produced macOS certificate/log-path warnings; an unrestricted weekend run passed with result saving.

## Files / running route

`npm run dev` serves the prepared browser host at `http://127.0.0.1:8787/host/`; same-Wi-Fi phones use the LAN QR URL. Relay must remain running. Re-export/reload after source changes. Read `USEFUL_COMMANDS.md` for controls/install/tests. Deliverables: `artifacts/countryside-coop-debug.apk`, `build/web/`, `artifacts/brackenridge-farm-source.zip`, `artifacts/release-manifest.json`, `artifacts/brackenridge-farm-vega-aarch64.vpkg`. Vega source/setup: `platform/vega/README.md`.

## Unresolved acceptance and submission requirements

1. No physical Fire TV was connected. Amazon Vega SDK 0.24.12112 and its aarch64 TV simulator were installed; simulator reported OS 1.2 (TV Ship/102282480). An official WebView wrapper was generated, configured and built in debug/release, installed and launched. The simulator reached the laptop host URL with HTTP 200. The initial LAN HTTP route was blocked by WebView cleartext policy and Godot secure-context checks. Scoped cleartext configuration plus VDA reverse-port forwarding to trusted loopback allowed PCK/WASM/worklet downloads and creation of a Godot room on the isolated relay. Full gameplay/rendering was not confirmed: the native window was unavailable to the inspection tool and the documented SDK framebuffer capture hung and yielded an empty file, excluded from evidence. Performance, TV remote navigation, QR/networking in the running game and qualifying demo footage remain unverified. APK and Vega packages are separate candidates.
2. No two-human complete weekend test this pass. Deadline tuning, readability on a TV, reconnect under real Wi-Fi and final visual approval remain required.
3. No public/private reviewer GitHub repository or public video link exists yet; no Devpost entry was submitted.
4. Four-player support, bespoke work/carry/boarding frames, full animal gait animation, extensive interiors, Bedrock, hosted relay, combine/trailer driving and tool attachments are deferred and must not be advertised as implemented.

## Single recommended next task

**Play the updated full solo weekend in the browser with one phone and review the art/readability at normal speed.** Local solo development continues without a two-human or TV gate. Fix observed solo issues first; the two-human full run and TV runtime/qualifying footage remain final submission checks.

## Vega setup limitations

The supervised simulator initially stopped when its launching shell ended; retaining that shell kept the device connected. Idle/background transitions were observed; no cause of missing gameplay confirmation is established. The official template install reported 27 dependency vulnerabilities (14 moderate, 13 high); SDK compatibility was preserved rather than force-upgrading. Read `platform/vega/README.md` before continuing. SDK tools, caches and installed dependencies are excluded from the source ZIP.

## September 30 — simulator startup correction

Configured only the chosen relay host in Vega cleartext policy; HTTP LAN URLs still fail Godot secure-context checks, so the candidate now targets trusted loopback with VDA reverse forwarding on port 8787. Isolated port-8788 evidence: host HTML/JS/PCK/WASM/audio worklet requests returned 200 and health reported a newly created room. Added opt-in resource-path/status trace with no queries/tokens. TypeScript passed; nine relay/layout tests passed using ARM Node after default Rosetta Node failed on esbuild architecture. Release wrapper rebuilt. This is concrete startup evidence, not full phone/remote/rendering verification. The default simulator status command reported false with SDK-resolution warnings while explicit device listing remained connected; use device list/info to establish connection.

The final loopback package on port 8787 created a second room alongside the existing Mac browser room. Corrected debug package also built/installed; documented DevTools forwarding on port 9229 was attempted, but its inspector URL returned `ERR_EMPTY_RESPONSE`. No remote rendering/keypress evidence was obtained. This turn made progress by fixing startup; the finish goal remains active.

## September 30 — phone-only inactivity / acceptance audit

Added Vega `useSetTimeoutCallback(1800)` so the component requests enough inactivity time for joining plus a normal weekend; this does not disable system sleep. Lint, TypeScript, the template render test and debug/release builds passed. After Debug install/launch, SDK reported the component running more than two minutes later; the forwarded inspector still returned an empty response. The default Android device list contained only emulator-5554, identified separately as the Vega TV virtual device; no physical Fire OS device is connected. The requirement-by-requirement audit is `docs/COMPLETION_AUDIT.md`. Full rendering/remote/cooperative device play and qualifying recording remain unverified.

Final acceptance blocker: with the component active, the documented framebuffer capture again remained running without an image and was cancelled after the diagnostic deadline. The inspector endpoint returned an empty response. No physical Fire OS device is connected and no two-human full device run or qualifying footage exists. These external verification gates remain unresolved across three goal turns; the finish goal is blocked, not complete. Resume once a usable device/view and playtest evidence are available.

## September 30 — full solo testing continuation

The user changed the testing order: complete solo testing first and leave real two-player acceptance until final integration. Replaced the shortened, ripe-crop sample with a full assisted solo weekend using normal deadlines and unprepared soil. Helpers cover only the second-person gate/diagnosis/hold/loading requirements. Solo clues explain crop work, apple covering, planning and dispatch. Mission changes preserve the occupied tractor dashboard and EXIT button.

Added `test:solo`, a complete route through the actual CharacterBody walking/tractor motors and collision space: all five sheep herded, belt collected/delivered/fitted, field entered by tractor, all seven natural crop stages observed, grain stored, apples covered, two loads carried/packed, assisted delivery, results and replay. No actor teleports or direct crop-stage changes on this successful route. Runs at accelerated simulation speed; 219 seconds of motor simulation plus two explicit 26-second planning waits. This is automated local evidence, not a human pacing measurement or TV proof. The former blocked external acceptance status is historical; the user's continuation authorizes solo work while multiplayer/TV acceptance remains deferred.

Verification for the solo pass: headless motor route passed; native rendered motor route passed with all four mission outcomes successful and results at about 4:30 simulation time including planning waits. Inspected repair, harvest and results captures. Corrected the objective status row overflowing the right edge and removed duplicate repair labels; native recapture and screen-bounds assertion passed. Existing weekend, repair and 2D host regressions passed. Web export/exported-PCK smoke passed; fresh browser reloaded. macOS restricted log/certificate warnings and the pre-existing small 2D-host ObjectDB exit warning remain. No new map assets or placement changes in this pass.

Final local browser check: a single test controller joined and was admitted; the large lobby disappeared and the host showed SOLO TEST WEEKEND with full arrival time. Phone received the correct welcome card and 18 ms median / 30 ms p95 frame acknowledgements. Closed the temporary controller and reloaded the host for the user's phone. Web and Fire OS exports rebuilt successfully; TV execution remains untested.

Source packaging now includes the September 30 solo route captures alongside release captures, so the ZIP preserves the new review evidence. Rebuilt the source archive and four-artifact hash manifest.

## September 30 — input pipeline and solo disconnect

Strengthened the full solo route: movement packets now pass through `_handle` and the normal `_physics_process` tick; ACTION/EXIT use buffered down/up messages, never direct interaction calls. The first input-pipeline route completed all four jobs and replay (217.3 seconds of movement simulation, plus explicit planning waits). This closes the gap between motor-only routing and host input integration; it still does not cover real network/browser rendering for the entire route.

Fixed solo phone loss: the only farmer disconnecting now pauses mission clocks/crops rather than letting jobs expire behind the lobby. Reconnect restores the prior pause state, including a deliberate manual pause, for solo and cooperative sessions. Replay clears remembered disconnect pause state. Added assertions for solo disconnect freeze, automatic reconnect resume and preserving manual pause.

Input-pipeline verification completed: headless full route passed including the new reconnect assertions; native full route/capture passed, inspected successful results at 4:28 simulation time (not a typical human duration). Existing three-route weekend/failure tests passed. Rebuilt Web with exported-PCK startup smoke and Fire OS APK successfully; browser host reloaded for the user.

Real relay→Godot integration also passed with 25.7 ms frame acknowledgement, private clues, screen-axis movement and tractor phone mode. Default Rosetta Node failed on esbuild architecture; bundled ARM Node was used. Its first restricted attempt could not bind the local socket; rerunning with local socket permission passed. No physical Fire OS or human multiplayer acceptance claim is made.

## September 30 — readable farming progression

Replaced the generic harvest objective with live cultivation, sowing, growth countdown, harvest, storage and apple-covering guidance. Work phases show unique cells completed out of 16. The objective marker targets the barley field until harvest, then grain intake, then apiary once grain is stored. The grower's phone receives updated task instructions when crop/stock state changes; the partner retains the separate storage clue. Entering the tractor during weather restores the current guidance without replacing EXIT/dashboard mode. No new artwork or map placement in this pass.

Added assertions for initial cultivation guidance, harvest EXIT/storage guidance and preserving the partner's private storage clue. A typed-string compile error was found on the first test run and corrected; test startup now exits with failure if host/session initialization fails rather than hanging after a compile error. Verification results follow below.

Crop-guidance verification: full headless solo input route and three-route weekend/privacy regressions passed. Native route completed with successful results; inspected current cultivation and harvest/storage frames and confirmed panel fit. An observation delay left the native process live with no new capture for several polls; re-polling the same process returned completion, without restarting it. Web export/PCK startup and Fire OS APK export passed. Reloaded the browser host; no physical TV acceptance added.

## September 30 — release audit and seeded faults

The requirements audit found that repair always asked for the belt, making repeat-session communication avoidable. Repair now selects a slipping packing-drive belt fault or leaking packing-pump gasket fault from the existing deterministic variant. The mechanic alone receives the diagnosis in cooperative mode; the runner receives both supply locations. Wrong parts are rejected, and both correct fault routes work. Solo receives the combined helper instructions. No new incident family, art or location was added.

Three-route weekend tests passed with both seeded faults, wrong/correct-part assertions and diagnosis privacy. Full solo input route passed; original repair/dual-interior regression passed. Inspected staged native belt/gasket solo instruction frames (`repair-belt.png`, `repair-gasket.png`); these force variants for wording review and are not completion footage. Corrected stale short-sample wording in GAME_PLAN and the submission draft's startup claim. Web export/PCK startup passed; refreshed Fire OS export and source packaging follow. Human multiplayer, TV rendering/performance/remote, qualifying video and repository publication are still outstanding; no submission-ready claim.

Release audit verification: refreshed Fire OS export passed and the resulting APK verified with v2/v3 signatures. Browser export and exported-PCK startup smoke passed. The browser was confirmed idle with zero joined farmers before reloading the fault update. Source package/hash refresh follows; execution on Fire OS remains untested.

## September 30 — source handoff preparation

Verified GitHub authentication with normal network access (the restricted attempt incorrectly reported an invalid token). The intended `MilanRabrenovic/brackenridge-farm` repository does not exist. Extracted the curated source into `artifacts/submission-source/brackenridge-farm/` and initialized an isolated local Git checkout; the development workspace itself is unchanged. The largest retained source file is 8.1 MB. A credential-pattern scan of 122 text source/doc files found no matches; SDK/cache/environment/signing-key files remain excluded by packaging. Publication/visibility is pending the user's decision. Instructions and exact limitations are in `docs/SOURCE_HANDOFF.md`.

Source handoff result: baseline local commit `ba36a38` contains 712 tracked files. The publishing checkout was verified clean with no remote. The curated ZIP contains 713 files because the diagnostic HTTP trace is ignored by Git. No dependency, toolchain, environment or signing-key files are tracked. Documentation evidence is committed separately before the visibility decision; no external repository was created or pushed.
