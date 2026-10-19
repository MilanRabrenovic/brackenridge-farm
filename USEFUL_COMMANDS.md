# Useful commands

Verified 2026-09-30. Run from the repository root. Requires Node 20+, Godot 4.7.2 and matching export templates. On this Mac use the bundled ARM Node when default Node cannot load esbuild:

```sh
export PATH=/Users/milanrabrenovic/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:$PATH
npm install
npm run export:web
npm run dev
```

Open `http://127.0.0.1:8787/host/`. Scan the QR on phones on the same Wi-Fi. Enter/Select on host admits phones. First admitted phone starts a full assisted solo test weekend; join/admit both during arrival for cooperative play. Restart with R after both have joined if solo play already moved past arrival.

## Native / Fire OS

```sh
godot --path game
FARM_RELAY_URL=ws://YOUR_MAC_LAN_IP:8787/ws godot --path game
npm run export:fireos
.tools/android-sdk/platform-tools/adb devices
.tools/android-sdk/platform-tools/adb install -r artifacts/countryside-coop-debug.apk
.tools/android-sdk/platform-tools/adb shell am start -n com.countrysidecoop.probe/com.godot.game.GodotAppLauncher
```

Local Android exporter expects `.tools/jdk17/Contents/Home` and `.tools/android-sdk`, plus Godot Android templates. These tools/credentials are not in the source archive. Keep `npm run dev` running on the Mac during Fire TV play. The APK is a signed debug sideload candidate, not Appstore certification or a Vega binary. No connected Fire TV was available on Sept30.

## Checks

```sh
npm run typecheck
npm test
npm run test:godot
npm run test:2d
npm run test:map
npm run test:repair
npm run test:weekend
npm run test:solo
godot --headless --path game --script res://tests/test_tractor_review.gd
npm run export:web
npm run export:fireos
```

`test:weekend` exercises three complete scripted routes, rejected stock, joint loading, failure recovery, assisted repair, pause/drop/replay, quick taps and 1000 repeatable seed selections. Those seed checks are not 1000 human playthroughs. `test:map` samples real physics routes/destination connectivity. `export:web` also boots the exported PCK and rejects missing resources. Always inspect a fresh browser load afterwards. On restricted shells socket tests and Godot user save/log paths may need normal local permissions.

## Visual review / rebuilds

```sh
npm run review:map
godot --path game --script res://tests/capture_map.gd -- release
godot --path game --script res://tests/capture_weekend.gd
godot --path game --script res://tests/test_tractor_review.gd
npm run assets:cohesive
npm run assets:reference
npm run assets:buildings
node scripts/build-tractor-directions.mjs
npm run assets:2d
npm run map:plan
```

Native review requires desktop graphics. Mission captures are staged visual review, not evidence of human completion. Import PNG changes once with `godot --headless --editor --path game --quit`, then export. Build commands overwrite their own generated derivatives.

## Host keys

| Key | Function |
|---|---|
| Enter/Select, 1/2 | Admit pending phones |
| WASD / arrows | Local farmer movement review |
| E / slash | Local ACTION for farmer 1/2 |
| P | Pause/resume (cannot bypass missing-farmer pause) |
| V | Mute/unmute synthesized objective bell |
| R | Replay current seed; chooses solo/co-op from current admitted count |
| Results button | Next seed; remote focus is set automatically |
| M | Development overview |
| T | Development forced split positions |
| C | Development crop-state review |

Phone: drag to move, release to stop, ACTION to interact/hold, EXIT from tractor, Share clue, Drop item, Pause/resume. Tractor gauge reports input strength, not true vehicle speed. Phone controller reconnects automatically with its stored token.

## Source map

- `game/scripts/main_2d.gd`: movement, cameras, networking and vehicle.
- `game/scripts/weekend_session_2d.gd`: weekend, clocks, inventory/results/replay.
- `animal_incident_2d.gd`, `repair_incident_2d.gd`, `crop_field_2d.gd`: underlying systems.
- `production_world_2d.gd` + `game/data/world_layout.json`: layered map and collisions.
- `controller/`: phone UI; `server/`: relay; `shared/protocol.ts`: protocol.
- `source_assets/2d/`: original source art; `game/assets/2d/`: runtime derivatives.

Legacy 3D commands are archived in `docs/history/2026-09-30/USEFUL_COMMANDS.md`. They do not apply to the active game.

## Package source candidate

```sh
python3 scripts/package-release.py
```

Writes `artifacts/brackenridge-farm-source.zip` and `artifacts/release-manifest.json` with SHA-256 hashes. Includes source, retained art, current review docs and September 30 release/solo capture evidence; excludes `.godot`, toolchains, dependencies, environment files and signing keys. Rebuild exports before packaging.

## Vega simulator wrapper (candidate, gameplay unverified)

See `platform/vega/README.md`. SDK 0.24.12112 is installed locally under `.tools/vega-sdk`; CLI is `/Users/milanrabrenovic/vega/bin/vega`. Tools are excluded from source packaging. Configure the laptop address before each build:

```sh
node scripts/configure-vega.mjs http://127.0.0.1:8787/host/
cd platform/vega
vega exec npm install
vega exec npm run lint
vega exec npx tsc --noEmit
vega exec npm test -- --runInBand
vega exec npm run build:release
vega virtual-device start --display-res 1280,720
vega device info
vega exec vda reverse tcp:8787 tcp:8787
vega run-app build/aarch64-release/brackenridgefarm_aarch64.vpkg
```

Keep `npm run dev` and the simulator-starting terminal open. Debug/release package builds, lint, TypeScript and the template render test passed Sept30. SDK dependencies require network access and Watchman uses a cache outside the repository. The aarch64 simulator connected, reported Vega TV OS 1.2 and reached the laptop host URL with HTTP 200. Package install/launch was successful, but actual Godot gameplay/remote input was **not** visually verified. Do not substitute these results for a qualifying demo recording.

Vega startup correction: the configuration script writes a cleartext allowlist for its single configured host. Godot also requires a secure context; use trusted loopback plus VDA reverse forwarding for simulator development. The package requires the laptop relay and is not a standalone release. A production remote host needs trusted HTTPS/WSS. `FARM_HTTP_DIAGNOSTICS=1 npm run dev` enables resource path/status traces without request queries or phone tokens. Simulator PCK/WASM downloads and room creation passed on the isolated test relay; visual/full gameplay verification remains open.

Vega debug inspection attempt: `vega exec vda forward tcp:9229 tcp:9229` forwards the documented WebView inspector port after a Debug install. On this setup the inspector returned an empty response; this is a troubleshooting command, **not** a verified inspection route.

Component-liveness check: `vega device is-app-running --appName com.brackenridge.farm.main`. With the 30-minute component-timeout request it reported running >2 minutes after launch. `/json/list` on the forwarded inspector still returned an empty response immediately after launch. Neither check establishes rendered gameplay.

## Full solo motor route review

```sh
npm run test:solo
godot --path game --script res://tests/test_solo_playthrough.gd -- --capture
```

The route sends movement and quick ACTION/EXIT packets through the host input handler and normal simulation tick, uses real walker/tractor motors and physics collisions, herds five sheep with gate assistance, exercises the natural crop lifecycle, covers apples and delivers the order. It also checks solo phone-loss pause, reconnect resume and preservation of manual pause. It accelerates simulation for regression testing and skips the two planning waits explicitly; it is not a human playtest. The native capture option saves route frames under `docs/audits/2026-09-30-solo/`.

Seeded repair wording review (staged solo views, not a playthrough):

```sh
godot --path game --script res://tests/capture_repair_variants.gd
```

Writes `repair-belt.png` and `repair-gasket.png` in `docs/audits/2026-09-30-solo/`. The variants are forced while reviewing the same scene, so the seed banner does not establish a normally generated run.

## Mission experience capture

```sh
godot --path game --script res://tests/capture_mission_audit.gd
```

Captures eight staged cooperative screens and current private cards under `docs/audits/2026-09-30-missions/`. Verified September 30. This stages actors/outcomes for readability; it is not a completed human playthrough. Read `docs/MISSION_EXPERIENCE_AUDIT.md` alongside the real solo route evidence.

## Source publication handoff details

Read `docs/SOURCE_HANDOFF.md`. The prepared Git snapshot is under `artifacts/submission-source/brackenridge-farm/`; it is separate from the main development workspace. Public GitHub publication was approved and completed October 19 at https://github.com/MilanRabrenovic/brackenridge-farm . Refresh the snapshot from the curated source ZIP after further changes before committing/pushing.

## Mission clarity regression

```sh
npm run test:missions
```

Verified September 30: three-second purchase hold/reset/ownership, no late purchases, private-fact preservation, task-credit guards, deliberate driver tool operation, intake sealing, covers/crates and eight-second gate lease. Tractor farming uses 16 gold marked plots. Use **Engage field tool** before sowing and harvesting. Storage ACTION must seal intake before grain transfer. The briefing replaces the second purchase phase; a job result remains visible for three seconds. These checks do not measure human enjoyment.

## Sheep movement and breakout

```sh
npm run test:sheep
godot --path game --script res://tests/test_sheep_motion.gd -- --capture
```

Verified September 30: bounded staggered escape, airborne sprite/ground shadow, activated leg gait, fleeing, secured progress and replay reset. Native capture saves four staged frames under `docs/audits/2026-09-30-sheep/`. Full solo route and three scripted co-op routes still complete with the breakout enabled. This does not establish human entertainment.

## Co-op repair pressure review

```sh
npm run test:repair
npm run test:weekend
godot --path game --script res://tests/capture_coop_repair.gd
```

Mechanic ACTION inspection reveals the fault. HOLD builds pressure; RELEASE cools. Keep 40–75% GREEN while the runner holds to fit the delivered part. Outside green pauses fitting without erasing it; maintenance reduces fitting from six to three seconds. Solo helper manages pressure. The capture script stages low/green/hot instrument states and saves private facts/hints under `docs/audits/2026-09-30-repair-play/`; not a completed human session. Verified September 30. Native rendering required normal macOS graphics-service permissions after a restricted launch hung.

Export maintenance: dynamically referenced UI scripts must be included in both `game/export_presets.cfg` filters. The actual-PCK startup check caught the missing repair gauge, and passed after its inclusion. An APK export/signature success alone does not prove runtime resource completeness or device gameplay.

## Adaptive minimap

```sh
npm run test:minimap
godot --path game --script res://tests/test_minimap.gd -- --capture
```

Verified September 30: split-centre/shared-corner/merge placement, small-window logical bounds, solo mode, public target updates, order privacy, lobby/results hiding. Captures under `docs/audits/2026-09-30-minimap/` stage shared, split and merged gameplay views. The map uses `world_layout.json`, not another world camera. Project stretch uses logical viewport coordinates, so small-window checks use the visible logical rectangle.

## Android packaged-resource verification — October 5

```sh
npm run test:fireos-assets
```

Checks the actual APK ZIP CRC and boots its extracted Godot game resources in an isolated temporary directory with desktop Godot. The detector check deliberately removes the dynamic minimap script from the temporary copy and requires startup to fail. Both checks passed October 5 with 257 shipped resources. `export:fireos` automatically runs the positive startup check after creating the APK. This does not execute Android libraries or prove Fire TV rendering/input/performance. Temporary copies are cleaned up. Packaging now dates the release manifest with the current packaging date.

## Full cooperative motor route — October 5

```sh
npm run test:coop-route
godot --headless --path game --script res://tests/test_coop_playthrough.gd -- --seed=1732
godot --headless --path game --script res://tests/test_coop_playthrough.gd -- --seed=1733
godot --path game --script res://tests/test_coop_playthrough.gd -- --capture
```

Two input slots, actual physics travel/collision and normal simulation ticks, with no solo helper or actor/crop state teleport. Covers all four successful jobs, private facts, full natural crop lifecycle, both farmers' packing/joint delivery, results and replay. Default seed 1731 passed headless/native, producing repair/harvest/results captures under `docs/audits/2026-10-05-coop-route/`. Simulation runs accelerated at 600 ticks/second with 1/60-second motor steps; this is not human pacing, fun or device acceptance. Result-beat ACTION is blocked from entering equipment; the route verifies that storage transition behavior.

Final variant checks: complete input/physics routes for seeds 1732 and 1733 also passed (358.9 simulated seconds each), covering all three bounded weekend variants. This remains automated evidence, not a human playtest.

## October 5 TV inspection correction

Read supported Inspector setup in `platform/vega/README.md`. Local Appium 2.2.2/Kepler 3.30.0/Inspector 2026.9.2 created a session. Relaunched VISIBLE game yielded a 1280×720 window and black captured view; later refresh remained pending. This is diagnostic evidence, not TV gameplay verification. Amazon explicitly documents `gwsi-tool-screenshooter` as unsupported on VVD. Use `vda shell vlcm list` for component liveness. Developer-shell logs use `loggingctl log`; `journalctl` prints replacement guidance. Date-filter attempts did not recover launch-time logs this pass; they are not verified historical queries.

Source packaging includes the October 5 TV diagnostic README and pending Inspector image; it remains diagnostic evidence only.

## TV startup diagnostics regression — October 5

```sh
cd platform/vega
vega exec npm run lint
vega exec npx tsc --noEmit
vega exec npm test -- --runInBand --watchman=false
vega exec npm run build:debug
vega exec npm run build:release
```

Lint/TypeScript, three tests in two suites and all three configured architectures' builds passed. `--watchman=false` avoids the external Watchman cache and passed in the restricted shell. Fresh Debug install/launch reported visible ready 1280×720 canvas in scoped logs and native diagnostic strip. This is startup evidence only: Inspector still showed a flat game surface. See `platform/vega/README.md` and `docs/audits/2026-10-05-tv-inspection/`. Native errors expose friendly messages; development detail is not a release gameplay feature.

Source snapshot freshness: after packaging, extract the curated ZIP into `artifacts/submission-source/`, compare every entry against the archive, then stage/commit in its isolated Git checkout. October 5: 765 files compared; sanitized startup evidence has an explicit `.gitignore` exception. Check `git status --short` and `git remote -v` there before any approved publication.

The same exact-file exception also retains the earlier path/status-only `vega-startup-http.log`; inspected content contains local LAN URLs and HTTP statuses, with no queries or phone tokens. Both retained log files are part of the 765-file snapshot.

Simulator lifetime revalidated October 5: a launch shell alone does not prove QEMU/device liveness. Check current `vega device list`/`vda shell vlcm list`; keep the successful simulator launcher terminal open. A plain launch returned ready and then disconnected; a retained terminal restored connection. Inspector can retain stale frames after disconnect; require a fresh successful capture. Latest inspection requests failed despite VISIBLE game/READY renderer.

## October 15 laptop finishing checks

```sh
npm run test:finish
godot --path game --script res://tests/test_finish_pass.gd -- --capture
node --import tsx scripts/review-controller.ts
```

`test:finish` covers public guidance/privacy/routing/bounds, results freeze, replay consent/cancellation/disconnection/solo. The native option writes staged shared/split/results review frames. `review-controller.ts` starts an isolated localhost:8789 presentation fixture, prints its room URL, and displays a labelled development results card; its ready button restores walking controls. It does not run Godot or prove mission completion. Stop its terminal with Ctrl-C after review.

The full native co-op capture command now writes `coop-repair.png`, `coop-harvest.png`, `coop-results.png` into `docs/audits/2026-10-15-finish/`, preserving earlier evidence. Phone results now support next-seed replay: both co-op players ready (tap again cancels), one in solo. Disconnect removes consent. The phone header displays its current room; compare with the host if it appears to control an old session.

October 15 admission clarity: a connected pending phone now explicitly says to press Enter/Select on the host; the host roster shows waiting phones and the same admission action. Admission authority is unchanged. The hint hides after admission. The finishing regression checks the host prompt. Final exports/package are refreshed after this change.

## GitHub publication — October 19

Public destination authorized by the user: `MilanRabrenovic/brackenridge-farm`. Use the isolated checkout `artifacts/submission-source/brackenridge-farm/` for `git status`, commits and `git push origin main`. The development root is not a Git checkout. Candidate Web ZIP extracts to `build/web/` in a cloned repository; then `npm ci` and `npm run dev` serve it without rebuilding through Godot. Publication outcome is recorded in PROJECT_STATE.

Verified publication commands: `gh repo view MilanRabrenovic/brackenridge-farm --json visibility,defaultBranchRef`, `gh api repos/MilanRabrenovic/brackenridge-farm/commits/main --jq .sha`, and release metadata at `repos/MilanRabrenovic/brackenridge-farm/releases/tags/v0.9.0-candidate`. Initial main SHA matched local; all four uploaded file sizes and GitHub asset SHA-256 digests matched. The release is public and explicitly a prerelease.
