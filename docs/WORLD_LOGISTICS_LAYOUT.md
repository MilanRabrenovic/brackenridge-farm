# Implemented world logistics layout

Status note, 2026-09-24: this document validates routes and operational scale, not final visual quality. The production 2D layer, collision and occlusion contract is in [`2D_WORLD_PRODUCTION_PLAN.md`](2D_WORLD_PRODUCTION_PLAN.md). See [`PROJECT_STATE.md`](../PROJECT_STATE.md) for the truthful implementation status.

The current Godot greybox is generated from [`game/data/world_layout.json`](../game/data/world_layout.json). Changing that file changes the measured districts, roads, structures, gates, and vehicle envelopes used by the world builder.

## Operational decisions

- The combine begins in a dedicated machine shed beside the arable field.
- Its lane is 9 metres wide and its gate is 10 metres wide for a 6.5-metre vehicle envelope.
- The crop field reserves a 12-metre headland for a 9-metre-long combine.
- Grain travels from crop to combine to trailer to intake pit to silo to delivery.
- The tractor and trailer use the farm loop and grain lane; the combine does not use the bridge, footpaths, or animal lanes.
- Every operational district has at least two exits.
- The bridge provides a reliable crossing; the muddy ford is a riskier foot shortcut.
- Sheep, apiary, repair, crop, loading, and delivery systems have distinct home areas without owning the entire map.

## Camera validation

- Overview mode will show the complete 170 × 120 metre playable boundary.
- Gameplay mode frames the players and automatically zooms based on their separation.
- Press `M` in the development host to switch modes.
- The large QR lobby panel disappears after the first player is admitted.

## Scope boundary

The greybox validates geometry for future drivable machinery. The committed hackathon slice can keep tractors and the combine as simplified task stations, as specified in the approved game plan. This prevents vehicle physics from delaying the asymmetric cooperative loop while preserving a world that can support driving later.
