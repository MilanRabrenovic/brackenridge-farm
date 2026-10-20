# Hackathon submission preparation

Updated October 20, 2026. The existing entry remains **submitted**. The correct Vega demo is public at https://youtu.be/EOK7y4zPDx4, and Devpost’s actual embedded video, story, setup instructions and candidate link were corrected. Public embed/story verification passed. The current Vega candidate is https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.2-vega-candidate. Organizer eligibility approval is not known; human acceptance/physical Fire TV testing/longer stability remain open.

## October 20 replacement demo

A real official Vega guest automated co-op weekend completed all four outcomes/replay, zero reported errors. The checked 111-second replacement video uses actual OBS simulator-window footage, English captions and quiet CC0 ambience. The new video is public and Devpost embeds the verified ID `EOK7y4zPDx4`. See `DEMO_VIDEO.md`. Physical TV and human acceptance remain open.

## Latest October 20 responsiveness result

The static-presentation optimized WebGL1 build now runs on the official emulator's host OpenGL backend with observed controller medians mostly 35–78 ms; startup frame samples showed 44–53.1 fps. These are scoped samples, not a full-game performance guarantee. Two private controllers, split/merge, cutaways and tractor driving were inspected in the guest. Use `--gpu host` (new launcher default); the earlier software-slowness/Metal-crash notes remain historical results for those different backends. Full strict Mac GLES2 routes and five wrapper tests/all Debug/Release targets passed. Evidence and exact limits: `docs/audits/2026-10-20-vega-performance/README.md` from project root. Genuine qualifying public footage, public candidate refresh and Devpost correction remain next.



## Current status — local WebGL1 port, October 20

The original Godot 4 WebGL2 failure is bypassed by a maintained Godot 3.6.3 GLES2/WebGL1 compatibility port. Actual farm, QR, TV admission, two independent private controllers, walking, sheep event and tractor/dashboard/drive were inspected inside the confirmed official SDK 0.24.12112 guest. Simulation/rendering execute entirely in Vega; Mac hosts static assets and relays packets. This is not Mac streaming.

Sustained responsive play remains unresolved: software backends showed roughly 300–400 ms median controller frame acknowledgements; Metal ANGLE gave roughly 50–66 ms then the host emulator crashed signal 11. These are samples, not FPS. Full automated solo/co-op routes passed on Mac GLES2, not an entire actual Vega weekend. No physical Fire TV/human acceptance is claimed. Local packages under `artifacts/vega-gles2/` passed archive/hash checks but have not been published. See [port evidence](audits/2026-10-20-vega-port/README.md) and `platform/vega-gles2/README.md` for commands, backend limitations and licences.

No replacement qualifying video or Devpost correction was made. Existing public Mac preview remains a Mac preview; the organizer warning remains open until accurate platform footage/submission corrections are supplied. VS Code/Vega Studio are optional tools; the verified command-line route does not require them.


## Verified official requirements

Sources: [event overview](https://amazonappdev2026.devpost.com/) and [official rules](https://amazonappdev2026.devpost.com/rules), rechecked October 19.

- Fire TV track; any framework permitted when demonstrated on Fire OS/Vega OS.
- Demo must show actual Fire TV or qualifying Fire TV/Vega simulator. Mac native/browser footage alone is insufficient.
- Public English YouTube/Vimeo demo shorter than three minutes.
- GitHub source/assets/instructions with public licensing or private reviewer access.
- Provide product feedback about tools/APIs used. Complete the entry fields and eligibility requirements yourself.
- October 19 rules recheck: deadline October 23, 2026, 12 pm PDT (21:00 Europe/Belgrade).

## Ready locally

- Browser candidate and signed Fire OS debug APK, original 2D source/runtime art and MIT code. Source archive: `../artifacts/brackenridge-farm-source.zip`; hashes: `../artifacts/release-manifest.json`.
- A complete arrival → sheep → planning → repair → weather/harvest → delivery briefing → dispatch → results/replay sequence.
- Labelled assisted solo weekend, two private phone roles, distinct tractor dashboard, pause/drop/share, reconnect handling.
- Scripted regression, route clearance, real relay input and native/browser visual evidence.
- README, run/export instructions and this submission draft.

## Remaining before submission

1. Sideload and play on qualifying Fire TV: QR/admission, remote selection, two-phone full successful run and failed run, reconnect, crop performance, split camera, audio, results/replay. Record frame rate/loading on that device. No physical Fire TV was connected. A Vega simulator connected and a WebView package installed/launched. Loopback/reverse forwarding enabled Godot PCK/WASM downloads and room creation, and the later October 20 WebGL1 port visually demonstrated gameplay/input; sustained responsive operation and a full guest weekend remain open.
2. Tune deadlines from a real two-human playtest. Confirm art at television distance. Current scripted tests do not establish fun, 12–15 minute typical duration or final visual approval.
3. **Source publication complete:** [public repository](https://github.com/MilanRabrenovic/brackenridge-farm) and [candidate downloads](https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.1-candidate). Submit the actual repository URL in the entry. Public source retains LICENSE and THIRD_PARTY_NOTICES; see SOURCE_HANDOFF.md.
4. Record the qualifying demo, upload to YouTube/Vimeo, add links and feedback to Devpost, review and submit. The user reports publishing the music-only Mac preview and submitting Devpost. No qualifying Fire TV/simulator replacement has been recorded; public submission/video visibility was not independently verified in the October 20 pass.

## Suggested title and short description

**Brackenridge Farm — One farm. Two phones. Half the story each.**

A family-friendly couch-cooperative farming weekend where private phone clues turn familiar farm jobs into communication challenges. One farmer guides the flock while another holds the gate; a mechanic diagnoses a seeded slipping drive or leaking pump while their partner finds the belt or gasket; stock conditions and buyer requirements must be combined before dispatch. A close shared camera becomes split screen when players separate.

## Build description draft

Godot 4.7.2 hosts the 2D world and authoritative simulation; a TypeScript/Node WebSocket relay connects lightweight phone controllers. A deterministic seed chooses bounded timing/order variants. Terrain, foreground buildings/foliage, collisions, crop-state layers and animated actors remain separate. Source art is original generated/edited material retained alongside optimized runtime assets. The project does not use licensed television-show names or copied game assets.

The first release optimizes for two players and includes a full assisted solo weekend for local testing. Failure advances the weekend with reserve stock rather than trapping players. Phones can deliberately share private facts; the TV does not automatically expose every clue.

Do not claim four-player support, Bedrock recaps, adaptive AI scheduling, drivable combine/trailer, commercial release certification or measured Fire TV performance.

## Demo outline — target 2:40

| Time | Footage |
|---|---|
| 0:00–0:15 | Actual Fire TV and two phones; show QR/admission and explain private facts |
| 0:15–0:45 | Guide-and-gate teamwork; different phone clues and split/merge camera |
| 0:45–1:15 | Diagnosis versus supply; wrong part feedback, correct delivery, joint repair |
| 1:15–1:45 | Tractor dashboard and upright directional motion; crop states/rain/storage |
| 1:45–2:15 | Buyer/stock fact combination, carry/pack, two-player loading |
| 2:15–2:40 | Results, seed/replay and short technical summary |

Edit actual play footage with cuts and disclose accelerated time if used. Native staged review captures are not qualifying footage. Keep both phones' facts visible in at least one shot so the core hook is clear.

## Product feedback draft

Godot's shared source/Web/Android exports accelerated local iteration. Scene-filter exports required explicit inclusion of scripts instantiated dynamically, so the exporter now boots the actual packaged PCK to catch omissions. Separate phone controls work well for private information, but quick taps required host-side buffering between network polling and simulation ticks. The official Vega WebView template and SDK 0.24.12112 were used to build/install a wrapper. Simulator startup was confirmed by Godot resource downloads and room creation; rendered gameplay and TV remote controls remain unverified. Do not claim measured device performance or Bedrock usage.

## October 5 platform evidence update

Instrumented Vega Debug launch reached visible 1280×720 Godot canvas/startup readiness approximately ten seconds after document load. Appium showed the native status strip but a flat game surface. Debug/Release builds, lint, TypeScript and three wrapper/injection tests passed; aarch64 release artifact refreshed. These do not establish actual TV gameplay/remote/performance/audio or qualify as demo footage. The browser and signed Fire OS APK game content remain the last tested October 5 build. Full Fire OS execution, human cooperative acceptance and publication are still required.

## October 15 candidate update

Laptop UI now includes per-farmer action/destination cards and public compass cues, phone room badge, and phone next-weekend ready voting (both connected co-op farmers; one in solo). Expanded results are centred and freeze actor movement/animation. Existing four incident families and the asymmetric diagnosis/buyer clues remain the implemented scope. Local checks and evidence are in PROJECT_STATE and `audits/2026-10-15-finish/`; final human/Fire TV acceptance is deferred, not passed. Use `LAPTOP_PLAYTEST.md` for the last playtest. No new publication or eligibility claim is made by this update.

## October 19 source destination

Public repository created and user-authorized: https://github.com/MilanRabrenovic/brackenridge-farm . Candidate downloads: https://github.com/MilanRabrenovic/brackenridge-farm/releases . Source push and all four release asset digests were verified; see PROJECT_STATE. These links do not imply a hosted backend, tested Fire TV run or submitted Devpost entry.

## October 19 English preview

A 115.12-second Mac gameplay preview with English on-screen explanations, captions and original instrumental music has been rendered and reviewed; The user reports YouTube publication. The user rejected synthetic narration; the current edit has no voice and a silent alternative is also available. See `DEMO_VIDEO.md`. It shows actual automated two-player gameplay, not Fire TV/simulator execution. Its persistent platform disclosure must remain. It cannot replace the required qualifying platform demonstration. Record that footage before using a final video in the entry.

## Devpost project overview cover

Upload `artifacts/submission/brackenridge-farm-devpost-thumbnail.jpg`: 1536×1024 (3:2), 1.16 MB, inspected and decoded. This is original promotional cover illustration referencing the actual character/environment designs, not gameplay/device evidence. Source and prompt are retained in `source_assets/2d/marketing/`.

## Devpost image gallery

Upload the four numbered JPEGs from `artifacts/submission/gallery-v1/` in order (or extract `artifacts/submission/brackenridge-farm-gallery.zip`). Each is 1536×1024 / 3:2, below 5 MB. They show actual native gameplay; the repair card adds labelled reproductions of private clues. The results card explains current two-player scope and planned four-player family play. Do not upload `review-contact-sheet.jpg`; it is QA only. These remain Mac gameplay evidence, not qualifying TV proof.