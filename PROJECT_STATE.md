# Current project state

Updated October 20, 2026. Active game: **Brackenridge Farm**, an original illustrated 2D asymmetric cooperative farming weekend. The user explicitly requested finishing and testing everything possible on the laptop, with **human playtesting and Fire TV verification deferred until the end**. Those acceptance steps must not block local implementation or be described as passed.

## October 20 — genuine Vega demo recorded

The user authorized a genuine Vega gameplay recording, English captions and quiet ambience without narration. OBS 32.2.2 from the official Homebrew cask now has user-approved macOS Screen Recording permission. Capture source is only `[vega-virtual-device] Vega Virtual Device`; cursor is hidden, microphone and source audio are muted, no camera source exists. The isolated normal-speed automated two-player route completed inside the official guest: 355.783333 simulated seconds / 364.0233 wall seconds, zero reported errors, all four outcomes and replay checks passed. This is not a two-human playtest. Final 111.0-second video exists; YouTube is uploaded as a draft, audience declaration awaits the user, and Devpost correction remains pending.

`scripts/vega-recording.py prepare` creates disposable recording routes from the maintained GLES2 port; `serve` collects local timing/result markers on 8790. `scripts/vega-recorder.js` does not capture pixels. `scripts/render-vega-demo.py` edits completed OBS footage and refuses missing/failed guest results. Native validation of the isolated route passed all four outcomes/replay at 355.8 simulated seconds. Python compilation/JavaScript syntax checks passed. The ordinary `/host/vega-gles2/index.html` configuration was restored, all three Release builds passed, its aarch64 package was refreshed locally, reinstalled and restarted; the genuine guest QR lobby was visually verified. Recording route is isolated and is not the submitted package.

Earlier in-page capture attempts were rejected: WebGL `captureStream` caused context loss; software canvas readback produced only a few usable seconds, very slow frames and a hang. A later host-mode emulator process exited 245 (signal 11) during a prolonged tool stall after these experiments. The cause is not established. The earlier 22-minute mixed session remains valid evidence, but long-running simulator stability is not established. The simulator was restarted with the official `host` backend for OBS capture.

Final video: `artifacts/demo-vega/brackenridge-farm-vega-demo.mp4`, 111 seconds, H.264 1280×720/30 fps plus AAC; fully decoded with ffmpeg, six composition frames inspected. Silent alternative and English SRT included. SHA-256 `7bb607e667c2ae582c52834da497eaa25d5ead822a27b4d0a81eae1aae3dd21a`. Audio mean −29.6 dBFS / peak −6.9 dBFS; no clipping reported.

Demo-only audio source is TinyWorlds’ **Forest Ambience**, CC0, with provenance in `source_assets/audio/demo/ATTRIBUTION.md`. It replaces the user-rejected synthesized instrumental; audio has not been subjectively reviewed by the agent. No new game assets or gameplay changes were made.

## Active priority — October 20

The user requires hardware-free execution entirely inside Vega and rejected Mac streaming. A repeatable Godot 3.6.3 GLES2/WebGL1 compatibility port now renders and runs the existing farm **inside the official Vega simulator**, SDK 0.24.12112, confirmed serial `amazon-835a951bf5d61cec`. The Mac serves static files and relays packets; simulation/rendering run in the guest WebView. Ordinary `/host/` remains Godot 4; Vega loads `/host/vega-gles2/index.html`.

**Verified visually in Vega:** farm/QR lobby, TV Select admission, two independent phone controllers with different private facts, directional farmer movement, sheep event/public guidance/minimap, tractor boarding/dashboard and upright driving. Evidence and exact limits: `docs/audits/2026-10-20-vega-port/README.md`.

**Responsiveness follow-up:** a static-terrain/building-cleanup bake plus the official emulator's `host` OpenGL backend now provides substantially faster local guest play. Observed phone acknowledgements were mostly 35–78 ms median, with a short crop-drive sample at 71 / 278 ms p95. Startup-only Debug frame samples showed 44–53.1 fps (37–40 ms p95 intervals); these are not sustained/split FPS benchmarks. Actual two-controller movement, split/merge cameras, sheep event, building cutaway and upright tractor/dashboard/drive were inspected. See `docs/audits/2026-10-20-vega-performance/README.md` for individual samples and retained evidence. Software remains the slower fallback; earlier Metal ANGLE host crash is still a failed result. The subsequent automated guest weekend passed as recorded above; a full human weekend, revised public video, refreshed GitHub release and Devpost correction are still unclaimed.

## October 20 — local Vega renderer port

Maintained adapter: `platform/vega-gles2/`; generated sources: `build/vega-gles2-source/`; runtime: `build/web/vega-gles2/`. Official Godot editor/templates passed SHA-512 checks. Adapter preserves existing art/simulation/private facts/collision/cameras, translates shader/physics/socket/layout APIs and fixes Godot 3 font lifetimes, colour ordering and camera zoom. Scene-owned scalable Noto Sans font cache is SIL-OFL licensed; runtime includes font/engine notices. Hidden second viewport rendering is disabled until split; the covered root world is excluded from rendering.

Strict Mac GLES2 checks passed: mission/weekend, 2D map/movement/animation, complete solo input/physics route (266.0 simulated seconds), complete co-op input/physics route (349.8 simulated seconds), results/replay and WebGL1 export. Runner rejects script/renderer errors even with exit zero. These are accelerated automated Mac checks, not full Vega playthroughs or human fun tests. Wrapper lint, TypeScript, four tests/two suites and all three Release targets passed. Final Release rebundles the WebGL1 URL/readiness observer; Debug is not refreshed after the final observer change.

Original Godot 4 remains the primary source. One source bug was corrected: admitting a second player during arrival now removes the stale solo banner. Its 2D regression and Web/PCK export passed; two existing ObjectDB exit warnings remain in that Godot 4 regression. Original APK/public candidate archives were not refreshed for this banner change.

An orphaned older SDK simulator was found conflicting on port 5555; both images were stopped before these confirmed newer-image tests. Intermediate overlapping SDK observations are inconclusive. SDK 0.24.9914 exists side by side but is not an established fix. The new `scripts/start-vega-simulator.py` refuses an occupied device port and terminates its own emulator child on Ctrl+C. Default software fallback is slower; no SDK/image/security settings were modified by this launcher.

Current local `artifacts/vega-gles2/` contains the 156,118-byte aarch64 Release package, 34,299,533-byte optimized Web ZIP, included licence notices, extraction/setup note and SHA-256 manifest. CRC/hash and Python compilation checks passed. These supersede the earlier local port files and are not published.

**Single recommended next task:** finish the user-confirmed YouTube audience/publication step, then refresh the public candidate and Devpost video/platform explanation. Keep normal-speed human co-op acceptance separate; a screenshot/build alone does not close the organizer warning.

## Implemented laptop experience

- One connected 170 × 120 metre farm, layered terrain/art, measured building/vehicle/river/boundary collisions, cutaway interiors and foreground occlusion. Reference-led buildings, foliage, roads and shadows are integrated.
- Two phone-controlled farmers; full assisted solo testing with the same normal mission deadlines. Host owns simulation/private facts/input authority. Adaptive close/shared/split cameras and a public schematic minimap.
- Complete weekend: arrival/hay check → staggered sheep escape/herding/gate → one joint £20 upgrade choice → private seeded repair diagnosis + part running + pump/release pressure → prepare/sow/grow/harvest barley + seal/store/cover apples/prepare crates → private buyer briefing → collect/pack/joint van loading → outcomes, task contributions, balance and replay.
- Failed jobs continue into recoverable delivery; no elimination. Pausing/disconnecting freezes mission/crop clocks. Buffered quick ACTION taps, reconnect tokens and safe tractor exit are implemented.
- Directional walking; four upright tractor views, independent side wheels and suspension; sheep fence jumps and shader leg motion; crop stages, rain/overcast, animated water/foliage and an original objective bell.

## October 15 laptop finishing pass

- Added per-farmer destination/action cards and coloured offscreen compass arrows, placed around the shared/split minimap. Nearby cards explain tap/hold/tractor EXIT and field-tool actions. Repair diagnosis and buyer preferences remain private; arrows show direction, not collision-aware paths.
- Added phone results/replay UI. In co-op both players vote ready; a second tap cancels; disconnected players lose their vote; both must be connected. Solo needs one tap. The host button still starts the next seed.
- Phone header now shows its room code to make old-room confusion visible.
- Results freeze farmer movement/walk animation. Centred the expanded results card after a native bounds check exposed clipping. Moved shared-clue text above the action cards.
- Reviewed real native co-op repair, split harvest and results; shared/split guidance and results fixtures; browser admission and the isolated phone results UI. No new raster assets or map placement changes were made.
- Fixed the integration test's obsolete welcome wording assertion to match the actual gate/inspection roles; it does not change the game.

## Verification this pass

| Check | Evidence / scope |
|---|---|
| Full solo input/physics route | Passed all four jobs, crop lifecycle, storage, delivery/results/replay; 266.0 simulated seconds plus explicit planning waits |
| Full co-op input/physics route | Headless and native seed 1731 passed all four outcomes/results/replay, no actor/crop teleports or solo helpers; 349.8 simulated seconds. Not human duration |
| Mission/weekend | Focused mission checks and three scripted success/failure/seeded routes passed |
| Map | 468 real physics clearance samples, zero blocked |
| Movement/animations | 2D-host, repair, sheep and minimap regressions passed; native route inspected |
| New finish check | Guidance privacy/routing/bounds, result movement freeze, joint/solo replay, cancellation and missing-player guards passed. Final headless disconnect-vote/walk-idle checks passed |
| Relay/network | Nine Node tests passed, including replay command identity; real relay→Godot integration passed at 32.9 ms frame acknowledgement |
| Browser | Fresh export reached QR lobby; a real browser test controller joined/admitted, received private welcome/room badge, and pause worked. Not a whole browser/network weekend |
| Phone results | Explicitly labelled isolated relay fixture inspected; button restored walking controls. Not a Godot mission completion |
| Web | Export and actual exported-PCK startup passed; guidance retained in export filters |
| Fire OS | Debug APK export/resource startup passed with 259 resources; v2/v3 signatures passed. Physical runtime deferred |
| TypeScript | Final check passed |

Restricted Godot runs retain macOS log/certificate warnings; 2D-host test reports two ObjectDB instances at exit. No gameplay assertion failed in those checks. Initial restricted Node socket tests failed EPERM and passed with normal local socket permissions. Results bounds initially failed and were corrected/recaptured. No Fire TV, human fun, typical duration or final aesthetic approval is inferred from automated/staged evidence.

## Current files / run

`npm run dev` serves `http://127.0.0.1:8787/host/`; keep it running. Phones on the same Wi-Fi scan the current QR. Enter/Select admits pending phones. One phone starts solo testing; admit both during arrival for co-op. See `USEFUL_COMMANDS.md` and `docs/LAPTOP_PLAYTEST.md`.

Current pass evidence: `docs/audits/2026-10-15-finish/`. `coop-*` are actual accelerated motor-route frames; other native frames and the phone fixture are labelled staged review. Older October 5 images were restored from the isolated Git snapshot after this pass's initial capture reused their paths; new captures now use the October 15 folder.

## Remaining acceptance / submission

1. User and two-person normal-speed laptop playtests: clarity, participation, pacing, visual approval and replay interest. Explicitly deferred until local completion.
2. Fire TV graphics, remote/phone controls, audio, sustained performance, reconnect and replay. APK/Vega builds are candidates. October 20 WebGL1 port has visible simulator gameplay/input evidence; sustained performance and full Vega playthrough remain open.
3. Public GitHub source and candidate downloads published October 19; qualifying demo video and Devpost submission remain pending.

Four players, drivable combine/trailer, attachments/spraying, extensive interiors, authored carry/repair/boarding and full directional sheep sheets, Bedrock and internet matchmaking remain deferred expansion. Do not add them to the committed four-incident slice or claim they exist.

## Single recommended next task

Capture the genuine local Vega Release demo and refresh the public candidate/submission, as detailed at the top of this file. Human playtesting remains an additional acceptance item.

History before this pass is preserved in `docs/history/2026-10-15/PROJECT_STATE-before-laptop-finish.md`.

## Final build / handoff verification

Final Web export plus actual-PCK startup and Fire OS debug APK export/resource startup passed after the last source fixes (259 APK resources). TypeScript passed. Phone results fixture was reviewed after the compact layout/solo wording correction; its temporary process/tabs were stopped/closed. The normal game relay remains running. Final package/signature/browser freshness results follow. Vega wrapper code/binary is unchanged; it loads the current host and still needs final TV acceptance.

Final signatures passed v2/v3. Fresh final browser export visibly reached its QR lobby with zero farmers and no browser warnings/errors; left open at localhost:8787/host for the user. Room codes change on reload; scan the current screen rather than an old capture. Preliminary 780-file source ZIP passed CRC, changed-source/evidence/exclusion checks and four artifact hashes; the final browser capture and latest notes are included in the refreshed handoff below. Final isolated snapshot comparison follows packaging.

October 15 admission clarity: a connected pending phone now explicitly says to press Enter/Select on the host; the host roster shows waiting phones and the same admission action. Admission authority is unchanged. The hint hides after admission. The finishing regression checks the host prompt. Final exports/package are refreshed after this change.

Admission follow-up was inspected through the real rebuilt browser/relay: the pending phone showed the explicit host instruction, host showed a waiting-phone count/Enter prompt, and Enter admitted the farmer and hid the phone hint. Captures `host-pending.png` and `phone-pending.png` retain that evidence. The temporary controller was closed and the final host reset to a clean QR lobby for the user. Finishing regression and TypeScript passed after this last code change; final Web/PCK and APK/resource exports also passed.

Final October 15 source handoff: 783-file ZIP passed CRC, excluded-tool/credential-file checks, byte-for-byte comparison of the isolated publishing snapshot and all four artifact SHA-256 checks. Latest signatures verified v2/v3. The source snapshot remains local; no remote/publication was added. This evidence supports the laptop candidate and final-playtest handoff, not completed Fire TV/human acceptance.

## October 19 — GitHub publication

The user requested committing/publishing the game and explicitly selected public visibility. Verified GitHub account MilanRabrenovic and created https://github.com/MilanRabrenovic/brackenridge-farm. Existing 783-file source candidate matched workspace/prepared checkout; credential-pattern scan passed for 143 text files and excluded keys/environment/tools were absent. Updated the public README with an actual gameplay frame, source/build instructions and separate candidate-download guidance. Push/release verification follows. No gameplay or art changed; human/Fire TV acceptance remains pending.

Publication verified: https://github.com/MilanRabrenovic/brackenridge-farm is PUBLIC with default branch main. Initial pushed commit matched local b76d4959fa9b1398dfcbe57e4f85958a6e32c6f1. Public prerelease https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.0-candidate contains Web ZIP (32,967,286 bytes), signed Fire OS debug APK (80,256,286 bytes), Vega aarch64 wrapper (155,572 bytes) and checksum text (287 bytes); GitHub uploaded-state/size/SHA-256 digests matched all four local files. Web archive CRC passed and extracts to build/web; source excludes signing/environment/toolchain files. GitHub automatic source archives retain the curated release commit. Publishing source/downloads does not host the relay or complete Devpost. Docs/curated local handoff are refreshed and pushed following this verification. No runtime code changed, so existing October 15 game-test evidence remains the recorded behavior evidence; no new human/Fire TV claim.

GitHub post-push dependency report: 16 open alerts were inspected through the API; all reference platform/vega/package-lock.json (2 critical, 7 high, 7 medium). Critical findings concern handlebars; other alerts include SDK-transitive packages. This does not prove every other dependency safe. No forced SDK upgrade or dependency change was made in the publication pass; compatibility review/remediation remains open before treating the Vega toolchain as release-ready. Public source/download publication itself completed and was verified. Final publishing checkout is clean after the publication-note commit; its current remote SHA is verified through GitHub.

## October 19 — Vega dependency fixes

Updated React Native CLI to 20.2.0 and added version-scoped patched overrides for Handlebars, Lodash, UUID, TOML, Ajv and minimatch. This addresses 14 of the 16 reported GitHub findings, including both critical alerts. Fresh Node 24.19.0 installation, lint, TypeScript, all three tests and Debug/Release builds for aarch64/armv7/x86_64 passed. Rebuilt aarch64 wrapper is 155,574 bytes; no gameplay/Web/APK source or art changed. Release source map was inspected for the affected tool packages. SDK nonfatal lock comparison/empty-assets warnings remain. An initial command from the wrong directory failed without changing source; the correct wrapper build passed.

npm audit still exits 1: braces (high) and sprintf-js (moderate) have no published patched versions. They propagate to 68 affected dependency entries, zero critical; they are two underlying advisories, not 68 separate flaws. Neither is dismissed. Details, exposure and supported Node installation requirement are in `docs/audits/2026-10-19-dependencies/README.md`. GitHub rescan confirmed only alert 15 (braces/high) and 16 (sprintf-js/medium) remain open: 14 of 16 closed, zero critical. Single next task remains the normal-speed laptop playtest, then Fire TV acceptance; check upstream tool fixes before a production toolchain release.

Publication verified: main received fix commit `554232d3d5a5f8dcf016eb4cef89876d4cf9ced4`; [v0.9.1-candidate](https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.1-candidate) targets that exact commit. All four uploaded files are complete and their GitHub size/SHA-256 metadata matches local Web ZIP, APK, rebuilt Vega package and checksum text. Curated source contains 784 files; CRC, exclusion, byte-for-byte snapshot and all four local manifest hash checks passed. The final documentation-only follow-up records this evidence; it does not change the tagged build. No alerts were dismissed. Human/Fire TV tests and submission deliverables remain open.

## October 19 — English demo production

Recorded the actual native two-player input/physics route at 30 fps; all four jobs/results/replay passed (355.8 simulation seconds including results hold). Rendered a 115.12-second 1080p English-narrated preview with chapter captions, embedded/sidecar English subtitles, factual private-clue card and persistent Mac/automated-input disclosure. Full decode, stream/duration/audio checks and sampled visual review passed. No runtime game/art changed. Source tools: `game/tests/record_demo.gd`, `scripts/render-demo.py`; output/provenance: `artifacts/demo/`; details: `docs/DEMO_VIDEO.md`.

YouTube publication is in progress, not yet verified. No qualifying TV footage: device list was empty; existing unsupported simulator capture routes were not repeated. The single recommended next task for hackathon eligibility remains verified Fire TV/simulator gameplay and replacing/augmenting this laptop preview with qualifying footage; human co-op acceptance and Devpost entry remain open.

Demo preference correction: the user rejected synthetic narration and selected music/silent viewing. Removed all voice from the current MP4, added a quiet original locally synthesized instrumental and exported a fully silent alternative. Video images remain byte-identical at the H.264 stream level; English explanatory captions replace speech transcription. Music peak -9 dBFS/mean -21.7; full decode passed and silent alternative has no audio track. Old narrated YouTube upload was saved as an unpublished private draft. Revised upload/public verification is in progress; see DEMO_VIDEO.md.

## October 19 — Devpost cover thumbnail

Created an original illustrated promotional cover using the actual game environment and Grower/Mechanic as image-generation references. Source/prompt retained under `source_assets/2d/marketing/`; upload JPEG: `artifacts/submission/brackenridge-farm-devpost-thumbnail.jpg`, 1536×1024 (exact 3:2), 1,162,991 bytes. Inspected generated art and final JPEG: title/tagline readable, both character identities retained, no HUD/third-party branding. Decode/aspect/under-5-MB checks passed. Promotional candidate for user review; no runtime integration or aesthetic approval claimed. User reports publishing the revised video; public playback was not independently verified in this thumbnail pass. Single recommended next task: upload this cover and complete the Devpost draft; qualifying TV footage remains a separate unresolved submission requirement.

## October 19 — Devpost image gallery

Created four upload-ready 1536×1024 (3:2) JPEG cards from actual native two-player recording frames: sheep teamwork, private-clue repair, split-screen harvest and successful shared results. The results card explicitly identifies two-player support now/four-player family play planned. All cards disclose Mac automated input capture; no TV acceptance is implied. Reproduced clue panels are labelled. JPEG decode/aspect/size checks passed (0.54–0.78 MB each), and rendered contact-sheet visual review passed. Source frames/provenance: `source_assets/2d/marketing/gallery-v1/`; upload JPEGs: `artifacts/submission/gallery-v1/`; four-image ZIP: `artifacts/submission/brackenridge-farm-gallery.zip`. No runtime source/art was changed. Single recommended next task: upload the four gallery cards and complete the Devpost draft while resolving qualifying TV footage before submission.

## October 20 — Organizer eligibility warning and simulator investigation

User reports publishing the music-only video, submitting Devpost and receiving an organizer warning that the entry does not appear built for Fire TV. This supersedes the historical draft-only status. The official rules were rechecked: video must show actual Fire TV or a qualifying simulator; deadline October 23 at 12:00 PDT / 21:00 Belgrade.

Started the relay, official aarch64 Vega simulator and installed Release package. Normal-permission device listing confirms connection; the farm component is VISIBLE and the renderer READY. Restricted device listing falsely returned empty, so it must not establish liveness. Latest SDK remains 0.24.12112. Installed official Vega Studio 0.24.1 from the Marketplace and launched the simulator through its Devices UI in a separate project window. No inspectable simulator window was exposed to available desktop tools. Fresh emulator logs contain unsupported GLSL 310 / atomic_uint shader errors and texture-validation failures; root cause and relationship to Godot are unproven. User asked whether the window is directly visible. No qualifying capture, YouTube replacement or Devpost edit completed. No gameplay/art change; existing game tests are not new TV evidence.

Scoped evidence: `docs/audits/2026-10-20-tv-eligibility/`. Prepared `docs/TV_ELIGIBILITY.md` with verified run steps, a two-minute capture outline, conditional correction copy and honest friction text; corrected stale submission status. Do not paste conditional success claims before footage exists.

**Single next task:** establish visible working gameplay on the official simulator or a Fire TV, record it and replace/update the Devpost demo before the deadline. Await the user's direct window observation to distinguish tool visibility from actual rendering failure. The eligibility warning remains unresolved.

Documentation verification: all seven updated/added Markdown documents and four scoped evidence files exist and are nonempty; explicit unverified-status checks passed. Runtime code was unchanged, so no new gameplay test result is claimed. These October 20 documentation changes have not been pushed to the public source snapshot.

### October 20 — User confirms black simulator window

The user supplied a screenshot showing the actual “Vega Virtual Device” window entirely black. This resolves the missing-window uncertainty: a GUI window exists, but the game display is not working. Launched the installed Amazon home component (`com.amazon.keplerlauncherapp.main`); lifecycle output now reports home VISIBLE and the farm NOT_VISIBLE. Asked the user whether the home screen is also black. That visual observation is pending; component status alone cannot answer it. The next diagnostic step is to distinguish a simulator-wide renderer failure from a game/WebView failure before changing game code.

### October 20 — Local Vega runtime required / side-by-side SDK test

Bundled SwiftShader, ANGLE/Metal, SwANGLE, dynamic GLES negotiation and a process-local experiment preserving Vulkan selection all rendered HTML/native UI through the supported inspector but did not provide WebGL2. Isolated probe shows WebGL1 true, WebGL2 false, Chromium 144, Mesa/virgl, and `BindToCurrentSequence failed`. This isolates the failure from game loading. The process-local shim is experimental diagnostic source under `.tools`, not a production dependency or a successful graphics fix. Original VVD config.ini was restored from backup.

The user rejected borrowing hardware and rejected streaming from the Mac; explicitly authorized investigating another SDK or a larger local renderer port. Started side-by-side installation of official SDK `main@0.24.9914` while keeping 0.24.12112 active. Starting disk free space: 38 GiB. Installation result and older-image runtime test are pending. Normal source HOST_URL is restored to `/host/`; the current diagnostic-installed package may still point at the isolated graphics-probe page until rebuilt/reinstalled. Do not publish it as a playable build.

Handoff: SwANGLE simulator and normal relay left running; app restarted and a fresh zero-player QR lobby visually verified (`final-lobby-inspector.png` in the port audit). Temporary browser controllers closed. Use the live QR, never a saved room code.

## October 20 — responsiveness implementation pass

Optimized only the compatibility presentation: cached 2040×1440 static terrain, separately clipped animated river and six individually baked existing building cleanup effects. No map placement/art direction/gameplay scope change. Added bounded numeric startup timings with Debug-only native display, explicit startup-sample wording and a regression preserving readiness/error behavior. Launcher now supports/defaults to bundled host OpenGL mode.

Strict four Godot 3 suites, full solo/co-op routes and Web export passed. Wrapper lint/TS/five tests/two suites plus Debug/Release all three architectures passed. Python compilation passed. Actual guest UI/input and earlier failure/correction details are in `docs/audits/2026-10-20-vega-performance/`. Initial timing-node alias parse/import failures were corrected before the passing rerun. Original Godot 4 source was not changed.

Final local candidate refresh: aarch64 Release 156,118 bytes, Web ZIP 34,299,533 bytes, CRC and SHA-256 checks passed with current licence notices. Host backend mixed session exceeded 15 minutes without observed crash. Final Release two-controller split view and disconnect/reconnect pause/resume inspected; captures `release-disconnect-paused.png` and `release-reconnected.png`. No successful full human/guest weekend or hardware-wide stability guarantee is inferred. Public artifacts/video/submission remain unchanged.

Handoff verified: final Release is running at a fresh zero-player QR lobby with no Debug strip (`final-release-lobby.png` in the performance audit); temporary controllers closed. Keep simulator launcher and relay running, scan the live QR and press TV Select/Enter to admit. Recommended next task remains genuine platform demo/public submission correction.

Final host-backend liveness observation: 22:02 elapsed, no observed crash during the mixed technical checks. No continuous full-weekend success is implied.
