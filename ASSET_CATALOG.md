# Active 2D asset catalogue

Updated 2026-09-30. See `ART_DIRECTION.md` for integration/approval distinctions. The former exhaustive expansion catalogue is archived at `docs/history/2026-09-30/ASSET_CATALOG.md`; it is not a remaining-to-build promise for this slice.

| Required group | Runtime status | Source/runtime |
|---|---|---|
| Cohesive overview | User-approved design reference; never a playable background | `source_assets/2d/concepts/farm-overview-cohesive-v1.png` |
| Ground, lanes, yard, river | Integrated layered terrain, wear/blend masks, animated water | `cohesive_terrain_atlas.png`, runtime `cohesive_*` |
| Barn, machinery shed, workshop, feed store, silos, packing | Coordinated derivative set integrated under reference-matching request; collision/entrances separately measured | `reference_buildings_v3.png` → `reference_{barn,shed,workshop,feed,silos,packing}.png` |
| Oaks, apple, blossom, willow, hedges, turf | Reference-led coordinated derivative set integrated; trunks/boundaries collide separately | `reference_foliage_v2.png`, `reference_meadow_v2.png`, `cohesive_verges_atlas.png` |
| Walls, gates, verge/reeds/flowers | Integrated modular straight/vertical runs and gate gaps | runtime hedge/wall/verge modules |
| Barley | Eight soil/crop states; timed growth and paired tramline gaps | runtime terrain/crop sprites |
| Grower and Mechanic | Original four-direction four-frame walk; anchored idle breathing | `source_assets/2d/prototype/` → runtime `prototype/*_walk.png` |
| Red tractor | Four directions integrated under Sept30 finish instruction; side wheels spin, body bobs; no whole-image rotation | `tractor-directions.png` → `tractor_{down,up,left,right}.png`, `tractor_wheel_{front,rear}.png` |
| Sheep | Integrated art, deterministic herding/gate simulation; no gait sheet | runtime sheep sprite |
| Bridge/ford | Integrated crossing artwork and corresponding collision gaps | runtime `stone_bridge`, `shallow_ford` |
| Operational props | Hay, trough, tools, feed, hive, intake, parts, produce, trailer, van, signs integrated at authored layout locations | runtime production props; `world_layout.json` |
| Interiors/divider | Measured timber/masonry cutaways; compact rear-wall props; slim timber divider | `interior_timber.png`, `interior_limestone.png`, existing props |
| Carry visual | Existing crate attached to carrying farmer/parts runner | `produce_crates.png`; no dedicated carry pose |
| Mission/results UI | Arrival, four incident families, planning, private cards, timer/progress, crop-step/cell/growth guidance and contextual waypoints, results/replay, shared clue | Godot controls + controller HTML/CSS |
| App identity | Original vector barn icon and existing stone-barn launch splash | `game/icon.svg`, project settings |
| Weather/audio | Rain shader/overcast tint; original synthesized objective bell; mute key V | `rain_overlay.gdshader`, session-generated waveform |

Expansion-only: additional farmhouses/shelters, corn/wheat chains, drivable combine, implements, bespoke interiors, more farmers, animal gait sheets and authored work animations. Previous 3D characters/buildings remain legacy, not active release assets or finished art.
