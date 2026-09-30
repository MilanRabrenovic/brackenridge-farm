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

## Source publication handoff

Read `docs/SOURCE_HANDOFF.md`. The prepared Git snapshot is under `artifacts/submission-source/brackenridge-farm/`; it is separate from the main development workspace. Public/private visibility and creation/push have not yet been approved or performed. Refresh this snapshot from the curated source ZIP after further changes.
