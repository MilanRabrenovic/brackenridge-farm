# Useful commands

## Tractor review

- node scripts/build-tractor-directions.mjs: extract four runtime candidates from retained source.
- godot --headless --path game --script res://tests/test_tractor_review.gd: assert upright direction selection.
- godot --path game --script res://tests/test_tractor_review.gd: labelled candidate review captures (desktop graphics required).
- node scripts/review-controller.mjs: three-minute local controller fixture; prints room code, joins receive tractor mode and EXIT restores walking. Use only for development review.
- npm run build:controller after controller changes; refresh phone page to load updated CSS/JS.


## Solo event testing

Join with one phone to start the sheep → repair sequence. R on the host restarts it. Two-player interactions still require the other character; this change enables startup/testing rather than an AI helper or solo campaign.


## Browser startup verification

npm run export:web now also boots build/web/index.pck headlessly and rejects missing-script/resource errors. Always refresh the real browser afterward to verify WebGL and QR lobby. Source-tree tests alone cannot detect scene-filter export omissions.


## Cohesive map visuals

- `npm run assets:buildings`: extracts the coordinated six-building reference sheet into alpha-preserving runtime sprites. Run Web export to import.

- `npm run assets:reference`: rebuild six alpha-preserving foliage sprites and the meadow texture from retained reference-led source art. Run Web export afterward to import changes.

- `npm run assets:cohesive`: extract optimized terrain/verge sprites and rebuild the layout-derived blend mask.
- `npm run review:map`: native renderer captures eight real map views under `docs/audits/2026-09-28-cohesive/after-*.png`. Requires a graphical session.
- After visual changes run `npm run test:2d`, `npm run test:map`, `npm run typecheck`, then `npm run export:web`. Refresh the browser host to load the new export.


Last verified: 2026-09-28

Run commands from the project root:

```bash
cd /Users/milanrabrenovic/local/Hackatons/06-amazonappdev2026
```

## Install dependencies

```bash
npm install
```

On this Apple Silicon workspace, if the shell selects the older x64 Node installation, use the bundled arm64 runtime and refresh optional native packages:

```bash
PATH=/Users/milanrabrenovic/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:$PATH npm install --include=optional
```

## Start the relay and browser host

```bash
npm run dev
```

The server prints local host and phone-controller URLs. On the same Wi-Fi network, open the host URL on the laptop and scan its QR code with each phone.

## Run the native Godot host

```bash
godot --path game
```

If UDP relay discovery is unavailable:

```bash
FARM_RELAY_URL=ws://YOUR_COMPUTER_LAN_IP:8787/ws godot --path game
```

Replace `YOUR_COMPUTER_LAN_IP` with the Mac's LAN address. The phone and Mac must be able to reach one another on the same network.

## Build the browser export

```bash
npm run export:web
```

Then start or restart the development server:

```bash
npm run dev
```

The browser build is written to `build/web/` and served under `/host/`.

## Run checks

```bash
npm run typecheck
npm test
npm run test:godot
npm run test:2d
npm run test:map
```

If macOS selects an x64 Node process while the installed native packages are arm64, use the bundled arm64 runtime for the test commands:

```bash
PATH=/Users/milanrabrenovic/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:$PATH npm test
PATH=/Users/milanrabrenovic/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin:$PATH npm run test:godot
```

The directly verified fallback on this Mac is:

```bash
arch -arm64 /usr/local/bin/node --import tsx --test tests/*.test.ts
arch -arm64 /usr/local/bin/node --import tsx scripts/test-godot.ts
```

Use `npm run test:godot` only after the browser export and relay prerequisites are available.

## Build the Fire OS debug APK

```bash
npm run export:fireos
```

Output:

```text
artifacts/countryside-coop-debug.apk
```

## Install and launch on a connected Fire TV

```bash
.tools/android-sdk/platform-tools/adb install -r artifacts/countryside-coop-debug.apk
.tools/android-sdk/platform-tools/adb shell am start -n com.countrysidecoop.probe/com.godot.game.GodotAppLauncher
```

Start `npm run dev` before launching the APK so the host can discover the local relay.

## Rebuild authored asset source scripts

Regenerate the production map planning diagram from `game/data/world_layout.json`:

```bash
npm run map:plan
```

Output: `docs/maps/brackenridge-production-map.svg`. This SVG is a design and route-review artifact, not a runtime background.

Rebuild the current 2D portraits and normalized 1024px four-direction walk atlases from the retained full-resolution sources:

```bash
npm run assets:2d
```

The script writes `game/assets/2d/prototype/grower.png`, `mechanic.png`, `grower_walk.png` and `mechanic_walk.png`. The walk sheets use four columns of stride frames and the rows down, left, right and up. The farmyard and tractor runtime images are selected source copies and are not regenerated by this command.

Rebuild the reusable production buildings, trees and boundary sprites from the retained coordinated atlases:

```bash
npm run assets:world2d
```

This writes cropped transparent runtime images, eight terrain panels, the horizontal/vertical/corner/end/gate hedge and wall modules, and the generated shared `contact_shadow.png` under `game/assets/2d/production/`. New PNGs require one Godot import pass before direct script tests: `godot --headless --editor --path game --quit`.

The commands below rebuild rejected or legacy 3D source. They are retained for history and must not be used as the active presentation pipeline:

These scripts overwrite their corresponding `.glb` outputs. Run one only when intentionally regenerating that asset:

```bash
python3 scripts/split_machinery_shed_atlas.py
python3 scripts/split_storybook_asset_atlases.py
blender --background --python scripts/create_tractor_asset.py
blender --background --python scripts/create_stone_barn_asset.py
blender --background --python scripts/create_machinery_shed_asset.py
blender --background --python scripts/create_storybook_existing_assets.py
blender --background --python scripts/create_boundary_kit.py
blender --background --python scripts/create_grain_store_asset.py
blender --background --python scripts/create_grain_chain_assets.py
blender --background --python scripts/create_secondary_buildings.py
blender --background --python scripts/create_player_characters.py
blender --background --python scripts/create_rigged_character_candidates.py
blender --background --python scripts/create_pip_puddleboots.py
python3 scripts/create_storybook_asset_contact_sheet.py
```

`create_player_characters.py` rebuilds the rejected primitive-pivot experiments. `create_rigged_character_candidates.py` rebuilds the rejected Grower, Mechanic and Milo source-body direction. Neither should be used for current review art. `create_pip_puddleboots.py` deletes the imported visible source meshes, keeps the free Quaternius CC0 skeleton and animations, authors Pip's visible body/outfit/face, and exports `game/assets/characters/rigged/bracken_pip_puddleboots.glb`.

`create_storybook_existing_assets.py` applies the shared painted materials to the barn and tractor, rebuilds the oak, hawthorn and drystone wall, exports all five GLBs, and renders their individual previews. Run the atlas splitter first.

`create_boundary_kit.py` creates the optimized modular hawthorn and drystone-wall kits plus the natural oak courtyard base under `game/assets/environment/boundary_kit/`. These assets are integrated into the playable map and remain available in the isolated review.

`create_grain_store_asset.py` creates `game/assets/buildings/bracken_grain_store.glb` and renders `docs/previews/bracken-grain-store.png`. It overwrites both files.

`create_farmyard_environment.py` is superseded and creates the old rejected versions. Do not run it.

The machinery-shed pipeline expects the source atlas at `source_assets/textures/machinery_shed_storybook_atlas_v1.png`. Run the split script first to create the four optimised 512px runtime textures, then run the Blender generation script.

## Development camera shortcuts

With the game canvas focused:

| Key | Action |
|---|---|
| `M` | Toggle full-map overview and normal gameplay camera |
| `T` | Separate two players to test split screen |
| `1` / `2` | Admit the corresponding pending phone during development |
| `Enter` / Select | Admit pending phone players |
| `WASD` | Move Player 1 for laptop animation/collision review |
| Arrow keys | Move Player 2 for laptop animation/collision review |
| `C` | Cycle the barley field through every visual growth/consequence state |
| `R` | Restart the sheep → repair event sequence |

These are developer presentation controls, not final player controls.

## Useful source locations

| Purpose | Location |
|---|---|
| WebSocket server | `server/main.ts`, `server/rooms.ts` |
| Shared message protocol | `shared/protocol.ts` |
| Phone controller | `controller/` |
| Godot host scene | `game/main.tscn` |
| Active 2D host/camera logic | `game/scripts/main_2d.gd` |
| Active 2D runtime art | `game/assets/2d/prototype/` |
| Full-resolution 2D source art | `source_assets/2d/prototype/` |
| 2D asset preparation | `scripts/prepare-2d-prototype-assets.mjs` |
| Layered production world | `game/scripts/production_world_2d.gd` |
| Crop growth and field work | `game/scripts/crop_field_2d.gd` |
| Guide-and-gate incident | `game/scripts/animal_incident_2d.gd` |
| Production environment art | `game/assets/2d/production/` |
| Production atlas preparation | `scripts/prepare-production-world-assets.mjs` |

After adding a production PNG, run `npm run assets:world2d` and then `godot --headless --editor --path game --quit` once so Godot creates import metadata before headless tests or export.
| Legacy 3D host/world | `game/scripts/main.gd`, `game/scripts/world_layout.gd` |
| Measured layout data | `game/data/world_layout.json` |
| Legacy 3D vehicles/buildings/characters | `game/assets/vehicles/`, `game/assets/buildings/`, `game/assets/characters/` |
| Browser and Fire OS export | `game/export_presets.cfg`, `scripts/export-*.mjs` |

## Reproduce the map placement review

```bash
npm run review:map
```

Captures ten native 1280 × 720 views to `docs/audits/2026-09-28-cohesive/after-*.png`: yard, pasture, orchard, dispatch, overview, mature field, mature overview split screen, interior and repair. This launches native Godot and needs desktop graphics access. `npm run test:map` checks full road clearance and all destination connectivity using actual physics collision.

## Repair regression

Run npm run test:repair to verify private roles, inspection, wrong/correct parts, shared holding, distance, success, timeout and two-player interior reveal. Source: game/scripts/repair_incident_2d.gd.
