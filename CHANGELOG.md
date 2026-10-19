# 2026-09-30 — Complete weekend candidate and release preparation

Connected arrival, sheep, planning, repair, weather/crops, buyer/stock dispatch and results/replay. Added assisted solo sample, bounded seed variants, recoverable failures, inventory/drop, clue sharing, pause/reconnect, quick-tap buffering, safe tractor exit/replay, four upright vehicle views/side wheel animation, rain/bell, compact cutaway furnishing and branded launch. Verified nine relay/layout tests, 2D/map/repair/weekend suites, 1000 repeatable seed choices, real relay input (34.2 ms), native visual review and browser quick tap/dashboard/exit at phone size. Exported Web/PCK and signed Fire OS debug candidate. Prepared source archive, provenance and submission/video guide. Fire TV execution, full human pacing test and source/video publication remain pending. Historical root docs archived; current docs now describe actual 2D scope and limitations.

# Project changelog

## 2026-09-30 — Mission clarity and engagement audit

Reviewed eight freshly staged cooperative mission screens/private cards and current native solo route captures. Full solo input route and three-route weekend regressions passed. Added reusable mission capture script and documented ineffective late upgrades, missing confirmation/result feedback, uneven partner workload, automatic field switches and lost private facts. No gameplay or art changed. Human fun/pacing remains unverified; mission-experience fixes are the next implementation priority.

## 2026-09-28 — Upright tractor, dashboard and soil trails

Removed image rotation, added movement-driven suspension bob, tractor-specific phone layout, input gauge and exit transition. Replaced circular work stamps with textured cells. Protected tractor mode from incident UI and restored late-join clues. Four directional sprite candidates generated/tested but withheld from main map pending art approval. Source/relay/export checks pass; authored wheel-spin and boarding animation remain unfinished.


## 2026-09-28 — Start incidents with one phone

Lowered event start threshold to one admitted connected player; corrected admission message. Regression checks first-player start and no timer reset on second-player join. Cooperative completion requirements unchanged.


## 2026-09-28 — Fix missing browser dependencies

Included repair incident in export presets; placed interior limestone inside 2D runtime asset directory. Added actual exported-PCK startup smoke to Web export. Verified fresh browser reaches farm and QR instead of green canvas.


## 2026-09-28 — Split seam and cooperative repair

Replaced geometric divider with clipped timber trim; aligned boots/contact shadows; removed stale sheep cast shadows. Added measured interior cutaways and shared occupancy. Connected sheep outcomes to asymmetric repair with timeout/replay. Added repair regression and two native review views. Export and relevant checks pass; full weekend and hardware verification remain pending.


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


## 2026-09-28 — Cohesive countryside implementation

- Applied the user-approved reference with coordinated source art and optimized reusable textures.
- Replaced hard road polygons with layout-driven blended turf/earth/gravel masks; added softly edged soil, textured moving water, authored verge foliage and estate-edge scenery.
- Thickened continuous boundaries and made mature barley denser while preserving tramlines and machinery access.
- Preserved layered actors/collision/growth. Inspected eight native views and the exported browser lobby.
- 2D host, 468 clearance samples, TypeScript, nine Node tests, relay (11.8 ms), and Web export pass. Hardware performance and final visual approval remain outstanding.


This file records completed implementation and documentation passes. It is not a promise that an item is visually approved; approval status lives in `ASSET_CATALOG.md`.

## 2026-09-28 — Cohesive map visual proposal

- Generated one full-map concept from the user's current overview screenshot after rejection of the strip-like road presentation.
- Proposed organic dirt lanes, blended verges, complete field boundaries and coherent working-yard composition in the same overhead direction.
- Saved source art for review; no runtime or gameplay changes and no production-readiness claim.

## 2026-09-28 — Placement review and route correction

- Consolidated building, prop, tree and boundary placement in layout v5 and removed duplicate coordinates from the world renderer.
- Cleared crop machinery access, orchard paths, apiary visibility, dispatch parking and river crossing approaches; moved yard props into functional groups.
- Added world-aligned textured route polygons, crop exclusions for machinery lanes, continuous water collision, tighter destination labels and full-estate overview framing.
- Added native capture and physics clearance commands. All 468 road samples and ten destination connections pass; 2D host, nine Node tests, typecheck, Web export and relay checks pass.
- Recorded remaining art blockers without declaring production readiness.

## 2026-09-25 — Complete guide-and-gate animal incident

- Added a 1:45 two-player incident in which five escaped sheep must be guided through a pasture gate held open by the other player's sustained phone action.
- Added different FLOCK and GATE private facts, role-specific controller modes, animated flock steering, real boundary/gate rules, television progress/timer UI, world markers, success/failure and replay.
- Suppressed the ordinary pasture destination label while the incident owns that location and restored it after the result.
- Added deterministic start-to-finish incident coverage and updated relay integration assertions for the new private clues and deadline.
- Inspected native shared and split-screen incident views. TypeScript, the 2D host test, all nine arm64 Node tests, Web export and relay integration at 19.9 ms pass; the exported browser reported no warnings or errors.

## 2026-09-25 — Functional production-map completion

- Added an original eight-asset operational sheet and integrated sheep, apiary, grain intake, trailer, dispatch van, produce pallet and repair-parts anchors into their planned districts.
- Added ten data-driven destinations with proximity labels and contextual phone feedback for every committed activity and crossing.
- Replaced flat route ribbons with repeated authored earth/gravel surfaces, moved conflicting dispatch/orchard objects and clamped shared/split cameras to the playable estate.
- Added destination and operational-prop regression coverage; all nine Node tests, the 2D Godot host test, TypeScript, Web export and relay integration pass.
- Inspected five native 1280 × 720 map views and the exported browser lobby/world; the browser reported no warnings or errors.

## 2026-09-25 — Coherent visual-world correction

- Added authored barley lifecycle clusters with denser mature planting, open headlands and two paired tractor tramlines.
- Replaced disconnected hedge/wall fragments with continuous directional modules and visible open gates.
- Added illustrated stone bridge and ford plus six purposeful working-yard prop groups.
- Enlarged workshop/feed-store presentation and raised farmer scale for television readability.
- Corrected road rendering, atlas alpha preservation and runtime extraction; exported and visually reviewed four native 1280 × 720 views.
- Passed TypeScript, 2D Godot, eight Node tests, relay integration and Web export; reopened the browser host with an immediate QR code.

## 2026-09-24 — Coherent playable-map rebuild

- Rebuilt the production layout as topology version 4 around a clear gravel working yard, irregular adjoining districts, yard-edge route terminals and direct pasture, crop/headland, packing and dispatch connections.
- Removed overlapping internal road ribbons and replaced uncovered flat-green seams with the shared meadow texture.
- Generated coordinated hawthorn and drystone 4 × 2 module atlases, added deterministic extraction, and replaced rotated/stretched scattered boundaries with snapped horizontal/vertical runs, tapered openings and matching collision.
- Normalised the visible world scale: farmer sprites now use `0.105`, the tractor `0.30`, and their collisions, shadows and identity markers match those footprints.
- Aligned the six active structures to measured topology footprints while retaining doorway collision, interior reveal, tree occlusion and water crossings.
- Expanded the 2D regression test to enforce actor/vehicle scale, connected operational routes and named snapped boundaries; updated topology tests for the version-4 field route and connected district graph.
- Inspected shared gameplay, overview and forced split views in the exported browser. Asset generation, typecheck, 2D host test, Web export, all eight arm64 unit tests and the two-phone relay integration pass.

## 2026-09-24 — Visual-audit correction pass

- Corrected the full-screen joining flow after a one-phone test exposed that it covered active solo development. The panel now disappears after the first admitted phone, and the 2D host regression test verifies that transition.
- Reduced world and crop texture scale so gravel, flowers, grass and soil read at character scale.
- Rebuilt crop-stage drawing around irregular plant clusters, missing plants, varied height/colour and clear tramline gaps instead of a uniform dot matrix.
- Added paired tyre wear to heavy routes and layered channel, reflection and flow detail to the river.
- Added a deterministic shared soft contact-shadow asset and applied it to buildings, trees and the tractor.
- Corrected boundary-sprite anchoring, reduced player and tractor scale, and gave the two players round and diamond identity markers.
- Replaced the gameplay-covering QR panel with a centred full-screen joining presentation that stays visible until two farmers are admitted.
- Inspected joining, shared gameplay, overview, mature crop and forced split states in the exported browser; no browser warnings or errors were present.
- Passed `npm run test:2d`, `npm run test:characters`, `npm run typecheck`, all eight arm64 unit tests and `npm run export:web`; the Godot relay integration passed at 20.6ms with two-player clues, screen axes and tractor phone mode verified.

## 2026-09-24 — Publishable farm composition and terrain pass

- Reworked the map from scattered test placement into a deliberate working estate: a U-shaped central court, north-side barn/machinery edge, west repair/feed edge, east grain edge, open southern exit and separate packing/dispatch yard.
- Rebuilt the route data so the entrance lane, yard spine, pasture track, combine lane, grain lane and delivery lane form readable logistics chains.
- Replaced isolated boundary pieces with continuous shared hedge and drystone runs, preserving explicit gate openings and machinery clearance.
- Planted the orchard in readable rows, moved willow trees to the river and reduced general vegetation to purposeful estate landmarks and restrained verge clusters.
- Added an original eight-surface terrain atlas and deterministic runtime extraction for pasture, hay, orchard, meadow, gravel, track, rough soil and furrows. The crop system now changes its underlying soil texture with field state.
- Removed debug world labels and the development footer; replaced player-name text with small colour-coded foot markers.
- Inspected close gameplay and full-map views in the exported browser. The rebuilt farm loads without new browser warnings or errors; the 2D host test, typecheck and all eight arm64 tests pass.

## 2026-09-24 — Layered world, crop growth and enterable buildings

- Replaced the flattened farmyard runtime with a 170 × 120 metre layered Godot world built from the measured layout data: irregular districts, final-width roads, stream, bridge, ford, boundaries, structures and world edges.
- Added coordinated reusable 2D production atlases for six structures and eight tree/boundary pieces, plus deterministic transparent runtime cropping through `npm run assets:world2d`.
- Added a barley-field state machine with unprepared soil, prepared furrows, seeded rows, timed seedling/young/mature growth, tramlines, harvested stubble and damage presentation.
- Connected tractor coverage to prepare, seed and harvest transitions while retaining phone entry, tractor controller mode, driving and exit.
- Added solid footprints with door gaps for enterable buildings, roof reveal while inside, tree-trunk collision with canopy reveal, solid hedge/wall bases, passable gates and deliberate water crossings.
- Removed obsolete flattened-world collision/occlusion code and restricted release exports to active 2D scripts and art.
- Inspected the gameplay and overview cameras in the exported browser, including a live seedling state. The latest browser session produced no new warnings or errors. TypeScript typecheck, all eight arm64 unit tests, the expanded 2D host test, Web export and relay integration at 17.9ms pass.

## 2026-09-24 — Layered production-world specification

- Locked the production topology to one connected 170 × 120 metre farm using the measured districts, gates, roads and vehicle envelopes in `world_layout.json`.
- Mapped the complete hackathon activity set onto the farm: sheep/gate, barley/weather, repair/parts, orchard/apiary, packing/loading and final dispatch.
- Defined the runtime layer stack for terrain, field states, low objects, interactive objects, Y-sorted actors, foreground occlusion, weather and UI.
- Defined reusable tree, building, hedge, wall, gate and field construction so feet and vehicles collide with functional footprints while crowns, roofs and tall foliage correctly cover characters walking behind them.
- Added `docs/2D_WORLD_PRODUCTION_PLAN.md` with dimensions, camera/travel targets, quest geography, staged production and acceptance tests.
- Added the reproducible `npm run map:plan` command and inspected the generated `docs/maps/brackenridge-production-map.svg` planning diagram.
- Corrected stale plan text that still described a 120 × 80 metre all-in-one-camera low-poly presentation.

## 2026-09-24 — Directional walking, scale, collision and occlusion

- Replaced both single-pose farmers with original 4 × 4 transparent walk atlases containing down, left, right and up four-frame stride cycles.
- Extended `npm run assets:2d` to normalize the full-resolution generated sheets into deterministic 256px runtime cells.
- Replaced coordinate teleporting and procedural bobbing with `CharacterBody2D` velocity, `move_and_slide`, directional animation selection and stable idle frames.
- Corrected the on-screen relationship between farmers and tractor, added small foot collisions, and retained phone-controlled tractor entry and driving.
- Added first-pass solid collision for the barn, machinery shed, two large trees and stream, plus y-sorted textured foreground masks for the barn, shed, courtyard oak and west wall.
- Added `WASD` and arrow-key laptop controls for fast visual testing while retaining phone input and direct screen axes.
- Inspected the exported browser host at gameplay scale during a visible right-walk stride; the console reported no warnings or errors. TypeScript typecheck, all eight arm64 tests, the expanded 2D host test, Web export and relay integration at 17.7ms pass.

## 2026-09-23 — Playable 2D conversion proof

- Replaced the default 3D host presentation with an original illustrated top-down three-quarter 2D farmyard while retaining the existing WebSocket room, QR, admission and private-clue flow.
- Added two distinct transparent farmer sprites and a matching transparent red tractor, with procedural idle/walk movement, facing, identity labels and working tractor entry, driving, rotation and exit.
- Rebuilt adaptive shared and split cameras for `World2D`, retained merge/split hysteresis and added a farm-themed hedge-and-stone divider.
- Changed phone movement to direct 2D screen axes and updated the relay integration assertion accordingly.
- Added reproducible runtime character cropping through `npm run assets:2d`, a dedicated 2D host visual test and a full prompt/file production record in `docs/2D_ART_PRODUCTION.md`.
- Limited Web and Fire OS exports to the active scene and four 2D runtime images, reducing the Web PCK from approximately 53 MB to 2.9 MB.
- Visually inspected the exported browser host in shared and forced-split views, corrected the root canvas layer that initially hid the SubViewport composition, and confirmed no browser warnings or errors. TypeScript typecheck, all eight arm64 unit tests, the 2D host visual test, Web export and relay integration at 15.5ms pass.

## 2026-09-23 — Pip Puddleboots replacement character direction

- Recorded the user's rejection of the Grower, Mechanic and Milo source-body direction and removed those candidates from the active `P` review.
- Verified that the free Quaternius Standard character package contains the Superhero bases rather than the paid Regular or Teen models; retained only the CC0 skeleton and compatible animation libraries.
- Authored Pip Puddleboots' complete visible character from new geometry: expressive head and face, hair and cap, loose yellow raincoat, red scarf, teal patched trousers, hands and oversized red Wellington boots.
- Added a reusable Pip scene, updated the isolated review to cycle idle, walk, interact, harvest and dance, and extended the skeletal regression test to cover all four retained rig files.
- Corrected detached hair/cap transforms and the opening orientation during live browser inspection. The final moving review keeps the costume attached and reports no browser warnings or errors.
- Passed generator Python compilation, TypeScript typecheck, all eight arm64 unit tests, the four-rig skeletal test, browser export and Godot relay integration at 24.0ms.

## 2026-09-23 — Local mesh reshape after proportion rejection

- Recorded the user's rejection of the previous whole-scale correction: the source superhero chest, shoulders and limbs still looked essentially unchanged.
- Added bone-aware local mesh reshaping before clothing generation, reducing chest and limb volume differently for each role while retaining the compatible skeleton and animations.
- Strengthened the distinct silhouettes: visibly lean Grower, medium Mechanic and compact Milo with a subtle soft middle.
- Rebuilt, imported, exported and visually inspected the three characters in still and animated `P` review phases; clothing and accessories remain attached.
- Passed Python compilation, TypeScript typecheck, all eight arm64 unit tests, the three-character skeletal test, browser export and Godot relay integration at 14.6ms.

## 2026-09-23 — Natural farmer body proportions

- Rebuilt all three character candidates with distinct ordinary working builds instead of uniformly broad superhero proportions: tall/wiry Grower, average Mechanic and shorter Milo.
- Removed Milo's separate widening override so his comedy now comes from his hat, face, colours and dance.
- Applied proportions at the common rig root, preserving skeleton, garment and prop alignment across the full animation library.
- Visually inspected the rebuilt browser `P` review in still and animated phases. TypeScript typecheck, all eight arm64 unit tests, the three-character skeletal test, browser export and Godot relay integration at 21.5ms passed.

## 2026-09-23 — Milo Mudboots kid-friendly character candidate

- Added Milo Mudboots, an original shorter and wider comic farmhand with teal overalls, red boots, a mustard shirt, oversized flowered yellow hat, round glasses, rosy nose, curled ginger moustache and tool pouch.
- Reused the retained Quaternius CC0 rig and skeletal animation pipeline, added the compatible `Dance` clip, and exposed it through the shared runtime action mapping.
- Added a reusable Milo scene and placed him only in the isolated `P` review beside the Grower and Mechanic; his eventual player or guide role remains open pending user approval.
- Expanded the deterministic character test to cover all three rigs and verify Milo's dance selection.
- Inspected the exported browser review through the dance phase with no console warnings or errors. TypeScript typecheck, all eight arm64 unit tests, the character test, browser export and Godot relay integration at 24.8ms passed.

## 2026-09-23 — CC0 rigged character replacement

- Downloaded the Standard Quaternius Universal Base Characters and Universal Animation Library 1/2 packages and retained their CC0 1.0 licence files with the selected source assets.
- Replaced the rejected primitive-pivot models in the isolated `P` review with customised skinned Grower and Mechanic candidates.
- Added original farm clothing and accessories, screen-aligned skeletal locomotion, interaction and farm-action runtime selection, and fourteen imported animation clips.
- Corrected missing clothing, garment holes, accessory attachment and reversed-facing defects found during successive close browser reviews.
- Reduced the two GLBs from roughly 33 MB to 8.4 MB combined and the web pack from 73 MB to 47 MB by using 1024px gameplay textures and removing unused maps.
- Replaced the pivot test with a skeletal test covering skeleton/mesh structure, required clips, animation advancement, turning and repair-action selection.
- Passed TypeScript typecheck, all eight unit tests, the skeletal character test, browser export and Godot relay integration at 12.9ms. The candidates remain in review until user approval.

## 2026-09-23 — Two-phone validation and player-character review

- Recorded the user's successful two-phone test of joining, control and the current cooperative build.
- Created original Grower and Mechanic character models with distinct silhouettes, colours, clothing, tools and identity symbols.
- Added reusable Godot character scenes with idle breathing, screen-aligned turning, walking motion, an interaction gesture and a carry-pose hook.
- Added an isolated animated character review reached with `P` and a standalone preview at `docs/previews/bracken-player-characters.png`.
- Kept the candidates outside live play until visual approval, preserving the asset review workflow.
- Added a deterministic Godot character test covering imported pivots, turn direction, walk motion and interaction motion.
- Passed TypeScript typecheck, all eight unit tests, the character test, browser export and Godot relay integration at 25.1ms; the live browser review reported no warnings or errors.

## 2026-09-22 — First asymmetric cooperative loop

- Added the five-minute `Rain Before Barley` sequence for two admitted phones.
- Sent private weather information to player one and a one-trip tractor route constraint to player two.
- Added a cooperative held-gate step, two tractor tramline checkpoints, objective/progress/timer UI and world-space task markers.
- Added protected and damaged barley outcomes, storm failure presentation and pause-on-disconnect behavior.
- Extended the Godot relay integration check to verify two-player private clues alongside movement axes and tractor controller mode.
- Corrected a web-only GDScript inferred-type failure found during browser inspection.
- Passed TypeScript typecheck, all eight unit tests, browser export and Godot integration at 15.6ms; visually inspected the corrected web build and objective HUD.

## 2026-09-22 — Authored workshop, feed store and roof correction

- Created original painted repair-workshop and feed-store assets using the established storybook limestone, timber, slate, sage and warm-red material family.
- Added reusable Godot building scenes with collision that preserves the operational entrances, plus an isolated `U` review with `1`–`2` asset switching.
- Replaced the two remaining cube buildings in the central farmyard with the authored candidates.
- Removed the obsolete primitive produce canopy that intersected the authored grain store and caused the apparent roof defect.
- Reduced and darkened roof divisions on the grain store and new buildings so roofs read as broad slate courses or standing seams at the gameplay camera.
- Regenerated the Blender previews, exported the browser build and visually inspected the workshop, feed store, farmyard composition and corrected grain-store roof.

## 2026-09-22 — Grain chain, field states and tractor interaction

- Generated original painted connected silos, combine and grain trailer assets with named animation pivots and a shared review render.
- Installed the grain store on a straight-through southern loading route and replaced the primitive silo, combine and trailer in the playable map.
- Replaced oversized crop bars with a batched irregular barley-field system supporting seven states, headlands and paired tramline gaps.
- Added subtle shared terrain-surface variation while retaining the existing irregular connected parcels.
- Added phone tractor entry, driving and exit, including controller-mode messages and private tractor information.
- Added relay coverage for controller-mode packets and stabilized the Godot direction test across idle/physics-frame boundaries.
- Inspected close, split and whole-map browser views; passed TypeScript typecheck, all eight tests, browser export and the Godot relay integration at 33.3ms. The final relay run also verifies tractor phone mode.

## 2026-09-16 — Grain store and drive-over intake review candidate

- Created an original painted grain-store complex with an enclosed hall and a separate straight-through intake canopy.
- Added a five-by-seven-metre unloading grate, safety frame, raised hall door, visible grain, transfer auger, fill indicators, lights and working props.
- Preserved 8.9 metres between the outer canopy columns and 6.5 metres of vertical clearance for tractor-and-trailer access.
- Consolidated repeated meshes by material and added collisions around the closed walls and canopy posts while leaving both operational openings clear.
- Added an isolated Godot review reached with `G`, plus an authored Blender preview at `docs/previews/bracken-grain-store.png`.
- Imported, browser-exported and visually inspected the asset in Godot; it remains outside the playable map pending user approval.
- Passed TypeScript typechecking, all eight unit tests and the sequential Godot relay check at 44.2ms with both screen axes verified.

## 2026-09-16 — Modular boundary-kit review candidates

- Created five reusable painted hawthorn modules: straight, curve, corner, tapered end and a gated opening.
- Created five reusable drystone-wall modules with the same routing variants, irregular courses, capstones, moss pockets, stone piers and a timber gate.
- Created an authored oak courtyard base with irregular soil, edging stones, grass and flowers.
- Consolidated repeated geometry by material to reduce draw calls while retaining separate gate pivots.
- Added a `K` review scene; keys `1`–`3` show the hedge, wall and oak-base candidates at gameplay scale.
- Imported, browser-exported and visually inspected all three review modes. The candidates remain outside the playable map pending user approval.

## 2026-09-16 — Boundary kit integrated into the playable farm

- Replaced the full-map box-and-sphere hedge generator with connected, painted eight-metre hawthorn modules along the irregular field polygons.
- Replaced the hidden decorative wall row with a visible connected drystone boundary at the west yard and aligned its open gate to the real road crossing.
- Replaced the primitive box-built oak ring with the authored soil, stone, grass and flower base.
- Removed floating gate-and-hedge fragments caused by the old approximate logistics markers; the combine crossing remains a clear ten-metre opening until a dedicated wide gate is authored.
- Exported and inspected the whole-farm and close farmyard views; the browser reported no warnings or errors.
- Passed TypeScript typechecking, all eight tests and the Godot relay check at 17.7 ms with screen axes verified.

## 2026-09-16 — Small-environment placement audit

- Inspected the normal farm camera and the isolated oak, hawthorn and drystone-wall reviews.
- Recorded that the wall is largely hidden, authored hedges are disconnected, procedural sphere-chain hedges dominate the map, and the oak base remains primitive.
- Moved the small environment kit ahead of the next building in the recommended production order.
- Corrected stale review labels that incorrectly said the already integrated assets were outside the playable map.

## 2026-09-15 — Storybook assets integrated into the playable farm

- Placed the painted machinery shed on the east yard and restored the painted stone barn to the north yard.
- Restored the painted red tractor to the central yard and moved the greybox combine away from the shed footprint.
- Placed the mature oak, four flowering hawthorn segments and five drystone wall segments in the actual map.
- Exported and visually inspected the normal farm view in the browser; all six authored assets load and the browser reports no warnings or errors.
- Kept the `H` and `J` isolated review routes for close asset inspection.

## 2026-09-15 — Existing asset storybook conversion

- Generated two original source atlases for painted heritage machinery and countryside nature materials.
- Added eight optimized 512px materials: red enamel, slate, farm steel, tractor rubber, oak bark, oak foliage, flowering hawthorn and drystone.
- Revised the stone barn and red tractor with shared hand-painted materials.
- Rebuilt the mature oak, hawthorn segment and drystone wall with more expressive continuous silhouettes and painted surfaces.
- Added five individual previews, a six-asset contact sheet and an isolated Godot review reached with `J`; keys `1`–`5` switch assets.
- Initially kept the revised candidates outside the playable farm for isolated review; they were integrated in the following pass at the user's request.
- Imported and inspected the assets in Godot, exported the browser build, passed typechecking, all eight unit tests and the Godot relay integration at 23.8ms frame acknowledgement.

## 2026-09-15 — Hand-painted storybook asset benchmark

- Generated an original four-part painted atlas for limestone, chestnut timber, sage metal and cream concrete using the built-in image-generation workflow.
- Saved the source atlas under `source_assets/` and created four optimised 512px runtime textures under `game/assets/textures/machinery_shed/`.
- Applied the painted materials to the actual 3D shed and added a round gable window, heavier rounded framing, cream fascia and ridge vent.
- Enlarged the isolated review framing, regenerated and imported the GLB, exported the browser build and inspected the live `H` view.
- Passed TypeScript typechecking and the Godot relay integration check; the latter measured a 26.7ms frame acknowledgement.
- Kept the asset in `Review` and outside the playable map.

## 2026-09-15 — Warm storybook machinery-shed variant

- Restyled only the machinery shed to test the family-oriented art direction.
- Replaced dark industrial colours with mint/sage roofing, cream trim, forest-green rounded frames, warm chestnut timber and honey limestone.
- Brightened the preview lighting and added colourful barrels and parts crates alongside the existing workshop details.
- Regenerated the GLB and preview, reimported it into Godot, exported the browser build and inspected the live isolated `H` view.
- Kept the asset in `Review` and outside the playable map.

## 2026-09-15 — Machinery shed review candidate

- Created a standalone 24 × 11.5 metre authored machinery shed with three open machine bays and an enclosed parts room.
- Added steel portal framing, timber cladding, limestone plinth, corrugated roof and daylight strips, drainage, work lights, workshop props and collision geometry.
- Added an isolated in-engine review stage with the red tractor as a scale reference; `H` opens it without placing the shed in the playable map.
- Corrected floating roof purlins and a shadow volume that initially blocked the bays.
- Generated and inspected the standalone preview, exported the browser build, passed TypeScript typechecking and all eight unit tests.
- Set the asset status to `Review`; user approval is still required before map integration.

## 2026-09-15 — Persistent project direction

- Added root instructions requiring future chats to read and maintain the project documents.
- Recorded the game concept, committed scope, camera, phone asymmetry, farming-system direction, and exclusions.
- Established the stone barn and red tractor as the current minimum visual quality references.
- Marked the oak, hedge, drystone-wall, silo, terrain dressing, and surrounding primitive buildings as rejected prototypes.
- Added the complete asset catalogue and ordered production queue.
- Recorded current engineering state, limitations, next task, and verified commands.

## 2026-09-15 — Farmyard environment prototype

- Added experimental oak, hawthorn hedge, drystone wall, puddles, ground dressing, and clear/overcast lighting.
- Added farmyard and lighting preview shortcuts.
- Exported updated browser and Fire OS builds and ran the available automated checks.
- Visual review found that this environment pass did not meet the barn-and-tractor quality bar.

## 2026-09-15 — Authored asset benchmarks

- Added an original red tractor with separate animation pivots.
- Added an original stone barn asset and close review views.
- User identified these as the only current assets close to the intended visual direction.

## 2026-09-15 — Platform and world foundation

- Added QR/room-code phone joining through a Node.js WebSocket relay.
- Added independent phone movement, latency reporting, host admission, and relay discovery.
- Added browser and signed Fire OS debug export routes.
- Added the irregular English countryside logistics greybox, camera-aligned movement, shared camera, and adaptive split screen.

## 2026-09-30 — full solo test weekend

- Replaced the short solo sample with normal deadlines and the complete crop lifecycle; retained second-farmer assistance. Added solo-specific planning, repair and delivery wording.
- Preserved tractor dashboard/EXIT when mission clues change. Fixed right-edge objective-panel overflow and duplicate repair labels found during rendered solo review.
- Added a full solo regression using actual physics motors and natural crop transitions, including sheep, repair, harvest/storage, apple covering, packing, results and replay. Final human multiplayer and TV checks remain deferred.

## 2026-09-30 — host input route and solo reconnect

- Full solo regression now uses received input packets and normal host ticks, including buffered quick ACTION/EXIT taps.
- Losing the only solo phone pauses missions and crops; reconnect restores play without cancelling an earlier manual pause. Replay resets disconnect bookkeeping.
- Added disconnect/resume/manual-pause assertions to the complete route.

## 2026-09-30 — crop progression guidance

- TV and grower phone now explain the actual crop step: cultivate, sow, grow, harvest, exit/store, cover apples. Cell progress/growth countdown and objective markers follow the state.
- Kept the partner's private storage clue separate and preserved tractor dashboard/EXIT on entry.
- Added guidance/privacy assertions and a startup failure guard to the solo/weekend tests; corrected an initially found GDScript type-inference error.

## 2026-09-30 — audit and seeded repair faults

- Seed variants now choose a belt/slipping-drive or gasket/leaking-pump fault using existing supplies and repair mechanics. Diagnosis stays private to the mechanic in co-op; solo has helper wording.
- Verified both correct parts, rejection of wrong parts, private diagnosis, complete solo/weekend routes and original repair regression. Reviewed staged native instructions for both variants.
- Corrected stale short-sample/startup wording in plan/submission documents.

## 2026-09-30 — clean source handoff

- Prepared an isolated Git snapshot from the curated source archive; SDK/caches/environment/signing keys remain excluded.
- Verified GitHub authentication and that the proposed repository does not exist; credential-pattern scan of 122 text files found no matches.
- Added source-handoff/publication instructions. User visibility decision, remote creation and push are pending.

## 2026-09-30 — mission clarity and participation pass

Replaced ineffective late purchases with delivery briefing; added purchase confirmation/result beats, gate-opening windows, marked crop work/tool handoffs, storage sealing/crate preparation, persistent phone facts and task-based recognition. Repair/crate outcomes affect delivery duration and care successes affect rewards. Full solo input route, cooperative scripted routes and new mission checks pass; native/browser review and refreshed Web/Fire OS packaging verified. Human pacing/fun and physical TV acceptance remain open. Updated affected direction, catalogue, audit, command and state documents.

## 2026-09-30 — sheep personality and motion

Added seeded staggered fence jumps, bounded rushed-approach evasion, simulation-driven leg-pair animation from existing art and grounded hop shadows. Safely returned sheep retain progress. Full solo and three scripted co-op routes pass; focused motion/replay test and native frame review pass. No new raster asset, incident type or human/TV acceptance claim.

## 2026-09-30 — active co-op repair

Mechanic inspection now reveals the private fault; pressure pumping/cooling replaces continuous joint holding. Runner fitting advances only with both nearby and green pressure; mistakes pause rather than erase progress. Added instrument UI and playful feedback, retained solo helper and maintenance benefit, clarified arrival guidance. Solo/co-op scripted routes, repair/mission regressions and native gauge review pass; human fun and TV acceptance remain open.

## 2026-09-30 — adaptive minimap

Added layout-derived schematic chart with farmers and public task targets. Bottom-centre in split view, bottom-right when shared; hides for QR/results and respects solo. Checked camera-layout changes, privacy, van targeting and small-window logical bounds; inspected native shared/split/merge captures and adjusted legend spacing. World simulation/art unchanged; TV/human acceptance remains pending.

## 2026-10-05 — APK game-resource startup gate

Added APK CRC/extracted-resource startup verification to Fire OS export, plus a negative check proving a missing dynamic minimap script is rejected. Existing/refreshed APK resources booted with desktop Godot (257 resources); export, syntax and v2/v3 signature checks passed. Minimap regression passed. Release manifest date now follows packaging time. No connected Fire TV; native Android execution and human cooperative acceptance remain unverified.

## 2026-10-05 — Full cooperative physics route and transition action fix

Added two-slot packet/motor weekend verification without solo helpers or teleporting actors/crop states. The route caught ACTION falling through to tractor boarding during result messages; context actions now pause through those transitions. Seed 1731 passed headless/native with all four jobs, joint delivery, results/replay; solo/mission/2D regressions passed. Inspected actual rendered route, refreshed Web/APK and verified startup/signatures. Human fun and TV acceptance remain pending.

Final variant checks: complete input/physics routes for seeds 1732 and 1733 also passed (358.9 simulated seconds each), covering all three bounded weekend variants. This remains automated evidence, not a human playtest.

# 2026-10-05 — Supported TV inspection investigation

Verified adaptive minimap regression and inspected split gameplay evidence; no runtime changes. Established official local Appium/Kepler/Inspector tools and corrected unsupported VVD framebuffer instructions. Session/window/source access succeeded after a confirmed stopped-component relaunch; captured view was black and subsequent refresh pending. Recorded limitations and next loading/rendering diagnostic in state/commands/platform/audit docs. No TV acceptance or submission-ready claim.

Source packager retains the diagnostic evidence folder. Python syntax, 761-file ZIP CRC/freshness/exclusion checks and four artifact manifest hashes passed.

# 2026-10-05 — Instrumented TV startup and readable failures

Added scoped canvas/startup/context diagnostics and friendly native loading/connection/error text to the Vega wrapper. Actual debug runtime reached visible ready 1280×720 canvas after approximately ten seconds; native debug strip inspected, farm capture still flat-coloured. Three tests/two suites, lint, TypeScript and Debug/Release builds passed after correcting template mocks and SDK-compatible test execution. Refreshed aarch64 release candidate; game simulation/art/browser/APK unchanged. Device graphics/input/performance/audio/replay and human acceptance remain open.

Late context recovery is now sampled immediately even after the 45-second polling window ends, so a restored context clears the native failure text. The actual injected-code regression covers this; final three tests, lint and TypeScript passed. Earlier ready-strip inspection remains valid startup evidence; late recovery was regression-tested rather than induced on the simulator.

Final late-recovery builds: Debug and Release completed successfully for aarch64, armv7 and x86_64. The retained aarch64 release candidate includes the recovery fix. Source handoff is refreshed with current diagnostics, tests and scoped inspection evidence; this remains a candidate, not a completed TV acceptance pass.

## 2026-10-05 — source handoff refresh

Refreshed the isolated submission Git snapshot to the current 765-file candidate, including current cooperative tests, minimap and TV diagnostics. Checked archive integrity, snapshot byte equality and artifact hashes; no publication performed. External acceptance remains pending.

Snapshot verification also caught the general `*.log` ignore excluding the sanitized startup evidence from Git. Added a specific exception for that retained evidence; unrelated logs remain ignored. Archive/snapshot comparison passed for 765 files, four manifest hashes matched, and a credential-pattern scan passed for 137 text files (a scoped scan, not a universal secrets guarantee). The local checkout has no remote.

The same exact-file exception also retains the earlier path/status-only `vega-startup-http.log`; inspected content contains local LAN URLs and HTTP statuses, with no queries or phone tokens. Both retained log files are part of the 765-file snapshot.

## 2026-10-15 — laptop mission navigation and replay completion

Added private-fact-safe per-player task cards/offscreen direction pointers; phone room badge and results/replay voting, cancellation and disconnected-player consent reset. Froze actors at results and centred the expanded report after a failed native bounds check. Added focused finishing tests and a labelled isolated phone-results fixture. Solo/co-op motor routes, mission/map/repair/sheep/minimap/relay checks passed; refreshed native and browser review evidence. Updated welcome assertion in the relay→Godot test. Fire TV and human playtesting remain final deferred acceptance. Export/package final results are recorded in PROJECT_STATE.

October 15 admission clarity: a connected pending phone now explicitly says to press Enter/Select on the host; the host roster shows waiting phones and the same admission action. Admission authority is unchanged. The hint hides after admission. The finishing regression checks the host prompt. Final exports/package are refreshed after this change.

## 2026-10-19 — public source publication preparation

User authorized public GitHub publication. Created the repository, verified current curated source and scoped credential exclusions, and prepared judge-facing README/build-download instructions. No gameplay/art change; runtime/human acceptance is unchanged. Commit, push and release verification are recorded in PROJECT_STATE.

October 19 publication result: source pushed to public main and candidate prerelease published with Web/Fire OS/Vega downloads and checksums. Remote commit and all four asset digests verified. GitHub supplies source archives; no live backend, video or Devpost entry was deployed.

Post-publication check: GitHub reported 16 open dependency alerts, all in the Vega wrapper lockfile, including two critical handlebars findings. Recorded scope without force-upgrading the SDK or changing gameplay; remediation requires compatibility testing.

## 2026-10-19 — Vega dependency remediation

Patched 14 reported dependency findings with CLI 20.2.0 and scoped overrides, including both critical Handlebars alerts. Rebuilt Debug/Release for all three architectures after clean installation, lint, TypeScript and three tests passed. Preserved two unpatched upstream alerts (braces/sprintf-js), documented npm's propagated counts and updated the candidate wrapper/source/checksums. Game art and gameplay remain unchanged; human/TV tests remain outstanding.
