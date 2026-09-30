# Current project state

## 2026-09-28 — Tractor presentation and phone dashboard

Live fixes: tractor no longer rotates its entire picture; existing art stays upright and mirrors for left/right. Suspension bob uses actual movement, stopping against walls. Phone TRACTOR mode now has steering-style directional drag, a live input-strength gauge, parked/driving input state and separate exit. Exit restores walking controls and role clue. Incident mode updates cannot overwrite tractor controls. Late joiners receive latest role clues. Field work stamps use contiguous, field-clipped soil texture cells instead of tan circles.

Generated matching four-direction tractor views with built-in imagegen. Source source_assets/2d/production/tractor-directions.png; runtime tractor_{down,up,left,right}.png. These remain Prototype pending explicit user approval per AGENTS.md. Main tractor_directional_approved remains false; only labelled test_tractor_review enables candidates. Do not claim new views are live. No authored wheel-spin/driver-entry animation yet; movement has subtle suspension bob, no vehicle physics simulation.

Verified 2D host suite, four-direction upright assertions/native captures, TypeScript, controller build, relay regression (19.9ms) and exported-pack smoke. Mobile controller inspected at 390x780 with no horizontal overflow; EXIT restored walking UI. Evidence docs/audits/2026-09-28-cohesive/tractor-*.png and tractor-controller.png. Browser preview fixture closed; physical phone/Fire TV not retested.
Next task: obtain approval for directional tractor sheet, then enable on main map and verify all four directions plus parked initial sprite.


## 2026-09-28 — One-phone event testing

First admitted connected phone now starts the sheep event; subsequent repair transition remains automatic. Second phone joining does not restart the timer. Admission message no longer claims two phones are required. This enables event testing, not solo completion: cooperative gate/repair requirements and private roles remain unchanged.

Verified with 2D host regression including first-phone start and second-phone no-reset. Next task: weather/crop stage and final dispatch; full solo assistance is not implemented.


## 2026-09-28 — Browser green-screen startup fixed

Reproduced on fresh browser reload: exported pack omitted RepairIncident2D. Export-pack smoke additionally found missing interior limestone texture. Added repair script to both export presets and moved limestone runtime copy under assets/2d/production. Web export now boots its actual PCK headlessly and fails on script/load errors, since source-tree tests did not catch missing packaged dependencies.

Verification: export and exported-pack startup passed; fresh browser reload visibly reached farm/QR lobby (room B6S7T4), screenshot docs/audits/2026-09-28-cohesive/browser-startup-fixed.png. No new browser errors after corrected load; previous errors remain in log history. Fire OS preset updated but APK/hardware not tested. Previous claim of working browser export was incomplete: export success alone did not establish startup.
Next task: implement weather/crop stage, preserving exported-pack smoke and real browser startup verification.


## 2026-09-28 — Divider, cutaway interiors and cooperative repair

Replaced diamond/bar divider with a clipped 10px timber seam and cream trim. Aligned each walking frame at the boots and strengthened farmer contact shadows. Excluded moving sheep from static shadow baking. Building reveals now show timber floors and masonry boundaries sized from collision dimensions with doorway gaps, tracking both occupants. Interiors remain unfurnished cutaways, not bespoke finished rooms.

Added RepairIncident2D eight seconds after either sheep outcome: mechanic privately knows the required belt; runner knows store locations. Inspect repair bay, fetch belt from feed-store supplies (workshop holds wrong gasket), deliver, then both hold ACTION within 5m for six seconds. Deadline 180 seconds, wrong-part feedback, failure and R replay implemented.

Verification: native split/interior/repair views inspected in docs/audits/2026-09-28-cohesive/gameplay-*.png. Fixed divider minimum-size overflow found during review. 2D host, repair lifecycle/two-occupant interior, 468 clearance samples, TypeScript, nine Node tests and Web export pass. Node tests use documented ARM runtime; default x64 failed esbuild startup. Physical two-phone acceptance and Fire TV performance remain unverified.

Remaining: interior furnishing, carry/repair animations, weather/crop event, final dispatch and complete 12–15 minute weekend. This is a two-event development loop, not the finished game.
Next task: implement asymmetric weather/crop stage and connect its outcome to final dispatch.


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


Last updated: 2026-09-28

## Latest implementation — 2026-09-28 cohesive countryside

User approved the cohesive overview concept and requested its application. The runtime now has a coordinated ground layer: fine olive grass, warm worn earth lanes, gravel yard blending into roads, softened crop edges, and textured animated water. New coordinated hedge/wall modules, shoulder flowers, reeds and shrubs replace the disconnected verge treatment. Peripheral vegetation extends the estate beyond the playable fence. Buildings, actors, crop states, collisions and interaction points remain separate.

Source images: `source_assets/2d/production/cohesive_terrain_atlas.png`, `cohesive_verges_atlas.png`, `cohesive_grass_source.png`. Build with `npm run assets:cohesive`. The mask is generated from layout data; roads retain their tested collision clearance but use narrower visible dirt with grassy shoulders.

Verification: 2D host test passed, 468 map clearance samples passed, TypeScript passed, all nine Node tests passed, relay integration passed (11.8 ms acknowledgement), Web export passed. Inspected eight native views under `docs/audits/2026-09-28-cohesive/final-*.png`; exported browser reload visibly reached the new terrain and QR lobby. No physical phone or Fire TV performance test this pass.

This is a playable translation of the approved composition, not a pixel-identical recreation or production certification. Existing building sprite edge speckles, repetitive trees, gate-state artwork and absent work animations still need polish. The mature overview is a deliberately advanced growth review; normal play starts with unprepared soil.

## Current milestone

Placement-reviewed map baseline with a complete asymmetric incident running on the `170 × 120 metre` production map. Two phones now receive different private facts and must coordinate a moving flock with a physically held pasture gate. The complete 12–15 minute cooperative weekend remains unfinished.

## What currently works

- QR/room-code joining, one- or two-phone play, private clues and measured frame acknowledgement.
- Shared close camera, adaptive split screen and development overview.
- One consistent `10 pixels per metre` world standard: farmer sprites are about 2.5 metres visually, the tractor about 5–6 metres, and building/route footprints use the same scale.
- A clean central yard with barn and machinery shed north, workshop/feed store west, silos east and an open southern route to packing and dispatch.
- Routes terminate at the yard edge instead of layering into a central road star. The entrance, pasture, field/headland and dispatch paths connect the activity districts while the gravel yard remains freely driveable.
- Irregular adjoining pasture, barley, meadow, orchard, loading, paddock and delivery districts over a textured countryside base; uncovered seams no longer become flat green holes.
- Continuous grid-snapped hawthorn and drystone boundary runs with authored horizontal/vertical modules and visible open gates aligned to crop, pasture and yard routes. Collision uses the same measured runs.
- Enterable barn, machinery shed, workshop and feed store with doorway gaps and roof/foreground reveal; closed silos; passable packing canopy.
- Tree trunk collision and canopy reveal, stream collision with bridge/ford gaps, world-edge collision and screen-axis movement.
- Four-direction animated farmers, tractor entry/drive/exit, and a complete barley lifecycle using authored seed/plant/stubble sprites from unprepared soil through preparation, sowing, timed growth, paired tramlines, harvest and damage.
- Illustrated stone bridge and shallow ford, plus barn hay, livestock water, workshop tools, feed supplies, packing produce and destination-sign work zones.
- Five simulated sheep escape into the meadow, respond to a nearby herder, respect the closed pasture boundary and return only through the held gate. The 1:45 incident has private FLOCK/GATE clues, role-specific phone modes, television HUD, world markers, success/failure and `R` replay.
- Operational staging for apiary hives, grain intake grate, farm trailer, spare-parts crate, produce pallet and dispatch van. These remain separate named world actors ready for later incident logic rather than decoration baked into the terrain.
- Ten contextual destinations cover animal care, repairs, grain intake, crop and pasture gates, apiary, packing, dispatch, bridge and ford. Approaching one reveals a TV-readable label; the phone action reports that place's current gameplay purpose.
- Camera clamping keeps shared and split views inside the playable estate at edge destinations. The dark countryside surround replaces exposed grey canvas in the development overview.
- Developer review keys: `M` overview, `T` forced split, `C` crop cycle, `R` animal-incident replay, `WASD`/arrows movement and `1`/`2` admission.

## Integrated authored art

- Coordinated production atlases supply six structures, four tree types, eight terrain surfaces, eight crop-state clusters, continuous hedge/wall/gate modules and eight infrastructure/yard props.
- Full-resolution sources live under `source_assets/2d/production/`; optimized runtime images live under `game/assets/2d/production/`.
- The farmer walk sheets and rotatable tractor remain integrated review proofs under `prototype/`; they need final idle/work/directional production art.

## Known limitations

- Dirt routes now use softly masked earth and gravel with subtle tyre wear. Dedicated wet/muddy variants remain future weather polish.
- Boundary corners are laid out coherently but the new generated module art remains a review candidate until user visual approval.
- Characters need idle, carry and role-specific work animation; the tractor needs four/eight directional views.
- Weather, wetness, mud, grain fill/unload, attachments and combine driving are not implemented. The animal gate has incident state and a held-open rule, but no authored opening animation yet.
- The guide-and-gate incident is complete as a first gameplay pass. Its sheep steering and 1:45 pacing need a real two-phone playtest and tuning; audio, wind presentation and the other three incident families remain unfinished.
- Fire TV performance is not verified on qualifying hardware.

## Immediate next task

Run a physical two-phone playtest of the new terrain and complete animal incident, checking close-camera readability, vehicle travel, split-screen performance and incident pacing before expanding content.

## Verification state

Placement audit and correction on 2026-09-28:

- Reviewed fresh native gameplay captures and found a tree planted in the crop, hidden apiary, shed/field-route crowding, a van on the dispatch lane, disconnected crossing approaches and separate code/data placement coordinates.
- Layout v5 now owns building dimensions/positions, all 17 operational props, 15 trees and 14 boundary runs. Runtime loads these placements directly. Moved the shed/workshop, tree rows, trough, trailer, crates and van into purposeful working locations.
- Rebuilt routes with shared world texture coordinates, cleared the field entrance, made the machinery headland visible above field soil, and reserved that corridor from planting and field work. Added orchard exit, bridge approach/gap and ford approach. Water collision is continuous except at the two crossings.
- Reduced proximity-label range and fixed the overview zoom so the complete footprint is visible.
- `npm run test:map`: 468 sampled road positions clear at walker/tractor/combine widths; all ten destinations free of collision and reachable from the yard by a flood of actual physics space. `npm run test:2d`, typecheck, all nine arm64 Node tests, Web export and map-plan generation passed. Relay integration passed at 30.4 ms.
- Inspected seven native views: yard, pasture, orchard, dispatch, overview, mature crop and bridge/apiary split. Before/after evidence and remaining art limitations are in `docs/audits/2026-09-28-placement/REVIEW.md`.
- The updated Web build was opened in the in-app browser and the farm and QR joining panel rendered successfully.
- This is a placement correction, not final art approval or Fire TV performance certification. Visible texture seams, repetitive boundary modules, unanimated gate artwork and simplified water still prevent a production-ready claim.


Animal incident completion on 2026-09-25:

- Added `animal_incident_2d.gd` and integrated its complete 1:45 guide-and-gate loop into the active host. It starts when two admitted phones are present, assigns different private facts, changes both controller modes and restores the normal pasture destination after the result.
- Added deterministic coverage for sustained gate holding, sheep boundary/gate behavior and all five sheep reaching safety. The scripted route completed successfully in about 25.6 seconds.
- Captured and inspected native shared and split-screen views with the flock, gate holder, HUD, markers and farm-themed divider. Evidence is in `docs/audits/2026-09-25-animal-incident/`.
- `npm run typecheck`, `npm run test:2d`, all nine arm64 Node tests, `npm run export:web` and the relay integration pass. Relay integration measured 19.9 ms and verified FLOCK/GATE private clues, the 1:45 deadline, screen axes and tractor controller mode. The exported browser host loaded with no warnings or errors.

Visual correction pass on 2026-09-25:

- Completed the functional-map pass with eight new operational sprites, ten named interaction destinations, contextual TV/phone feedback, textured dirt routes and edge-safe shared/split cameras.
- Captured and inspected five native 1280 × 720 views covering the working yard, pasture, orchard/apiary, dispatch, opposite-corner split screen and whole estate. Evidence is in `docs/audits/2026-09-25-functional-map-final/`.
- `npm run typecheck`, `npm run test:2d`, all nine arm64 Node tests, `npm run export:web` and the Godot relay integration pass. Relay integration measured 18.7 ms and verified private clues, screen axes and tractor phone mode. The exported browser host rendered the revised lobby/world with no browser warnings or errors.

- Generated and integrated original crop-state, continuous-boundary and farm-infrastructure atlases; retained full-resolution sources and deterministic runtime extraction.
- Fixed alpha preservation for generated sources, preventing authored art from becoming nearly invisible after extraction.
- Captured and inspected central-yard, mature-crop, split river-crossing and whole-map views at native 1280 × 720. Evidence and candid remaining issues are in `docs/audits/2026-09-25-visual-correction/`.
- `npm run typecheck`, `npm run test:2d`, all eight arm64 Node tests, the Godot relay integration and `npm run export:web` pass. Relay integration measured 17.9 ms and verified two-player private clues, screen axes and tractor phone mode.
- The exported browser host was reopened at `http://127.0.0.1:8787/host/`; the updated world rendered behind the lobby and the QR code appeared immediately.

Native 1280 × 720 visual audit on 2026-09-24:

- Captured and inspected the central yard, whole-map overview, opposite-corner split screen and mature crop state.
- Confirmed that topology and camera behavior are usable, but the current world is not visually publishable.
- Critical visible blockers are the repeated stick-like mature crop, disconnected boundary posts, hard terrain seams, flat capped lanes, miniature secondary structures, empty activity areas and geometric bridge/ford.
- Full findings and evidence are saved under `docs/audits/2026-09-24-map-review/`.

Coherent-map rebuild on 2026-09-24:

- Rebuilt `world_layout.json` as topology version 4 and updated topology tests for the current route/gate names and connected district graph.
- Replaced rotated/stretched boundary scattering with named horizontal/vertical modules and measured collision; created new coordinated hedge and wall source atlases and deterministic runtime extraction.
- Corrected farmer scale from `0.32` to `0.105`, tractor scale from `0.58` to `0.30`, and matched collisions/markers to the new footprints.
- Removed internal yard road overlaps, aligned every external route to a yard/field opening, textured the uncovered base and verified close, overview and forced-split cameras in the exported browser.
- `npm run assets:world2d`, `npm run typecheck`, `npm run test:2d`, `npm run export:web` and all eight arm64 Node tests pass.
- The Godot relay integration passes with two-player private clues, screen axes and tractor phone mode. The final browser inspection covered the central yard, opposite field/meadow split and crop route; no rendering failure appeared.

Previous production-world pass on 2026-09-24:

- `npm run assets:world2d` rebuilt all fourteen production environment sprites.
- The expanded `npm run test:2d` passed the complete unprepared → prepared → seeded → seedling → young → mature → harvested → damaged field lifecycle, all four enterable building collision/reveal structures, stream crossings, animated players, tractor and cameras.
- TypeScript typecheck and all eight arm64 unit tests passed.
- Web export passed; the gameplay and overview cameras were inspected in the browser, including a live seedling state. The final reload produced no new browser warnings or errors.
- The relay integration passed at 17.9ms with two-player private clues, direct screen axes and tractor phone mode verified.
- A physical two-phone traversal of every new doorway, bridge, ford and heavy route remains the next required acceptance check.
- The publishable-composition pass replaced diagram-like placement with an organised working court, logistics-aligned routes, planted orchard rows, continuous shared boundaries and restrained landmark trees. Eight coordinated terrain textures replaced broad flat fills; field soil also changes texture with preparation state. Gameplay and full-map views were inspected in the exported browser without new errors.

Most recent recorded engineering results after the machinery-shed review pass:

- TypeScript typecheck passed.
- All eight unit tests passed. The first sandboxed run could not open loopback ports; the normal local-network run passed.
- Godot imported and exported the machinery-shed GLB successfully.
- The browser export completed and the `H` review view was inspected visually.
- The standalone Blender preview was inspected after correcting floating roof purlins and the blocked interior.
- The warmer storybook variant was regenerated, reimported, exported and inspected in the live `H` review view.
- The hand-painted storybook benchmark was imported and visually checked in Godot; all four painted material families survive the browser export.
- Two additional original source atlases provide eight 512px shared materials for red enamel, slate, steel, rubber, oak bark, oak foliage, hawthorn and drystone.
- The revised barn, tractor, oak, hedge and wall were imported, exported and inspected individually in the live Godot `J` review.
- The final unit-test run passed all eight tests. The initial sandboxed run could not open loopback ports; the local-network run passed.
- The Godot relay integration passed with a 23.8ms frame acknowledgement and verified screen-right/screen-down axes.
- TypeScript typechecking and the browser export passed.
- The runtime material textures are four 512px PNGs. The 1254px generation atlas was moved to `source_assets/` so it is not included as an unused game resource.
- The earlier Fire OS debug APK remains at `artifacts/countryside-coop-debug.apk`; it has not been rebuilt for this unapproved review asset.

- The six authored storybook assets were placed in the real `world_layout.gd` farmyard and inspected in the browser-exported playable map; the browser console contained no warnings or errors.
- The machinery shed occupies the east yard, the barn the north yard, the tractor and oak the central yard, and authored hedge/wall segments define the immediate boundary.
- The boundary correction pass produced five optimized hawthorn modules, five optimized drystone-wall modules and an authored oak courtyard base. The user accepted the kit and it is integrated into the playable map.
- Repeated foliage, branches, stones and grass are joined by material. Ordinary hedge and wall modules export as two mesh groups rather than dozens of separate objects; gate variants preserve a separate gate pivot.
- The final boundary-kit browser export passed, TypeScript typechecking passed, all eight unit tests passed, and the Godot relay integration passed with a 23.9ms frame acknowledgement and verified screen-right/screen-down axes.
- The integration pass replaced procedural field hedges, moved the drystone boundary into the visible west-yard composition, aligned the ordinary gate to the actual road crossing and installed the oak base. Whole-map and close farmyard views were inspected; the browser console contained no warnings or errors.
- Final checks for the integration passed: browser export, TypeScript typecheck, all eight tests, and Godot relay input at 17.7ms with screen-right and screen-down axes verified.
- The grain-store pass created `bracken_grain_store.glb`, a collision scene, a `G` review scene and `docs/previews/bracken-grain-store.png`. Blender and Godot views were inspected; the final Godot review exposes the grain-hall door, intake pit, canopy and operating indicators without adding the asset to the farm.
- Grain-store verification passed: browser export, TypeScript typecheck, all eight unit tests and a sequential Godot relay check at 44.2ms with both screen axes verified. One earlier concurrent relay sample was incomplete; the isolated rerun passed.
- The 2026-09-22 grain-chain pass created and imported connected silos, a combine and grain trailer, installed the grain store, and inspected close, split and full-map browser views.
- The crop system replaced the oversized bar rows with one batched irregular field supporting seven states, headlands and paired tramline gaps.
- Tractor entry/driving/exit changes the private phone controller mode through the relay. TypeScript typecheck, all eight tests and browser export pass. The Godot relay check passes at 33.3ms and the final run verifies screen axes plus tractor mode.
- The first asymmetric loop adds a five-minute objective HUD, different private phone clues, a held-gate dependency, two tractor tramline checkpoints and protected/damaged barley consequences.
- Browser inspection found and corrected a web-only inferred-type error in `field_system.gd`; the corrected build loads the farm and objective HUD without new console errors.
- Final checks pass: TypeScript typecheck, all eight unit tests, browser export and Godot relay integration at 15.6ms. The integration now verifies two-player private clues, screen axes and tractor phone mode.
- The secondary-building pass generated an authored workshop and feed store, added collision scenes and a `U` review, and replaced both cube buildings in the real farmyard. The obsolete primitive produce canopy was removed because it intersected the authored grain store; the grain-store roof seams were also reduced and darkened.
- Browser export, the isolated workshop/feed review, the farmyard framing and the corrected grain-store roof were visually inspected. The workshop and feed store remain integrated candidates pending user visual signoff.
- Final validation passed: TypeScript typecheck, all eight unit tests, browser export and Godot relay integration at 12.5ms. The live browser reported no warnings or errors. The first unit-test attempt used the Mac's mismatched x64 Node/esbuild pair; the documented bundled arm64 Node route passed.
- On 2026-09-23 the user reported a successful real two-phone playtest, closing the previous hardware-input validation task.
- The character pass created original Grower and Mechanic GLBs, reusable Godot scenes, idle/walk/interact animation code, a carry-pose hook, a `P` isolated review and a deterministic character-pivot test.
- The final browser build was inspected in the `P` review; both characters render and animate, and the browser console reported no warnings or errors. The candidate art remains outside live play pending user approval.
- Validation passed: TypeScript typecheck, all eight unit tests, character visual test, browser export and Godot relay integration at 25.1ms. Sandboxed network attempts could not bind loopback and the local-network rerun passed.
- The rejected primitive-pivot character models were replaced in the `P` review by customised Quaternius Universal Base Characters with compatible Universal Animation Library 1 and 2 clips. The retained source packages include their CC0 1.0 licence files under `source_assets/third_party/quaternius/`.
- Each new candidate has a real `Skeleton3D`, skinned body/garments and fourteen imported clips covering idle, walk, jog, carry, interact, drive, repair, pickup, sitting, harvest, planting, watering, chopping and throwing.
- The close browser review caught and corrected centimetre/metre clothing selection, unbaked garment thickness, accessory attachment and reversed-facing defects. The final `P` review was inspected with the Grower walking and the Mechanic performing the repair animation.
- Runtime character files were reduced from roughly 33 MB combined to 8.4 MB combined by using 1024px gameplay textures and removing unused normal/roughness maps. The browser pack fell from 73 MB to 47 MB.
- Current checks pass: TypeScript typecheck, all eight unit tests, the skeletal character test, browser export and Godot relay integration at 12.9ms. The first unit-test attempt used the Mac's mismatched x64 Node/esbuild pair; the documented arm64 route passed.
- The kid-friendly character pass added Milo Mudboots as a third isolated candidate with a compact silhouette, bright overalls, oversized flowered hat, glasses, moustache, tool pouch and imported `Dance` clip. The `P` review was inspected at close gameplay scale through its dance phase; all three rigs rendered correctly and the browser console reported no warnings or errors.
- Post-Milo checks pass: TypeScript typecheck, all eight arm64 unit tests, the three-character skeletal test, browser export and Godot relay integration at 24.8ms. The current browser pack is 50 MB; the three runtime GLBs are 3.9 MB, 4.7 MB and 4.2 MB.
- The natural-build correction removed Milo's widening override and added rig-level proportions to all three exports: tall/wiry Grower, average Mechanic and shorter Milo. The rebuilt `P` review was visually inspected in idle and animated phases; clothing, accessories and skeletal motion remain aligned.
- Post-correction checks pass: TypeScript typecheck, all eight arm64 unit tests, the three-character skeletal test, browser export and Godot relay integration at 21.5ms. The first relay attempt used the Mac's mismatched x64 Node/esbuild route; the documented arm64 route passed.
- The user correctly rejected that first proportion correction because whole-character scaling left the superhero chest, shoulders and limb volume visibly unchanged. The generator now reshapes weighted torso, arm and leg geometry around the actual bones before creating clothing; Milo also receives a subtle soft middle. The stronger lean/medium/compact silhouettes were inspected both still and animated in the exported `P` review with no visible garment or accessory detachment.
- Final reshape checks pass: Python compilation, TypeScript typecheck, all eight arm64 unit tests, the three-character skeletal test, browser export and Godot relay integration at 14.6ms.
- The user rejected the Grower, Mechanic and Milo direction because the reshaped source bodies still felt artificial and insufficiently appealing to children. Those three models remain only as rejected historical files and no longer appear in the `P` review.
- Pip Puddleboots was authored as a new original visible character over the free Quaternius CC0 armature and animations. All imported source meshes are deleted before export; Pip's head, face, hair, cap, raincoat, scarf, trousers, hands and Wellington boots are custom geometry.
- The exported browser `P` review was inspected in idle and moving phases after correcting detached hair/cap transforms and the opening orientation. Pip's full costume stays attached and the browser reports no warnings or errors.
- Pip-pass checks pass: generator Python compilation, TypeScript typecheck, all eight arm64 unit tests, the four-rig skeletal test, browser export and Godot relay integration at 24.0ms. The Fire OS APK was not rebuilt for this unapproved review candidate.
- The user rejected continued 3D art production and chose a Stardew Valley-informed 2D presentation while preserving the original asymmetric cooperative design. The default `main.tscn` now loads `main_2d.gd`; the previous `main.gd` and all 3D assets are legacy source.
- The first 2D proof generated and integrated an original illustrated English farmyard, two transparent farmer sprites and a matching tractor. The source imagery and exact production prompts are recorded through this pass; the runtime crops are reproducible with `npm run assets:2d`.
- The 2D host preserves QR rooms, two-phone admission, private clues, direct screen-axis input, frame acknowledgements, tractor mode and adaptive shared/split cameras. The live Web build was inspected in shared and forced-split views after correcting the root canvas layer that initially hid the SubViewport composition; the final browser reports no warnings or errors.
- Export presets now include only `main.tscn` and the four 2D runtime images. The Web PCK fell from approximately 53 MB to 2.9 MB; the 36 MB WebAssembly runtime remains unchanged.
- Final 2D-proof checks pass: TypeScript typecheck, all eight arm64 unit tests, the dedicated 2D host visual test, Web export and Godot relay integration at 15.5ms.
- On 2026-09-24 the single-pose farmers were replaced by original 4 × 4 directional walk sheets: down, left, right and up with four stride frames per direction. Runtime sheets are deterministic 1024px atlases rebuilt by `npm run assets:2d`.
- Character movement now uses `CharacterBody2D.move_and_slide`; player and tractor scale were corrected, major farm structures received first-pass collision, and y-sorted foreground masks create real behind/in-front occlusion against the flattened proof image.
- The exported browser build was inspected at gameplay scale while the Grower moved right through a visible stride pose. The console contained no warnings or errors. TypeScript typecheck, all eight arm64 unit tests, the expanded 2D host test, Web export and Godot relay integration at 17.7ms pass.
- On 2026-09-24 the 2D production-world plan consolidated the measured 170 × 120 m logistics layout with every committed hackathon activity: sheep/gates, barley/weather, repair/parts, orchard/apiary, packing/loading and final dispatch.
- `npm run map:plan` now regenerates `docs/maps/brackenridge-production-map.svg` from `world_layout.json`. The SVG was rendered and inspected; package and layout JSON parse successfully. No runtime gameplay code changed in this planning pass.

## External blockers and limitations

- The APK has not been verified on qualifying Fire TV hardware because none is connected.
- Actual Fire TV performance, controller latency, focus behaviour, launcher metadata, and store compatibility remain unverified.
- The earlier Rain Before Barley proof was tried with two phones, but its old 3D gate/checkpoint route is not the active 2D incident. The complete 12–15 minute game and remaining incident systems are not implemented.
- The 2D joining and movement path has been exercised with two physical phones. The new guide-and-gate animal incident has deterministic and relay coverage, but still needs a complete physical two-phone pacing test.
