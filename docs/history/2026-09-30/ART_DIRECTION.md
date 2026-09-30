# Art direction and asset approval

## 2026-09-28 — Tractor directions awaiting approval

New front/rear/left/right art is a coordinated derivative of the original red tractor, generated through imagegen and reviewed at gameplay scale. No flat-sprite rotation is permitted for vehicles. Candidate remains review-only until user approval. Suspension bob is implemented; authored wheel-spin/entry animations are still missing. Phone uses a functional steering-styled directional pad, not simulated steering physics.


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


## 2026-09-28 approved reference applied

The user approved `farm-overview-cohesive-v1.png` as the visual direction and explicitly requested implementation. Preserve its warm earth, restrained turf, blended verges and purposeful yard. New terrain and verge derivatives are integrated under that authorization; final runtime appearance awaits user review. Do not replace the playable world with the concept image. Native evidence: `docs/audits/2026-09-28-cohesive/`. Older placement notes below describe the previous baseline; flat water and hard road edges have now been replaced. Gates and legacy tree repetition remain unresolved.


Last reviewed: 2026-09-28

## 2026-09-28 placement review

The current placement is layout v5. Native close/overview/split evidence is in `docs/audits/2026-09-28-placement/`. Keep the clear machinery lane, visible apiary, roadside delivery parking and bridge approaches. Next art work must address visible texture seams, boundary repetition, open/closed gate sprites and the flat water presentation. These are unresolved production blockers; the placement pass does not approve existing candidate art.


## 2026-09-25 integrated review benchmark

The current crop, boundary and infrastructure sheets define the next 2D quality benchmark under user review:

- barley uses overlapping authored clumps rather than procedural sticks;
- mature fields keep an open headland and two paired, tractor-readable tramlines;
- hawthorn and drystone runs read as continuous boundaries with real openings and gates;
- work props sit in named operational zones and leave the manoeuvring court open;
- bridge and ford art agrees with the route width and passable collision gap;
- generated source alpha is preserved during extraction.

Native evidence is stored in `docs/audits/2026-09-25-visual-correction/`. These integrated assets remain `Review` until the user accepts the final gameplay view.

The functional-map completion adds one coordinated operational sheet: two sheep poses, apiary hives, a grain grate, green farm trailer, cream-and-green dispatch van, produce pallet and spare-parts crate. They use the same top-down three-quarter light and warm countryside palette, remain separate sprites for later state changes, and were inspected in real shared and split cameras. Evidence is in `docs/audits/2026-09-25-functional-map-final/`; the set remains `Review` pending explicit visual approval.

## Target

Create an original, charming, polished 2D pixel-illustrated interpretation of a prosperous English countryside farm. The game uses a top-down three-quarter camera, readable silhouettes, warm colours, crisp clusters and enough detail to feel authored without copying another farming game.

The result should feel like a crafted animated farm world. It must not reproduce the identifiable visual language, composition, assets, names, or branding of another game or television programme.

## Audience and stylisation

- The world should immediately feel welcoming to children while retaining enough craft and detail for adults.
- Aim for a high-quality pixel-illustrated storybook farm rather than realistic agricultural visualisation or a preschool toy set.
- Use chunky readable pixel silhouettes, slightly exaggerated vehicle and character proportions, warm colour variation and small playful storytelling details.
- Prefer honey stone, chestnut timber, sage and mint greens, cream trim, sunny ochre, warm red and clear sky blue.
- Interiors should feel warm and safe, with golden practical lights and readable objects instead of near-black voids.
- Keep dirt, wear and mud, but stylise them into controlled pixel clusters and warm hues rather than grey-brown visual noise.

## Active 2D conversion benchmark

The default host uses a composed layered 170 × 120 metre farm assembled at runtime on a locked 10-pixels-per-metre scale, two distinct transparent 4 × 4 farmer walk atlases and one transparent tractor. Reusable production buildings, trees, boundaries and terrain surfaces live under `game/assets/2d/production/`; their full-resolution coordinated atlases live under `source_assets/2d/production/`.

The farmyard establishes the active palette and density: honey limestone, dark slate, sage metal, ochre dirt, golden barley, moss and hawthorn greens, wildflower accents and clear stream blue. Routes are broad and connected; heavy routes use subtle paired tyre wear. The barley parcel is irregular and includes headland/tramline gaps with plant placement varied inside readable rows.

Runtime terrain uses a `2.55×` UV repetition scale so gravel, flowers, grass blades and soil clods stay subordinate to characters. Buildings, trees and vehicles share the generated soft contact shadow in `game/assets/2d/production/contact_shadow.png`. Player identity combines colour with a round/diamond marker pair.

The two farmers establish the character rule: large expressive faces, different hair and headwear, different body silhouettes, clear occupational clothing and colourful boots. Their first production locomotion pass preserves those identities across down, left, right and up walk cycles with four stride frames each. At gameplay scale the farmer is visibly smaller than the tractor. The tractor establishes the vehicle rule: friendly exaggerated mass, large readable wheels and original fictional detailing without real-world branding.

This remains an integrated review pass, not approved final polish. The clean working court, textured route network, operational destinations, orchard rows, snapped field boundaries and landmark trees form one deliberate composition. Boundary and operational art remain review candidates until the user approves them. Terrain, routes, field states, buildings, trees, props, boundaries and foreground behaviour are independent. Weather variants and the single-view tractor still need production work.

The production topology and layer contract are locked in [`docs/2D_WORLD_PRODUCTION_PLAN.md`](docs/2D_WORLD_PRODUCTION_PLAN.md). The generated map SVG is a route and composition diagram only. Do not paint it into a single runtime background; construct the world from terrain chunks, reusable boundary/building scenes, field-state masks and separate foreground occluders.

## Legacy 3D reference set

The following work documents the rejected 3D phase. It may inform English farm function and colour choices, but it no longer defines the rendering technique and is not loaded by the default host:

- `game/assets/buildings/bracken_stone_barn.glb`
- `game/assets/vehicles/bracken_tractor.glb`
- `game/assets/environment/english_oak.glb`
- `game/assets/environment/boundary_kit/hawthorn_straight.glb`
- `game/assets/environment/boundary_kit/drystone_straight.glb`
- `game/assets/environment/boundary_kit/oak_courtyard_base.glb`
- `docs/previews/storybook-existing-assets-review.png`

Their old isolated review scenes remain in source, but the default 2D host does not expose them.

## Legacy machinery-shed benchmark

- `game/assets/buildings/bracken_machinery_shed.glb`
- `docs/previews/bracken-machinery-shed.png`

The machinery shed was the strongest 3D building and remains a useful functional reference for bay clearance, colour and farm storytelling. It is not the active visual benchmark.

The current storybook benchmark goes beyond flat colours: it uses original hand-painted texture maps for timber, limestone, metal and concrete, plus a round gable window, heavier framing and a small ridge vent. This is the technique to evaluate for future assets: economical geometry carrying painterly surface detail.

## Integrated boundary kit

The legacy 3D host used `K` to inspect the hawthorn kit, drystone-wall kit and oak courtyard base. That route is not available in the active 2D host.

- Hawthorn: straight, curved, corner, tapered end and four-metre gate modules with a continuous hand-shaped body, crown breaks and visible stems.
- Drystone: straight, curved, corner, tapered end and gate modules with irregular courses, capstones, moss pockets and stone piers.
- Oak base: irregular mulched soil, varied edging stones, grass and small flowers replaces the primitive box-built ring.
- Fire TV preparation: repeated meshes are joined by material; movable gates keep a separate `GatePivot`.

That paragraph describes the legacy 3D acceptance. The active 2D host uses newly generated horizontal, vertical and end modules aligned to the four-metre planning grid. They are integrated review candidates with matching collision and route gaps; they are not yet user-approved final art. The isolated `K` scene remains available for close review.

## Grain store in review

The legacy 3D host used `G` to inspect the grain store and drive-over intake. Its straight-through lane and loading-clearance decisions should inform the later 2D building layers.

## Grain-chain candidates

`docs/previews/bracken-grain-chain.png` shows the connected silo set, combine and grain trailer. They share painted sage metal, cream concrete, warm red, farm steel and rubber with the established tractor and shed family. Their silhouettes and named pivots are authored for real-time use; visual signoff and gameplay-state polish remain.

## Secondary-building candidates

The legacy 3D host used `U` to inspect the repair workshop and feed store. Their functional layouts and palette remain reference material for eventual 2D replacements.

Roof lines should describe a few broad slate courses or dark standing seams. Dense pale grids read as damaged or floating roof geometry at the gameplay camera, so the grain-store and secondary-building roofs use fewer, thinner, darker divisions.

## Rejected 3D character history

The Grower, Mechanic, Milo and Pip 3D candidates are retained only as historical source. The default host no longer exposes their `P` review. Do not use them as the basis for new production art.

Their skeleton and animation work may be consulted for interaction timing, but their visible bodies, clothing and rendering direction are rejected.

Pip's visible geometry is original. The free Quaternius Standard package supplies only the CC0 skeleton and compatible animation libraries; the imported superhero mesh is deleted before the custom head, body, outfit and accessories are built. Do not describe paid Regular or Teen source models as part of this project.

The earlier Grower, Mechanic and Milo candidates are rejected because their source-derived anatomy remained artificial after local reshaping. They no longer define the direction. New characters need different heads, body masses, costume volumes and movement personalities rather than recolouring one shared visible body.

Character silhouettes should be simple, rounded and emotionally legible, with enough asymmetry and material detail to belong beside the authored farm. Keep hands, footwear and props chunky enough for television readability. Avoid superhero anatomy, segmented placeholder shapes, blank faces and realistic uncanny proportions.

### 2D source and runtime rule

- Keep generated and full-resolution source art under `source_assets/`; only cropped and optimized runtime images belong under `game/assets/2d/`.
- Use transparent sprite sheets for characters, vehicles, animals and interactive props. Keep terrain and buildings in separate layers so states and occlusion can change independently.
- Reuse a shared palette, outline colours, shadow direction and pixel density across every asset.
- Inspect every runtime crop in Godot at the real shared and split-screen camera scales. A source image alone is not release evidence.
- Preserve prompts and deterministic crop/build commands in `docs/2D_ART_PRODUCTION.md` and `USEFUL_COMMANDS.md`.

## Rejected current experiments

The earlier low-poly oak, sphere-chain hedge and flat-colour wall have been replaced in the playable map. These remaining procedural dressing elements do not meet the target and must not guide new work:

- The primitive cylindrical silo.
- Box-built surrounding sheds.
- Remaining procedural trees and small vegetation.
- Flat blue puddle discs.
- Scattered procedural grass and flower primitives.
- Pale overlapping ground patches used as final terrain.

The revised oak uses a tapered trunk and asymmetrical hand-shaped crown lobes. The hawthorn is one continuous irregular volume rather than a chain of spheres. The wall uses individually offset courses and broad uneven capstones. Their painted detail comes from one shared 512px-per-material nature atlas.

These may remain temporarily for engineering context, but they are marked `Rejected` and should be removed from the main world as approved replacements become available.

## Shape language

- Use softened bevels and slightly exaggerated proportions.
- Give each building and vehicle a recognisable silhouette from the gameplay camera.
- Avoid perfect repetition. Rooflines, stonework, hedges, field boundaries, and tree crowns need controlled variation.
- Preserve functional scale: large doors, turning circles, loading areas, and gates must agree with vehicle dimensions.
- Keep small details chunky enough to survive television distance.

## Materials and colour

- Limestone and weathered stone: warm grey, ochre, moss, and restrained variation.
- Timber: warm brown with readable structural beams and darker sheltered faces.
- Metal roofs and machinery: muted greens, reds, slate blues, and galvanised grey.
- Crops and pasture: distinct families of green and gold, avoiding neon saturation.
- Soil: layered dark earth, dry ridges, compacted tracks, mud, and stubble rather than one flat brown surface.
- Use roughness, normals, colour variation, and contact shading to separate materials. Do not rely on colour alone.

## Lighting

- Warm directional daylight with soft atmospheric fill.
- Contact shadows must anchor objects without becoming large opaque brown shapes.
- Clear, overcast, approaching-storm, and wet-after-rain states need distinct environmental signals.
- Weather changes should affect sky, cloud shadows, wind, vegetation, surfaces, particles, and audio where appropriate.
- Preserve readable player and interaction contrast in every weather state.

## Terrain and fields

- Build connected terrain, not isolated coloured islands.
- Field boundaries should follow irregular, plausible contours.
- Blend verge, soil, crop, lane, mud, and yard surfaces through authored transitions.
- Crop geometry requires rows, headlands, tramlines, growth states, harvested stubble, and local damage variants.
- Vegetation density should frame routes and buildings without hiding gameplay.

## Television readability

- Judge every asset from the real close gameplay camera and at sofa distance.
- Player identity uses colour, symbol, and label.
- Interactive entrances, gates, implements, and load points need strong shapes and visible state changes.
- Tiny decorative detail is valuable only when it supports the larger silhouette and material read.
- Cooperative objectives use restrained dark-green television panels and emissive ground rings. These are functional prototype presentation elements; replace them only after the interaction route is validated.
- The first validated incident presentation uses one compact top-right objective panel, a green held-gate state, amber action-needed state and world rings sized for both shared and split cameras. Native evidence is in `docs/audits/2026-09-25-animal-incident/`; this approves the information hierarchy for prototyping, not the final illustration of the sheep or gate.

## Asset production pipeline

Every asset moves through these statuses:

`Planned → Specification ready → In production → Review → Approved → Integrated`

`Rejected` returns to specification or is replaced.

For each asset:

1. Record gameplay purpose, dimensions, moving parts, variants, and camera requirements in `ASSET_CATALOG.md`.
2. Create the asset as a separate reusable scene or model.
3. Render it in an isolated review scene under the target camera and lighting.
4. Inspect silhouette, materials, scale, animation pivots, performance, and Fire TV readability.
5. Ask the user to approve the visible result.
6. Mark it `Approved` before inserting it into the playable world.
7. After integration, verify collisions, navigation, entrances, split-screen readability, and performance; then mark it `Integrated`.

The map is assembled only from approved assets and approved terrain systems.

## Cohesive overview proposal — 2026-09-28

`source_assets/2d/concepts/farm-overview-cohesive-v1.png` is a review-only redesign of the current overhead map. Its worn dirt lanes, continuous vegetation edges, grounded yard and natural river banks establish a proposed cohesion target. Await user feedback. Do not use the image as one flattened playable background; retain independent terrain, collision, occluder, actor and crop layers. The illustration is not proof of machinery clearance.
