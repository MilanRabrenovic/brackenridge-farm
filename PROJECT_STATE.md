# Current project state

Updated October 5, 2026. Active game: **Brackenridge Farm**, original 2D two-player cooperative weekend. This is a playable release candidate with completed scripted routes; **hackathon submission readiness is not yet established**. Previous status entries are preserved in `docs/history/2026-09-30/PROJECT_STATE.md` and are historical.

## September 30 completed implementation pass

- Added host-owned `WeekendSession2D`: arrival/tutorial, sheep guide-and-gate, one confirmed £20 planning decision and a delivery briefing, asymmetric repair/supply, timed rain/harvest/storage protection, buyer/stock dispatch, outcomes/contributions/balance and replay.
- Normal cooperative deadlines total roughly 14–15 minutes; successful jobs advance after a three-second result beat. Failure continues with reserve apples rather than trapping the run. Seed variants affect timing/order; not a full adaptive AI Director.
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
| Repair | Passed inspect-to-discover private diagnosis, wrong/correct parts, pressure regulation/overheat, runner fitting, maintenance, timeout and two-occupant cutaway |
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

**Observe a first-time normal-speed run for clarity, then a two-person run for communication, idle periods and replay interest.** The local mission improvements below address the audited defects; human pacing/fun and qualifying TV footage remain acceptance checks.

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

## September 30 — browser startup recheck

Inspected the live browser, joined a temporary controller and admitted it with Enter. The lobby disappeared, SOLO TEST WEEKEND arrival rendered and the controller received the walking/tractor welcome instructions. Frame acknowledgements settled to 23 ms median / 25 ms p95 in this brief local check. This verifies startup only, not a full normal-speed browser playthrough. Closed the temporary controller and reloaded the host; the fresh QR lobby rendered with zero farmers. Normal-permission ADB listing now contains no devices. No code or art changed, and no full-suite rerun was warranted. Source visibility remains pending; refresh the publishing snapshot after these documentation changes before any publication.

## September 30 — mission experience audit (historical baseline; superseded below)

The user made mission fun, clarity and attention the priority. Ran the full native solo input route again successfully (221.5 seconds of simulated input plus explicit planning waits; rendered results 4:33). Ran the three-route weekend/failure/private-clue regression successfully. Added and executed `capture_mission_audit.gd`, then inspected eight staged cooperative mission states and private cards, plus current actual solo route frames. These are an expert usability review and automated regression, not a human fun/pacing study. No gameplay balancing or art changed.

`docs/MISSION_EXPERIENCE_AUDIT.md` records confirmed defects and inferred boredom risks. The second planning purchase affects only jobs already finished, and ownership is not checked. Hold-to-buy confirms on one tick. Mission results are immediately overwritten. Weather work is uneven, field stages change globally after 16 small cells, original clues are overwritten by cargo/status messages, and contribution scoring rewards repeated commands. These findings supersede any assumption that mechanical completion proves an engaging experience. The audit report gives the exact next implementation pass. Restricted Godot log/certificate warnings remain; no failed mission regression. Source ZIP/publishing snapshot now need refreshing after this audit addition before publication.

## September 30 — mission improvement implementation

Implemented the local audit fixes within the four existing incident families: acknowledged hay tutorial, eight-second gate windows, three-second purchase hold/reset/ownership guards, delivery briefing replacing late spending, readable success/failure beats, 16 marked field plots with local worked patches and deliberate sow/harvest tool engagement, intake sealing, optional crate preparation, visible cover/storage progress, persistent private facts plus current hints, correct cargo guidance, outcome-dependent loading/rewards and deduplicated task recognition. Failed repair slows delivery; crates shorten loading. No art asset or world placement was changed. Field stages still change globally after all plots; this is an abstraction, not continuous per-plant simulation.

Verification: full solo input/physics route passed and rendered results at 5:18 simulated time (266.9 seconds of input simulation plus explicit planning waits); three cooperative scripted routes/failure/privacy checks and 1000 seeds passed; new mission regression, existing 2D/repair tests, nine Node tests and TypeScript passed. Native eight-screen staged review passed. Initial tests exposed outdated immediate-transition/tool assumptions and a test tap lacking release after sealing; fixtures/input test were corrected. A cover expectation was corrected for the purchased shelter's faster duration. The pre-existing small 2D-host ObjectDB exit warning remains. These are automated/expert checks, not human fun evidence.

Phone tractor UI inspected at 390×780 with dashboard, tool and steering/EXIT controls visible. Web export plus actual exported-PCK startup passed; Fire OS export and v2/v3 signature verification passed. Physical TV execution remains unverified. Current evidence and residual design risks are in `docs/MISSION_EXPERIENCE_AUDIT.md`. Source packaging includes current mission review captures. The curated source ZIP passed CRC and required mission-test inclusion checks; the release manifest records refreshed hashes; the separate Git publishing snapshot remains older and must be refreshed before publication. No external source upload or submission was performed.

**Single recommended next task:** observe a first-time normal-speed run for clarity, then a two-person run for communication, idle periods and replay interest. Mechanic waiting, split-view offscreen navigation, simplified field stages and bespoke work animations remain limits; do not call the game fun-tested or submission-ready.

Final handoff: browser freshly reloaded and visibly reached the QR lobby with zero farmers; relay remains running. Final APK signature check passed with the bundled JDK (the initial plain invocation lacked JAVA_HOME). Exported Web/PCK and APK contain the final instruction wording. The isolated publishing Git checkout remains stale, explicitly documented in SOURCE_HANDOFF.

## September 30 — sheep personality and animation

Added a four-second staggered fence breakout at the beginning of the existing sheep event, with seed-controlled jump order, bounded fleeing/jinks when rushed and calm guiding unchanged. Sheep now move diagonal leg pairs independently through a shader using the existing raster art; cadence responds to movement, bodies settle subtly and hop shadows stay at ground level. Animation/wandering use simulation time, not wall-clock noise. Recovered sheep remain safe: no surprise repeated progress loss. No new incident family, map placement or generated asset was introduced. This is lightweight art deformation, not an authored directional gait sheet; fixed illustration perspectives remain visible.

Verification: full headless solo input/physics route passed (266.0 seconds of input simulation plus planning waits). Three complete scripted co-op routes, failed-job recovery and 1000 seed selections passed. Focused sheep test and native four-frame capture passed; inspected frames 0 and 2 at real gameplay scale. Restricted macOS log/certificate warnings remain. Web export/exported-PCK startup and Fire OS export/v2/v3 signing checks passed; source package refreshed for this change; physical TV execution and human fun remain unverified.

**Single recommended next task:** normal-speed first-time co-op playtest, recording time to understand objectives, idle time (especially the mechanic), wrong turns and replay interest. Use that evidence to improve repair/weather participation and split-view navigation. Do not treat local regression success as human fun or hackathon submission acceptance.

## September 30 — active co-op repair

Replaced the mechanic's continuous fitting hold with pressure regulation: ACTION inspection reveals the seeded fault; HOLD pumps and RELEASE cools, while the runner fetches/delivers and holds to fit. Both must remain at the bay, with pressure 40–75% green. Overheating or low pressure pauses fitting without erasing it; six seconds of safe fitting are needed, three with maintenance. Solo helper balances pressure. Added readable sage/cream instrument UI and playful overheat/success copy. Arrival's second-phone instructions now name CHECK HAY rather than a vague blue marker. No incident family, map placement or raster asset was added; no physical repair/work animation was authored.

Verification: full solo input/physics route passed (266.0 seconds of input simulation plus planning waits). Three scripted co-op routes and failure/privacy/1000-seed checks passed after adapting the mechanic inputs. Repair checks cover absence, overheating, cool-down, held-progress, correct/wrong part, maintenance, private-fact persistence, timeout and cutaway. Mission checks passed. Initial checks caught a percent-formatting error and tests assuming continuous joint hold; fixed both. The weekend test's released mechanic input also needed resetting before its separate covering stage. Native low/green/hot captures inspected, panel fit checked. A restricted native launch hung before graphics initialization; stopped it and the normal-permission capture passed. Existing restricted certificate/log warnings remain.

Web/Fire OS/source packaging is refreshed for this pass; detailed final checks follow. Human fun, balanced participation, normal-speed pacing and physical TV execution remain unverified. The isolated publishing Git snapshot is still older than current source.

**Single recommended next task:** normal-speed co-op playtest with first-time players, recording repair communication/pressure understanding, idle periods, navigation difficulties and replay interest. Per-player offscreen navigation, directional animal/work animations and physical TV acceptance remain open; no submission-ready claim.

Final repair packaging checks: first exported-PCK smoke rejected the missing dynamically referenced gauge script. Added it explicitly to both export presets. Rebuilt Web/exported-PCK smoke and Fire OS export successfully; APK v2/v3 signature check passed. Refreshed curated source package includes the gauge, updated tests and repair review evidence. No public repository upload or TV execution was performed.

## September 30 — adaptive minimap

Added a live schematic minimap using authored field/road/building data, river, farmer identity markers and public mission targets. It sits at bottom-centre over the split seam when farmers separate, moves to bottom-right when they share a camera, and hides for QR lobby/results. Solo shows only the active farmer. Order/diagnosis details remain private; targets never inspect buyer preference. The map draws one compact UI chart rather than rendering a second farm viewport. No art asset, map placement, mission mechanics, input or collision was changed. Added both export-filter entries for the dynamically loaded script.

Verification: existing 2D host checks passed. Focused minimap test checks shared/split/merge/solo layouts, lobby/results visibility, privacy, packed-order van targeting and small-window logical bounds. Native staged shared/split/merged captures inspected; adjusted footer spacing after review. The first capture test called an incorrectly named method and hung; stopped its test processes and corrected it. The small-window assertion initially compared physical window size with the stretched logical viewport; corrected the coordinate-space assertion. Restricted certificate/log warnings remain. Export/source final results follow. This verifies local UI behavior, not physical TV readability or human navigation success.

**Single recommended next task:** observe a normal-speed two-player run with the minimap, checking if first-time players locate field, intake, packing and van without help, alongside pressure-minigame comprehension and idle time. Physical TV acceptance, human fun and published submission evidence remain open.

Final minimap checks: native and headless minimap tests passed; Web export plus actual exported-PCK startup passed; Fire OS export and v2/v3 APK signature verification passed. Source packaging includes the minimap script/test and shared/split/merge review frames. The original browser surface briefly had zero width/empty rendering; a temporary 1280×720 test viewport allowed a fresh export load, with final browser startup checked separately. Physical TV readability and performance remain untested.

Browser handoff: fresh exported game visibly reached the QR lobby with zero farmers; minimap correctly hidden there. Restored the temporary viewport override. Relay remains running for phone joining.

## October 5 — Android packaged-resource verification

Rechecked adaptive minimap behavior: focused headless test passed for shared/split/merge placement, solo visibility, public target privacy and small-window bounds; inspected the existing split gameplay capture. No minimap/gameplay/art changes were needed.

Added `scripts/verify-fireos-assets.py` and integrated it into `export:fireos`. It checks APK ZIP CRC, extracts the shipped Godot assets into an isolated temporary project, and boots those resources with desktop headless Godot. Both the existing and newly exported APK passed with 257 resources. A deliberate removal of the dynamically loaded minimap script was correctly rejected. This checks the actual packaged dependency graph rather than the editor source tree; it does **not** prove Android native libraries, graphics, input, audio or Fire TV performance. Added `test:fireos-assets`; Python/JavaScript syntax checks passed. Release manifest dates now use the packaging date instead of a hard-coded September 30 date.

ADB initially failed under restricted local socket permissions; normal-permission retry returned no connected devices. Fire TV execution and a complete human cooperative playtest remain unverified. Earlier relay-running claims describe September 30, not current availability; the local health probe returned no response this pass. Export and v2/v3 signature verification passed; existing restricted macOS certificate warning remains. Curated source ZIP refreshed (753 files); CRC, changed-file freshness and all four manifest hashes passed. Manifest uses October 5 packaging date. The separate publishing Git snapshot is still stale and unpublished.

**Single recommended next task:** perform a full normal-speed cooperative browser run, recording navigation, pressure-control clarity and idle periods, then complete physical Fire TV acceptance before submission. No finished/submission-ready claim is supported yet.

## October 5 — complete cooperative input/physics route

Added `test:coop-route`, reusing the actual motor/pathfinding helpers from the solo route with an active-player slot. Both farmers move through input packets and normal host physics ticks; the route does not position actors, assign crop stages, call context handlers directly or enable solo assistance. It covers five sheep with a real gate keeper, normal planning-clock saving, private mechanic diagnosis/pressure control and runner fitting, second-farmer intake/apple/crate jobs, tractor entry/full crop lifecycle/storage, both delivery readiness inputs, buyer inspection, a load packed by each farmer, rejection of single-player loading, joint dispatch, results and co-op replay.

The first route exposed a gameplay defect: ACTION during a result beat could fall through to boarding a nearby tractor, so the first delivery-readiness action became EXIT. Added a result-transition guard in `_try_context_action`; the complete route now asserts the farmer stays on foot after storage/result hold. Headless and native seed-1731 routes passed (349.8 simulated seconds, rendered results 5:49). These are accelerated deterministic technical runs, not a typical human duration or fun test. Actual repair/harvest/results frames inspected under `docs/audits/2026-10-05-coop-route/`; no art/map placement changed. Seeds 1732 and 1733 also passed headless complete routes (358.9 simulated seconds each), covering all three bounded variants.

Full solo route passed after the shared helper/game fix (266.0 seconds of motor simulation plus explicit planning waits). Mission and 2D-host regressions passed; the pre-existing small ObjectDB exit warning and restricted macOS log/certificate warnings remain. Web export/actual-PCK startup passed; Fire OS export/actual-APK resource startup and v2/v3 signatures passed. A restricted relay launch failed on socket permissions; normal-permission launch succeeded and the fresh browser visibly reached a zero-farmer QR lobby, left open for joining. This is browser startup evidence, not a full browser/network co-op run. Physical TV execution remains unverified. Source packaging now retains the new route test and actual co-op capture evidence; Refreshed 759-file ZIP passed CRC, changed-source and four co-op-image inclusion/freshness checks; all four manifest artifact hashes matched. Separate publishing Git snapshot remains stale/unpublished.

**Single recommended next task:** a normal-speed first-time two-person browser playtest, recording navigation, pressure comprehension, participation and replay interest; then physical Fire TV acceptance/qualifying footage. The technical routes strengthen playability evidence but cannot establish human fun or submission readiness.

## October 5 — supported TV inspection investigation

Minimap headless shared/split/merge/solo/privacy/visibility regression passed; existing split gameplay frame inspected. No runtime or art changes needed; restricted Godot log/certificate warnings remain.

Established official local Appium Inspector tooling (Appium 2.2.2, Kepler 3.30.0, checksum-verified Inspector 2026.9.2 ARM ZIP). Current Amazon VDA docs explicitly say the previous `gwsi-tool-screenshooter` route is unsupported on VVD. Existing simulator/server handles confirmed live. Component listing showed the game had stopped, so it was relaunched; listing then showed game VISIBLE and WebView renderer READY. Inspector returned a 1280×720 window and black screenshot. A GUI UP command received driver HTTP 200, but visible response was not established. Later screenshot/source refresh stayed pending; recorded pending Inspector UI under `docs/audits/2026-10-05-tv-inspection/`. This is not gameplay footage. GWSI buffer-state logs were found, but capture limitation versus actual rendering failure remains unresolved. No security bypass/filesystem-permission workaround applied; local tools excluded from source.

No physical Fire OS execution, complete rendered TV playthrough, normal-speed two-human fun test, qualifying video or publication completed. Goal remains active; prior blocked entries are historical. Source packaging now includes the TV diagnostic README/pending capture. Python syntax check passed. The 761-file ZIP passed CRC, current source/docs/evidence byte comparisons and tool exclusion checks; all four manifest hashes matched. Game binaries unchanged.

**Single recommended next task:** gather fresh TV wrapper/startup diagnostics alongside a supported Inspector view to distinguish loading/rendering failure from capture limitation; retain live handles while requests are pending. Human cooperative acceptance remains required afterwards.

## October 5 — TV startup diagnostics and readable failure handling

Added scoped WebView startup reporting for Godot's canvas dimensions, visible bounds, startup-overlay removal, secure context, WebAssembly support and context loss/restoration. Sampling stops after 45 samples and only changed state/first/final samples are sent. It never creates/reconfigures a WebGL context, and collects no room code, phone token or private mission fact. The native wrapper shows friendly loading/connection/startup failure messages; diagnostic detail appears only in development mode. Main-frame HTTP/SSL/load failures hide the app splash so the error can be seen. No game simulation, art, map placement or phone controller changed.

Fresh debug install/launch passed. Actual scoped runtime logs show canvas 300×150 / not ready at 11:51:22 UTC, then 1280×720 / ready / visible / secure / WebAssembly supported at 11:51:32 UTC, with no startup failure notice; final sample remained ready. This readiness means the Godot startup overlay was removed, not that the rendered farm pixels were verified. Native Inspector later showed the debug diagnostic strip reading `Canvas 1280,720; view 1280,720; ready=true; visible`, but the game surface remained flat-coloured. Saved `inspector-flat.png` and scoped `startup-diagnostics.log` under `docs/audits/2026-10-05-tv-inspection/`. The temporary log collection process ended (exit 0). Renderer service is already present in the manifest, as required by Amazon's blank-screen troubleshooting. Capture/compositing versus actual game rendering remains unresolved; a user observation question about the simulator window is pending.

Verification: lint and TypeScript passed; three tests in two suites passed, including execution of the actual shipped injection string against zero-sized/lost/restored canvas states without creating a graphics context. Initial test failures exposed missing Text/StyleSheet.flatten in the template mock; corrected those. SDK TypeScript lacked Node VM declarations, so the test now executes owned injection code with explicit fake browser globals. Restricted Watchman access initially failed; a normal-permission run passed, and final `--watchman=false` run passed without the external cache. Debug and release packages built for all three configured architectures; aarch64 release artifact refreshed. Existing manifest warnings about missing icon/build number and empty asset glob remain; build returned success. Native debug strip inspected; friendly error states have component-test evidence, not observed device error evidence.

No physical Fire OS or complete TV gameplay/input/audio/performance/replay acceptance, first-time human fun test, qualifying recording or publication was achieved. Browser/APK game binaries are unchanged. Source packaging refresh follows.

**Single recommended next task:** establish whether the farm is visible in the actual simulator window (pending user observation) or connect a physical Fire TV, then run the complete two-phone acceptance route. The ready canvas and native diagnostic strip must not be presented as a full TV graphics pass.

Late context recovery is now sampled immediately even after the 45-second polling window ends, so a restored context clears the native failure text. The actual injected-code regression covers this; final three tests, lint and TypeScript passed. Earlier ready-strip inspection remains valid startup evidence; late recovery was regression-tested rather than induced on the simulator.

Final late-recovery builds: Debug and Release completed successfully for aarch64, armv7 and x86_64. The retained aarch64 release candidate includes the recovery fix. Source handoff is refreshed with current diagnostics, tests and scoped inspection evidence; this remains a candidate, not a completed TV acceptance pass.

Final handoff verification: 765-file source ZIP passed CRC, current edited source/docs/evidence byte comparisons and tool exclusion checks; all four release-manifest hashes matched.

## October 5 — refreshed submission source checkout

Refreshed the isolated publishing checkout from the current 765-file curated candidate, retaining its local Git history. The previous 712-file snapshot had no obsolete tracked files and no local edits. Current source/docs/evidence are compared against the ZIP, whose CRC and four manifest hashes are checked. No remote or upload is added. This closes source handoff freshness only; human/browser whole-run and TV visual/runtime acceptance, recording and publication remain open.

**Single recommended next task:** establish a usable actual TV view/device and run the complete two-phone acceptance route; the simulator-view observation question remains unanswered.
