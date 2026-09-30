# Visual-world correction review — 2026-09-25

## Result

The correction pass now reads as one playable English farm rather than a scatter of unrelated objects. The central court, crop gate, pasture route, orchard, loading yard and river crossings have clear spatial roles. This is a coherent gameplay baseline; it is not the final submission-art pass.

## Evidence

- `01-central-yard.png` — shared gameplay camera, two farmers, tractor, work zones, walls, hedges and gates.
- `02-mature-barley.png` — authored mature barley clusters, open headland and two paired tractor tramlines.
- `03-river-crossings-split.png` — adaptive split screen with illustrated stone bridge and shallow ford.
- `04-overview.png` — complete 170 × 120 metre topology with connected routes and continuous field boundaries.

All captures are native 1280 × 720 Godot renders from the active runtime world.

## Corrections completed

- Replaced stick-like procedural crop marks with authored seed, seedling, young, mature, damaged, stubble and swath art.
- Increased mature crop density while preserving a working headland and two paired tramline gaps.
- Replaced disconnected boundary posts with continuous horizontal/vertical hawthorn and drystone modules plus visible open gates.
- Replaced geometric bridge/ford shapes with illustrated, scale-correct crossings while retaining their collision gaps.
- Added purposeful barn, livestock, workshop, feed and packing props to explain the yard's activity zones.
- Enlarged the workshop and feed store and increased both farmer sprites from `0.105` to `0.14` scale for television readability.
- Removed striped/repeating track textures and used continuous dirt surfaces with tyre marks and square route terminals.
- Fixed the generated-atlas alpha pipeline. Source images that already contain alpha now retain it instead of being cleared a second time.

## Remaining visual work

- Dirt routes are coherent and driveable but still need final authored verge/apron/junction masks.
- The orchard footpath and yard-to-road transitions need a final edge-blend pass.
- Farmers still need idle, carry and job-specific animations; the tractor still uses one rotatable view.
- Contextual destination, partner and interaction markers remain to be designed around the first incident.
- The new crop, boundary and infrastructure art is an integrated review candidate pending the user's final visual acceptance.

## Verdict

The map is ready for a two-phone route/collision playtest and then the first complete asymmetric incident. Do not expand the world footprint or add more incident categories before that test.
