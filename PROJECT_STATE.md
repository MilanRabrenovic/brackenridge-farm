# Current project state

Updated October 15, 2026. Active game: **Brackenridge Farm**, an original illustrated 2D asymmetric cooperative farming weekend. The user explicitly requested finishing and testing everything possible on the laptop, with **human playtesting and Fire TV verification deferred until the end**. Those acceptance steps must not block local implementation or be described as passed.

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
2. Fire TV graphics, remote/phone controls, audio, sustained performance, reconnect and replay. APK/Vega builds are candidates. Simulator startup/ready canvas never proved rendered gameplay; previous inspection failed. Do not resume repeated unsupported capture attempts instead of laptop work.
3. Public GitHub source and candidate downloads published October 19; qualifying demo video and Devpost submission remain pending.

Four players, drivable combine/trailer, attachments/spraying, extensive interiors, authored carry/repair/boarding and full directional sheep sheets, Bedrock and internet matchmaking remain deferred expansion. Do not add them to the committed four-incident slice or claim they exist.

## Single recommended next task

Hand the laptop build to the user for the complete solo/two-phone playtest using `docs/LAPTOP_PLAYTEST.md`; fix observed defects, then perform Fire TV acceptance. Full goal remains unproven until those final tests and submission deliverables are complete.

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
