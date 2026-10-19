# Hackathon submission preparation

Updated October 19, 2026. Source and candidate downloads are public. This is a draft package, not a submitted entry.

## Verified official requirements

Sources: [event overview](https://amazonappdev2026.devpost.com/) and [official rules](https://amazonappdev2026.devpost.com/rules), checked September 30.

- Fire TV track; any framework permitted when demonstrated on Fire OS/Vega OS.
- Demo must show actual Fire TV or qualifying Fire TV/Vega simulator. Mac native/browser footage alone is insufficient.
- Public English YouTube/Vimeo demo shorter than three minutes.
- GitHub source/assets/instructions with public licensing or private reviewer access.
- Provide product feedback about tools/APIs used. Complete the entry fields and eligibility requirements yourself.
- At the September 30 rules check, the deadline was October 23, 2026, 12 pm Pacific; recheck the official rules before submission.

## Ready locally

- Browser candidate and signed Fire OS debug APK, original 2D source/runtime art and MIT code. Source archive: `../artifacts/brackenridge-farm-source.zip`; hashes: `../artifacts/release-manifest.json`.
- A complete arrival → sheep → planning → repair → weather/harvest → delivery briefing → dispatch → results/replay sequence.
- Labelled assisted solo weekend, two private phone roles, distinct tractor dashboard, pause/drop/share, reconnect handling.
- Scripted regression, route clearance, real relay input and native/browser visual evidence.
- README, run/export instructions and this submission draft.

## Remaining before submission

1. Sideload and play on qualifying Fire TV: QR/admission, remote selection, two-phone full successful run and failed run, reconnect, crop performance, split camera, audio, results/replay. Record frame rate/loading on that device. No physical Fire TV was connected. A Vega simulator connected and a WebView package installed/launched. Loopback/reverse forwarding enabled Godot PCK/WASM downloads and room creation, but gameplay was not visually confirmed; packaging and simulation startup do not establish a full gameplay pass.
2. Tune deadlines from a real two-human playtest. Confirm art at television distance. Current scripted tests do not establish fun, 12–15 minute typical duration or final visual approval.
3. **Source publication complete:** [public repository](https://github.com/MilanRabrenovic/brackenridge-farm) and [candidate downloads](https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.0-candidate). Submit the actual repository URL in the entry. Public source retains LICENSE and THIRD_PARTY_NOTICES; see SOURCE_HANDOFF.md.
4. Record the qualifying demo, upload to YouTube/Vimeo, add links and feedback to Devpost, review and submit. No demo upload or Devpost submission has been performed.

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
