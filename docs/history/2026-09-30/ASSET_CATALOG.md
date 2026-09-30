# Asset catalogue and production order

## 2026-09-28 — Directional tractor candidate

| Asset | Status | Files |
|---|---|---|
| Red tractor front/rear/left/right | Prototype — awaiting user approval, isolated review only | source_assets/2d/production/tractor-directions.png → game/assets/2d/production/tractor_{down,up,left,right}.png |

Rebuild with node scripts/build-tractor-directions.mjs. Native camera review through game/tests/test_tractor_review.gd. Existing tractor art remains on main map, now upright.


## 2026-09-28 — Interior export fix

interior_limestone.png is the runtime copy of existing original barn limestone under game/assets/2d/production, ensuring inclusion in scene-filtered exports. Appearance unchanged; no new art approval claimed.


## 2026-09-28 — Presentation reuse

Reused original painted timber as runtime interior_timber.png for the narrow divider and measured cutaway floors; existing limestone supplies wall strips. No new generated art or user approval claimed. Native split/interior reviewed in docs/audits/2026-09-28-cohesive/gameplay-*.png. Interiors remain unfurnished functional cutaways awaiting visual acceptance. Boot alignment and stronger contact shadows ground farmers; moving sheep excluded from static shadow baking.


## 2026-09-28 — Coordinated buildings and connected yard

Replaced all six runtime structure illustrations with one coordinated source atlas: stone barn, sage machinery shed, workshop, feed store, twin silos and packing canopy. Clean silhouettes remove the previous floating extraction debris. Layout structure asset references select the new set while measured collision, entrances and reveal areas remain unchanged. Added facade-corner planting, kept centre entrances clear, and joined visual road bends with bounded curves. A separate opaque wear mask adds paired wheel wear along lanes and entrance-to-yard work routes; it cannot be stored in the ground mask alpha because texture import treats alpha as transparency.

Source: `source_assets/2d/production/reference_buildings_v3.png`. Optimized 512px assets: `game/assets/2d/production/reference_{barn,shed,workshop,feed,silos,packing}.png`. Rebuild: `npm run assets:buildings`; terrain mask: `npm run assets:cohesive`. Generated with the built-in image tool using the approved overview as reference. Applied under the user's explicit reference-matching request; final visual acceptance remains theirs.

Verification: inspected native yard, overview and bridge/apiary split; eight views saved as `docs/audits/2026-09-28-cohesive/estate-final-*.png`. 2D host suite, 468 clearance samples, TypeScript, nine Node tests and Web export pass. Relay regression passes at 23.3ms with private clues, screen directions and tractor phone mode.

The farm now translates the reference through independent ground, buildings, foliage, crops, props and actors. It is not pixel-identical: buildings are more front-facing, the playable yard/headland are broader for manoeuvring, trees repeat, river detail is simplified and character/work animations remain incomplete. Fire TV performance is unverified. No finished-game or hardware-ready claim.

Recommended next task: physical two-phone acceptance of the new farm, checking doorway visibility, vehicle clearance and split-camera readability, before adding more incident content.


## 2026-09-28 — Reference-led foliage and meadow replacement

Used the built-in image-generation tool with the approved overview to create a coordinated rounded oak/oak variant, apple, blossom, willow and flowering hedge atlas, plus a meadow tile. Sources: `source_assets/2d/production/reference_foliage_v2.png` and `reference_meadow_v2.png`. Runtime derivatives are `reference_*.png`; extraction uses measured cells, preserves alpha and limits trees to 384px. User requested applying the reference as closely as possible; this coordinated derivative set is integrated for runtime review under that request, not separately claimed as visually approved.

Replaced sparse tree art, thickened connected boundaries (including overlapping crowns for vertical runs), blended flower meadow with short turf, and increased mature crop density while retaining readable tramline exclusions. Collision footprints, entrances, vehicle lanes and crop headland exclusion remain. No building reconstruction was completed in this pass: the existing structures were retained because the approved reference uses similar buildings. This pass addresses the conspicuous vegetation gap; composition parity is still incomplete.

Verification: 2D host suite, 468 clearance samples, TypeScript and Web export pass. Inspected native overview and yard and corrected sprite-cell bleed plus disconnected hedge stacking. Final captures: `docs/audits/2026-09-28-cohesive/reference-final-*.png`. Mature overview advances growth for review only. Hardware performance and physical two-phone acceptance remain unverified; higher crop sprite density needs Fire TV profiling.

Next task: review the new art at close gameplay scale with two phones, then author a coordinated building/apron scene and work animation set. Do not describe this as visual parity with the reference.


## 2026-09-28 — Sprite edges and ambient character polish

Applied a connected-alpha shader to existing structure sprites to suppress isolated extraction flecks while preserving source PNGs and reveal transparency. Varied peripheral tree spacing, scale, mirroring and tint, with fewer flowering trees; all variation is deterministic and outside functional routes. Added restrained idle breathing anchored at the feet and stick-speed-driven walking playback. These are presentation refinements, not new authored repair/carry/harvest frames.

Verified: 2D host suite and 468 physics route samples pass; native yard and overview inspected at 1280×720; eight `detail-*.png` captures saved under `docs/audits/2026-09-28-cohesive/`; Web export passed. Existing baked perspective, some connected sprite-edge noise and tree silhouette reuse remain visible. Fire TV performance remains unverified.


## 2026-09-28 — Sunlight and grounding polish

Added soft alpha-silhouette shadows cast southeast from static scenery, independent of actor y-sort. Contact shadows stay under actors; farmers now have foot shadows. Shortened the initial projection after native review to reduce detached-looking props. Added subtle crown-weighted tree/reed breeze, reduced yard pebble scale/contrast, and finer slower water texture motion. No collision, placement or incident rules changed.

Verification: native yard and split views inspected, eight capture views saved as `docs/audits/2026-09-28-cohesive/polish-*.png`; 2D host test and all 468 clearance samples pass; Web export succeeds. Initial inferred-type compile error was corrected before final checks. Fire TV performance, physical phone acceptance and final visual approval remain unverified. Shadows are economical 2D projections, not physically reconstructed building volumes. Legacy sprite speckles, repeated trees, directional vehicle art and missing work animations remain.


## 2026-09-28 cohesive direction implementation

| Set | Status | Runtime/source |
|---|---|---|
| Cohesive overview reference | Approved by user as direction | `source_assets/2d/concepts/farm-overview-cohesive-v1.png` |
| Coordinated grass, earth, yard, water | Applied under approved-reference implementation request; runtime review pending | `cohesive_*.png` in production assets |
| Hedge/wall horizontal and vertical modules, reeds, flowers, shrub, rocks | Coordinated derivatives; integrated hedge/wall/reeds/flowers/shrub; rocks extracted but unused | `verge_*.png` in production assets |

Sources: `cohesive_terrain_atlas.png`, `cohesive_verges_atlas.png`, `cohesive_grass_source.png`. Rebuild through `npm run assets:cohesive`. Preserve the source alpha. Earlier placement-status notes below are historical.


Last reviewed: 2026-09-28

## 2026-09-28 placement status

Existing integrated candidates were repositioned; no new art was generated or approved. Buildings, operational props and trees now load positions from layout v5. The trough is in the pasture, apiary is visible beside the orchard path, trailer/intake form the grain zone, produce sits beside the canopy and the van is parked off the lane. Boundary runs now leave bridge and orchard exits. Terrain seam treatment, boundary variation and gate state art remain required before visual release approval.


## 2026-09-25 visual correction set

| Set | Runtime assets | Status | Evidence |
|---|---|---|---|
| Barley lifecycle | seeded row, seedling, young, mature, damaged, stubble, headland, cut swath | Review — integrated candidate | `docs/audits/2026-09-25-visual-correction/02-mature-barley.png` |
| Continuous boundaries | horizontal/vertical hawthorn, hedge gate, horizontal/vertical drystone, wall gate | Review — integrated candidate | `01-central-yard.png`, `04-overview.png` |
| River crossings | stone bridge, shallow ford | Review — integrated candidate | `03-river-crossings-split.png` |
| Working-yard props | hay bales, supplies, tool station, trough, produce crates, destination sign | Review — integrated candidate | `01-central-yard.png` |
| Operational activity set | two sheep poses, apiary hives, grain intake, farm trailer, dispatch van, produce pallet, spare-parts crate | Review — integrated; five sheep now animate and participate in the complete guide-and-gate incident, while the other items remain functional anchors | `docs/audits/2026-09-25-animal-incident/`, `docs/audits/2026-09-25-functional-map-final/` |

Full-resolution sources are `crop_stages_atlas.png`, `boundary_modules_v2_atlas.png` and `farm_infrastructure_atlas.png` under `source_assets/2d/production/`. Runtime crops live under `game/assets/2d/production/`.

## Status key

- **Planned** — required but not yet specified or created.
- **Specification ready** — dimensions, function, variants, and review view are defined.
- **In production** — currently being made.
- **Review** — visible review asset exists and awaits approval.
- **Approved** — user accepted the asset; safe to place in the world.
- **Integrated** — placed and verified in the playable map.
- **Rejected** — current version does not meet the art direction and must not be treated as final.

## Production rule

Create and approve assets one by one. Review each in isolation first. Once the user asks to see an accepted candidate in the playable farm, record that decision and integrate it. The stone barn and red tractor set the minimum quality bar.

## Active 2D conversion assets

| Asset | Required production result | Status |
|---|---|---|
| Illustrated farmyard | Layered terrain, buildings, foreground occlusion, irregular crops, routes and boundaries | Integrated functional baseline — topology v4 connects all committed activities, has textured routes, ten contextual destinations, snapped collision and edge-safe cameras; visual approval and weather variants remain |
| 2D Grower | Distinct face/outfit; four-direction idle/walk/run and farm actions | Integrated review proof — original four-direction, four-frame walk atlas live; idle/run/work actions remain |
| 2D Mechanic | Distinct face/outfit; four-direction idle/walk/run and repair actions | Integrated review proof — original four-direction, four-frame walk atlas live; idle/run/work actions remain |
| 2D red tractor | Four/eight directions, wheel motion, driver, hitch and load states | Integrated review proof — one rotatable view with entry/drive/exit logic |
| Shared contact shadow | Soft transparent ellipse, consistently scaled under world actors and structures | Integrated technical asset — generated deterministically and live under buildings, trees and tractor |

All 3D rows below are legacy production history. Their functional specifications may inform the 2D replacements, but their models are excluded from current release exports.

## Priority production queue

| Order | Asset | Purpose | Required features | Status |
|---:|---|---|---|---|
| 1 | Main machinery shed | Home for tractor, combine, trailer, and attachments | Open bays, hand-painted storybook materials, vehicle clearance, warm interior, readable details | Integrated — storybook benchmark |
| 2 | Grain store and intake building | Receive harvested grain and explain storage flow | Drive-over intake, unloading marker, interior bay, visible stored-state variants | Integrated candidate — loading route installed; visual signoff and unloading logic remain |
| 3 | Proper grain silo set | Store grain without blocking the yard | Two or three connected silos, ladder/pipes, fill indicators, loading clearance | Integrated candidate — three connected painted silos; fill logic remains |
| 4 | Authored hedgerow kit | Define connected irregular fields | Straight/curved/end/gate pieces, layered foliage, trunks, seasonal/wet variants | Integrated review candidate — horizontal/vertical/end modules follow measured field edges with passable route gaps; user visual approval and authored corner/gate states remain |
| 5 | Terrain material system | Unify the whole world | Pasture, soil, crop, yard, lane, mud, verge and blended transitions | Integrated review pass — eight coordinated textures now repeat at the corrected gameplay scale; route tyre wear and river reflection layers are live; authored junctions, transition masks, wetness and puddles remain |
| 6 | Drystone wall and gate kit | Bound livestock and older fields | Corners, damaged segment, end caps, repair state, vehicle and foot gates | Integrated review candidate — snapped wall runs and yard opening have matching collision; user visual approval, damaged and working gate states remain |
| 7 | English tree kit | Landmarks and boundary vegetation | Oak, ash, willow, small orchard tree; age/shape variants and wind motion | Integrated functional pass — oak, willow, orchard and flowering trees have trunk collision and canopy reveal; wind/season variants remain |
| 8 | Crop field system | Prepare, grow, treat and harvest crops | State transitions, rows, headlands, tramlines, stubble, damage masks | Integrated functional pass — tractor coverage prepares and seeds; timed seedlings/young/mature growth, irregular plant clusters, tramline gaps and harvesting to stubble are live; treatment/damage gameplay remains |
| 9 | Combine harvester | Harvest and unload grain | Cabin, header, wheels, steering, header/unload animation pivots | Integrated candidate — model and pivots exist; driving/harvesting remain |
| 10 | Grain trailer | Move grain from combine to intake | Hitch, wheels, fill levels, tipping/unload animation | Integrated candidate — model and pivots exist; hitch/fill/unload remain |

The **main machinery shed** is the first storybook benchmark and is now placed on the east side of the playable farmyard. Press `H` for its isolated review or inspect `docs/previews/bracken-machinery-shed.png`.

### Main machinery shed specification

- Footprint: approximately 24 × 11.5 metres, plus a broad concrete apron.
- Structure: five dark steel portal frames supporting four structural bays.
- Access: three complete open-front machinery bays; the fourth contains an enclosed parts room.
- Clearance: approximately 5.8–6.3 metres between posts and 4.75 metres at the eaves.
- Exterior: warm chestnut cladding, honey Cotswold-limestone plinth, bright sage/mint corrugated roof, cream trim, translucent daylight strips, gutters and downpipes.
- Interior storytelling: golden work lamps, cheerful bay markers, red tool chest, workbench, spare tyres, colourful barrels and stacked parts crates.
- Storybook geometry: heavier rounded supports, oversized cream fascia, round blue gable window and a small ridge vent break the industrial silhouette.
- Painted materials: four original 512px textures provide brush-painted limestone, timber, weathered sage metal and cream concrete without expensive surface geometry.
- Review scale reference: the approved-direction red tractor is parked inside the first bay in the isolated review scene.
- Files: `game/assets/buildings/bracken_machinery_shed.glb`, `game/assets/textures/machinery_shed/`, `source_assets/textures/machinery_shed_storybook_atlas_v1.png`, `game/scenes/buildings/machinery_shed.tscn`, and `docs/previews/bracken-machinery-shed.png`.
- Integration decision: placed in the playable farm after the user explicitly requested that the completed assets appear on the actual map.

## Buildings and structures

| Asset | Variants or interactions | Status |
|---|---|---|
| Stone barn | Open entrance, storage interior, optional door animation | Integrated — painted limestone, slate, timber and iron |
| Main machinery shed | Three open bays, enclosed parts room, painted textures, lights, collision | Integrated — storybook benchmark |
| Grain store/intake building | Intake pit, unloading state, interior | Integrated candidate — authored straight-through intake and grain hall; roof collision removed and interaction states planned |
| Grain silo set | Empty/part/full indicators, pipework | Integrated candidate; state logic remains |
| Workshop | Repair bay, tool wall, parts shelves, door state | Integrated candidate — authored two-bay workshop; isolated review and collision complete; interaction states planned |
| Packing/loading shed | Crates, orders, loading point, canopy | Planned |
| Feed store | Wide doors, feed sacks, loading porch, stock state | Integrated candidate — authored compact stone store; isolated review and collision complete; interaction states planned |
| Livestock field shelter | Hay/feed storage, weather protection | Planned |
| Small farmhouse/office exterior | Background landmark; limited interaction | Planned |
| Apiary shelter | Smoker/tool storage and hive equipment | Planned |
| Delivery entrance/sign structure | Arrival point and readable gate | Planned |
| Distant farm structures | Non-interactive world depth | Planned |

### Grain store and intake review specification

- Overall working pad: approximately 28 × 22 metres.
- Grain hall: 14 × 14 metres with a raised six-metre front door, visible retaining wall and stored-grain mound.
- Intake lane: 8.9 metres between outer columns, 6.5 metres vertical clearance and an unobstructed front-to-back route.
- Intake pit: five-metre-wide, seven-metre-long framed grate with television-readable ochre safety edging.
- Material language: chestnut timber, honey limestone, slate, sage metal and warm concrete reuse the approved painted material families.
- Operational storytelling: overhead auger, transfer pipe, ladder, fill-state lights, work lamps and a clear intake marker explain the grain flow.
- Performance: repeated geometry is joined by material before export; collisions preserve the grain-hall opening and complete intake lane.
- Review evidence: `docs/previews/bracken-grain-store.png` and the in-engine `G` review with tractor/trailer scale references.
- Remaining before integration: user visual approval, final placement and route check in the real farm, and later interactive unload/fill states.

## Vehicles and implements

| Asset | Required moving parts or states | Status |
|---|---|---|
| Red tractor | Steering, rotating wheels, hitch, driver position | Drivable from phone; wheel/steering animation active; hitch remains |
| Combine harvester | Wheels, steering, header, reel, auger, grain fill | Integrated authored candidate; gameplay remains |
| Grain trailer | Wheels, hitch, fill states, tipping bed | Integrated authored candidate; gameplay remains |
| Flatbed/utility trailer | Hitch, load anchors, cargo states | Planned |
| Delivery van or farm truck | Doors, load states, arrival/departure | Integrated static review sprite at dispatch; animation and load states remain |
| Cultivator | Raised/lowered, soil preparation effect | Planned |
| Plough | Raised/lowered, furrow result | Planned |
| Seed drill | Raised/lowered, seed use, row result | Planned |
| Sprayer | Folded/deployed booms, liquid state | Planned |
| Fertiliser spreader | Attached state and visible application | Planned |
| Mower | Raised/lowered, cut-grass result | Planned |
| Baler | Pickup animation and bale output | Planned |
| Front loader/forks | Lift/tilt and pallet handling | Planned |

## Terrain and surface systems

| Asset/system | Required states | Status |
|---|---|---|
| Base landscape mesh | Gentle slopes, drainage, connected parcels | Planned |
| Farmyard surface | Compacted gravel, concrete apron, dirt edges, drainage | Rejected current version; replacement planned |
| Muddy farm lane | Dry, damp, wet/rutted | Planned |
| Asphalt/public-road edge | Clean join to delivery entrance | Planned |
| Pasture terrain | Grazed, long grass, muddy/damaged | Planned |
| Ploughed soil | Directional furrows, headland turns | Planned |
| Prepared seedbed | Fine soil rows and vehicle passes | Planned |
| Seeded terrain | Subtle drill lines and markers | Planned |
| Crop tramlines | Parallel wheel tracks aligned to working width | Implemented visually in barley field; tool validation remains |
| Harvested stubble | Cut rows, straw residue, wheel damage | Planned |
| Puddles and wetness | Shape follows terrain, reflections and wet edges | Rejected current discs; replacement planned |
| Stream, ditch and pond | Banks, reeds, crossings, wet margins | Planned |

## Crops and field vegetation

Each crop needs low-cost LODs or density control suitable for Fire TV.

| Crop | Required states | Status |
|---|---|---|
| Permanent grass | Short/grazed, growing, long, cut, windrow | Planned |
| Wheat | Seedling, growing, mature, tramlines, harvested, damaged | Planned |
| Barley | Seedling, growing, mature, tramlines, harvested, damaged | Planned |
| Maize/corn | Young, mature, harvested rows, damaged | Planned |
| Meadow flowers | Sparse verge and meadow clusters | Planned |
| Cover/rough field growth | Weeds and neglected patches | Planned |

## Boundaries and vegetation

| Asset | Variants | Status |
|---|---|---|
| Hawthorn hedgerow kit | Layered straight, curved, corner, end, gate gap | Integrated review candidate — snapped horizontal/vertical runs and tapered openings are live; visual approval and final corner/gate variants remain |
| Drystone wall kit | Straight, curved, corner, end, damaged | Integrated review candidate — measured west-yard/meadow runs are live; visual approval, damaged and movable-gate variants remain |
| Post-and-rail fence | Straight, corner, end, broken | Planned |
| Wire livestock fence | Posts, wire, damaged section | Planned |
| Vehicle gate | Open/closed/held/damaged | Ordinary timber gate integrated visually; interaction and combine-width variant planned |
| Foot gate | Open/closed/latched | Planned |
| Temporary sheep hurdles | Carryable and connectable | Planned |
| Mature oak | Multiple crown shapes, wind response | Hero oak and natural courtyard base integrated; variants and wind planned |
| Ash/tree-line trees | Shape variants, seasonal tint | Planned |
| Willow | Stream-side landmark | Planned |
| Orchard trees | Growth/fruit/harvest states | Planned |
| Bramble/nettle/verge kit | Controlled clusters | Planned |

## Animals, characters and animation

| Asset | Required states | Status |
|---|---|---|
| Player character set | 2–4 distinct friendly 2D characters with different faces, silhouettes, costumes, colours, symbols and directional idle/walk/run/carry/interact/drive animation | Integrated review proof — original rust-and-sage Grower and cream-and-teal Mechanic are live with four-direction, four-frame walk cycles, corrected tractor-relative scale, identity labels and foot collisions. Directional idle/run/carry/work actions remain. All 3D character candidates are Rejected as production art. |
| Sheep | Idle, graze, walk, run, turn, panic, contained | Planned |
| Farm dog, if used | Guide, stop, recall; optional until proven necessary | Planned |
| Bees | Hive swarm particles and readable agitation | Planned |
| Small wildlife | Ambient birds/rabbits; cut first if schedule slips | Planned |

## Props and interaction objects

| Asset group | Examples | Status |
|---|---|---|
| Grain and produce containers | Pallets, sacks, crates, bulk bags | Planned |
| Workshop props | Tool cabinet, parts bins, jack, compressor, workbench | Planned |
| Yard props | Barrels, fuel tank, cones, hose, bins, wheelbarrow | Planned |
| Hay assets | Loose hay, small bales, large bales, stacks | Planned |
| Animal care | Feed trough, water trough, hay rack | Planned |
| Apiary | Hives, frames, smoker, suit rack | Planned |
| Delivery | Order board, labels, loading markers | Planned |
| Repair variants | Broken gate, failed machine part, temporary fix | Planned |

## Effects and presentation assets

| Asset/system | Required states | Status |
|---|---|---|
| Clear/overcast/storm sky | Clouds, colour, exposure, transition | Prototype; current lighting insufficient |
| Wind system | Crop, hedge, tree, dust response | Planned |
| Rain | Directional particles, splashes, wet surfaces | Planned |
| Dust/chaff | Field and vehicle feedback | Planned |
| Mud tracks | Vehicle/player decals or terrain mask | Planned |
| Interaction markers | Strong TV-readable shapes and states | Planned |
| Split-screen divider | Attractive farm material motif with clear separation | Prototype |

## Overview composition proposal

| Asset | Status | File |
|---|---|---|
| Cohesive farm overview v1 | Review — concept only, not integrated | `source_assets/2d/concepts/farm-overview-cohesive-v1.png` |
