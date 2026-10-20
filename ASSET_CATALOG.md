# Active 2D asset catalogue

Updated 2026-09-30. See `ART_DIRECTION.md` for integration/approval distinctions. The former exhaustive expansion catalogue is archived at `docs/history/2026-09-30/ASSET_CATALOG.md`; it is not a remaining-to-build promise for this slice.

| Required group | Runtime status | Source/runtime |
|---|---|---|
| Cohesive overview | User-approved design reference; never a playable background | `source_assets/2d/concepts/farm-overview-cohesive-v1.png` |
| Ground, lanes, yard, river | Integrated layered terrain, wear/blend masks, animated water | `cohesive_terrain_atlas.png`, runtime `cohesive_*` |
| Barn, machinery shed, workshop, feed store, silos, packing | Coordinated derivative set integrated under reference-matching request; collision/entrances separately measured | `reference_buildings_v3.png` → `reference_{barn,shed,workshop,feed,silos,packing}.png` |
| Oaks, apple, blossom, willow, hedges, turf | Reference-led coordinated derivative set integrated; trunks/boundaries collide separately | `reference_foliage_v2.png`, `reference_meadow_v2.png`, `cohesive_verges_atlas.png` |
| Walls, gates, verge/reeds/flowers | Integrated modular straight/vertical runs and gate gaps | runtime hedge/wall/verge modules |
| Barley | Eight soil/crop states; 16 gold plot targets, local work patches and deliberate sow/harvest engagement; timed growth and paired tramline gaps | runtime terrain/crop sprites |
| Grower and Mechanic | Original four-direction four-frame walk; anchored idle breathing | `source_assets/2d/prototype/` → runtime `prototype/*_walk.png` |
| Red tractor | Four directions integrated under Sept30 finish instruction; side wheels spin, body bobs; no whole-image rotation | `tractor-directions.png` → `tractor_{down,up,left,right}.png`, `tractor_wheel_{front,rear}.png` |
| Sheep | Integrated existing art; staggered fence jumps, rushed-approach jinks, shader leg-pair gait and grounded jump shadows; no authored directional gait sheet | runtime sheep sprite |
| Bridge/ford | Integrated crossing artwork and corresponding collision gaps | runtime `stone_bridge`, `shallow_ford` |
| Operational props | Hay, trough, tools, feed, hive, intake, parts, produce, trailer, van, signs integrated at authored layout locations | runtime production props; `world_layout.json` |
| Interiors/divider | Measured timber/masonry cutaways; compact rear-wall props; slim timber divider | `interior_timber.png`, `interior_limestone.png`, existing props |
| Carry visual | Existing crate attached to carrying farmer/parts runner | `produce_crates.png`; no dedicated carry pose |
| Mission/results UI | Arrival, four incident families, confirmed planning/briefing, persistent private facts/current hints, result beats, repair pressure instrument, adaptive schematic minimap, timer/progress, crop-step/cell/growth guidance and contextual waypoints, results/replay, shared clue | Godot controls + controller HTML/CSS |
| App identity | Original vector barn icon and existing stone-barn launch splash | `game/icon.svg`, project settings |
| Weather/audio | Rain shader/overcast tint; original synthesized objective bell; mute key V | `rain_overlay.gdshader`, session-generated waveform |

Expansion-only: additional farmhouses/shelters, corn/wheat chains, drivable combine, implements, bespoke interiors, more farmers, animal gait sheets and authored work animations. Previous 3D characters/buildings remain legacy, not active release assets or finished art.

October 15 UI update: per-farmer contextual cards/offscreen compass, centred results and phone replay voting/room badge are implemented as code-native UI. No new raster asset or map integration approval required or claimed. Existing animation limitations remain unchanged. Evidence: `docs/audits/2026-10-15-finish/`.

## Submission artwork

| Asset | Status | Files / verification |
|---|---|---|
| Devpost cover v1 | Prototype — promotional candidate awaiting user review; not integrated into the world | `source_assets/2d/marketing/devpost-thumbnail-v1.png`, retained prompt; `artifacts/submission/brackenridge-farm-devpost-thumbnail.jpg`. 1536×1024, 1,162,991 bytes, decode/aspect/size checks and visual review passed. |

| Devpost gallery v1 (four images) | Prototype — submission layouts awaiting user review; no runtime integration | Actual native recording frames at 28/110/271/351s; source/provenance `source_assets/2d/marketing/gallery-v1/`; 1536×1024 upload JPEGs `artifacts/submission/gallery-v1/`, all under 5 MB, decoded and visually inspected. |

## October 20 — compatibility dependency

| Asset | Status | Location |
|---|---|---|
| Noto Sans Regular | Utility font dependency, SIL Open Font License; guest UI inspected; no world-art approval implied | `platform/vega-gles2/fonts/NotoSans-Regular.ttf`, `fonts/OFL.txt` |

Existing farm/character/tractor art is reused unchanged by the compatibility generator. Godot 3 engine notices are retained under `platform/vega-gles2/licenses/` and copied into its Web runtime. No new map asset was integrated.

## Vega derived runtime cache — October 20

| Existing asset derivative | Status / purpose | Location |
|---|---|---|
| Static ground composite | Build-time cache of integrated terrain shader, with animated river kept separate; no new visual approval claimed | generated `build/vega-gles2-source/assets/2d/production/vega_baked_ground.png` |
| Six cleaned building textures | Existing alpha-cleanup shader cached per building; separate cutaway/collision retained | generated `vega_clean_reference_*.png` |

Regenerate via the compatibility builder; original source/runtime art under `game/` remains unchanged. No new asset-design scope was added.

## October 20 — demo media only

Genuine Vega gameplay video uses existing runtime art, simple editorial captions and a labelled reproduction of actual private clues; no new runtime asset or approval state changed. CC0 TinyWorlds Forest Ambience is demo-only audio; provenance is `source_assets/audio/demo/ATTRIBUTION.md`. Video/check scope: `docs/DEMO_VIDEO.md`.
