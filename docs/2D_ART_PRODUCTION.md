# 2D art production record

Last updated: 2026-09-25

## 2026-09-25 visual correction atlases

Three original 4 × 2 extraction sheets were generated and saved as:

- `source_assets/2d/production/crop_stages_atlas.png`
- `source_assets/2d/production/boundary_modules_v2_atlas.png`
- `source_assets/2d/production/farm_infrastructure_atlas.png`

The crop prompt requested eight isolated top-down three-quarter barley states on a perfectly uniform black extraction background: seedling, young, mature, storm-damaged, drilled seed row, stubble, headland tuft and cut swath. It required a warm storybook painterly pixel-art hybrid, crisp silhouettes, identical lighting/scale and no named-game imitation.

The boundary prompt requested eight continuous English field modules: horizontal/vertical hawthorn, an L corner, hedge gate, horizontal/vertical Cotswold drystone, wall corner and wall gate. It explicitly required the vertical wall to remain connected masonry rather than separate posts.

The infrastructure prompt requested a tractor-width Cotswold stone bridge, shallow ford, hay stack, supply station, tool station, water trough, produce crates and blank destination sign in the same top-down three-quarter family-game treatment.

Exact retained-source prompts:

> Production sprite extraction sheet. EXACT 4 columns x 2 rows grid, eight isolated original barley assets. Background must be perfectly uniform pure black RGB 0,0,0 from edge to edge: NO gradient, NO vignette, NO halo, NO glow, NO floor, NO cast shadows, NO lighting on the background. Use even neutral studio lighting on objects only. Warm storybook painterly pixel-art hybrid, top-down three-quarter game view, crisp silhouettes and readable small-scale shapes. Top row left to right: sparse barley seedlings rooted in a tiny irregular soil clump; young green barley clump; mature golden barley clump with plump heads; flattened storm-damaged golden barley. Bottom row: short drilled seed row with visible seeds; harvested barley stubble; compact mature barley headland tuft; cut barley swath. Keep each asset centered and fully inside its cell with at least 20 percent pure-black margin on every side. No text, characters, buildings or vehicles. No colored light or atmospheric background. Original art, no named-game imitation.

> Create an ORIGINAL production-ready 2D environment sprite atlas for a warm family-friendly English countryside farming game. Top-down three-quarter view, painterly storybook pixel-art hybrid, crisp silhouettes, subtle outlines, warm sunlight from upper left, consistent camera and scale, readable at small size. No text, logos, characters, buildings or vehicles. Clean 4 columns by 2 rows grid, EXACTLY eight isolated assets, generous separation, each fully inside its cell, on a uniform plain near-black background with no texture and no cast shadow outside the asset. Top row left-to-right: long dense green hawthorn hedge segment running horizontally; matching vertical hedge; L-shaped hedge corner; open wooden five-bar field gate between hedge posts. Bottom row: long honey-grey Cotswold dry-stone wall segment running horizontally; continuous vertical wall; L-shaped wall corner; open wooden farm gate between stone piers. Make every continuous segment clearly long enough to tile without gaps. The vertical wall must read as a connected run of masonry, not a row of pillars. Keep all perspective, lighting and scale consistent. Original fictional art, not matching any named game's style.

> Production sprite extraction sheet. EXACT 4 columns x 2 rows grid, eight isolated original English farm infrastructure assets. Background must be perfectly uniform pure black RGB 0,0,0 edge to edge: NO gradient, NO vignette, NO halo, NO glow, NO floor, NO cast shadows, NO lighting on background. Warm family-friendly storybook painterly pixel-art hybrid, top-down three-quarter game view, crisp silhouettes, even neutral lighting on objects only. Top row left to right: short honey-grey Cotswold stone bridge for a tractor, complete deck, low parapets, road openings, no surrounding water; shallow stone ford made of irregular flat slabs and two tiny reed clumps, no surrounding water; compact stack of golden rectangular hay bales on pallet; supplies station with two wooden crates, feed sacks and blue barrel. Bottom row: red tool rack and small workbench; galvanized livestock water trough; wooden produce crates with apples and vegetables; timber destination signpost with three blank boards and no lettering. Bridge and ford may fill more of their cells; props smaller. Every asset fully inside its cell with at least 15 percent pure-black margin. No text, people, buildings or vehicles. No atmosphere. Original art, no named-game imitation.

The first crop/infrastructure generations used gradient backgrounds and were retained only in the generation history, not the project. The accepted source sheets use uniform black/transparent extraction plates. `npm run assets:world2d` preserves their existing alpha, crops the largest connected object in each cell and writes runtime PNGs. Native review evidence is under `docs/audits/2026-09-25-visual-correction/`.

## 2026-09-25 operational activity atlas

The functional-map pass generated `source_assets/2d/production/operational_assets_atlas.png`. `npm run assets:world2d` extracts it into `sheep_alert.png`, `sheep_grazing.png`, `apiary_hives.png`, `grain_intake.png`, `farm_trailer.png`, `delivery_van.png`, `produce_pallet.png` and `spare_parts_crate.png` under `game/assets/2d/production/`.

Exact retained-source prompt:

> Production sprite extraction sheet for an ORIGINAL warm family-friendly English countryside cooperative farming game. EXACT 4 columns x 2 rows grid, eight isolated assets. Background perfectly uniform pure black RGB 0,0,0 edge to edge: no gradient, vignette, halo, glow, floor, cast shadow, text or labels. Top-down three-quarter storybook painterly pixel-art hybrid, warm light on objects only, crisp silhouettes, identical camera, scale family and outline treatment. Top row left to right: 1. one charming woolly white sheep standing and looking alert, full body; 2. one charming woolly white sheep grazing, full body; 3. cluster of three small traditional wooden beehives on stands, honey-gold boxes with pale roofs; 4. rectangular steel grain intake grate set in a small compacted-dirt apron. Bottom row: 5. parked green farm trailer with open empty bed, seen top-down three-quarter and sized for a tractor; 6. compact friendly cream-and-green delivery van with no branding and no driver; 7. pallet of labelled-by-colour produce crates with no written text; 8. open wooden spare-parts crate containing a red belt, silver cog, hose and wrench. Keep every asset completely inside its cell with at least 15 percent pure-black margin. No buildings, scenery, UI, people, logos or real brands. Original fictional art, no imitation of a named game.

The source sheet is preserved at full resolution. Runtime extraction keeps the authored alpha and largest connected component in each cell. Native shared/split/overview review evidence is stored in `docs/audits/2026-09-25-functional-map-final/`.

## Active direction

The game now uses an original top-down three-quarter pixel-illustrated English farm. Stardew Valley informed the decision to use readable 2D farming presentation, but its assets, palette, characters and layouts must not be copied.

## Built-in image generation prompts

The first proof used the built-in image-generation workflow.

### Farmyard

Create one original polished top-down three-quarter pixel-art English countryside farmyard. Include a honey-stone barn, open sage machinery shed, connected broad dirt yard, irregular golden barley field with headland and tramlines, pasture, curved hawthorn hedges, drystone wall, oak, flowers, muddy tracks, wide gates and a stream. Use crisp deliberate pixel clusters and a warm storybook palette. Keep the central routes clear. Exclude characters, people, vehicles, UI, text, logos, watermarks, copied assets, floating islands and rectangular field dominance.

### Farmers

Create exactly two isolated transparent full-body 2D pixel-art farmers in relaxed three-quarter view. The Grower is slim with curly auburn hair, forest cap, rust jacket, sage trousers and brown Wellington boots. The Mechanic has an average build, dark bobbed hair, mustard hat, cream shirt, teal overalls, tool belt and red Wellington boots. Give both large expressive faces and distinctly different silhouettes. Exclude scenery, held tools, extra poses, text, logos, superhero anatomy and copied characters.

### Tractor

Create one isolated transparent original red English farm tractor sprite in three-quarter top-down view facing down-right. Use a cream grille, charcoal tyres, yellow hubs, pale blue cab glass, exhaust, headlights and hitch, with friendly exaggerated proportions and no real-world branding. Exclude scenery, driver, implements, text, logos, photorealism and copied sprites.

### Directional farmer walk sheets

Each existing farmer portrait was supplied only as an identity and costume reference. The built-in image-generation workflow used this specification separately for the Grower and Mechanic:

> Create a production-ready original 2D game character sprite sheet. Use a warm whimsical British-countryside family-game treatment with a crisp hand-painted cartoon pixel-art hybrid that remains readable at small size. Use a transparent background and exactly four columns by four rows with sixteen equally sized cells. Rows are walking down, left, right and up. Columns form a seamless contact, passing, opposite-contact, passing walk cycle. Clearly alternate arms and legs, keep the head and torso stable, centre the full body with identical margins, and preserve the reference identity and outfit. Exclude grids, labels, text, extra objects and copied characters.

The generated sheets had slightly different source dimensions, so `npm run assets:2d` deterministically resamples every source cell into a uniform 256 × 256 runtime frame without changing row or column order.

## Files

Full-resolution generated sources:

- `source_assets/2d/prototype/farmyard_background_source.png`
- `source_assets/2d/prototype/farmhands_source.png`
- `source_assets/2d/prototype/tractor_source.png`
- `source_assets/2d/prototype/grower_walk_sheet.png`
- `source_assets/2d/prototype/mechanic_walk_sheet.png`

Runtime images:

- `game/assets/2d/prototype/farmyard_background.png`
- `game/assets/2d/prototype/grower.png`
- `game/assets/2d/prototype/mechanic.png`
- `game/assets/2d/prototype/tractor.png`
- `game/assets/2d/prototype/grower_walk.png`
- `game/assets/2d/prototype/mechanic_walk.png`

Run `npm run assets:2d` to reproduce the two isolated runtime farmer crops and both normalized walk atlases from retained source.

## Current limitation

The active world is no longer a flattened image. It assembles independent terrain, route, crop-state, building, tree, boundary, collision and foreground/reveal layers. The terrain fills and transitions remain functional rather than final, and the farmers still need directional idle/run/work sheets while the tractor needs consistent directional art.

### Production environment atlases

Full-resolution coordinated sources:

- `source_assets/2d/production/buildings_atlas.png`
- `source_assets/2d/production/environment_atlas.png`
- `source_assets/2d/production/terrain_atlas.png`

`npm run assets:world2d` crops, clears connected background washes and writes reusable runtime sprites and terrain panels under `game/assets/2d/production/`. The building atlas contains the barn, machinery shed, workshop, feed store, silos and packing canopy. The environment atlas contains oak, willow, orchard and flowering trees plus hedge, wall and gate pieces. The terrain atlas supplies pasture, hay, orchard floor, riverside meadow, gravel yard, track, rough soil and furrow soil. The same command also creates `contact_shadow.png`, a soft transparent grounding shadow shared by buildings, trees and vehicles.

The runtime terrain UVs repeat at `2.55×` the original world-space frequency. Do not restore one-image-per-field scaling: it makes gravel, flowers and soil clods comparable to character features. Crop plants use uneven spacing, deterministic jitter, missing plants and explicit tramline gaps so the growth stages remain readable without forming a dot matrix.

### Snapped boundary module atlases

The coherent-map pass added two original coordinated 4 × 2 source atlases:

- `source_assets/2d/production/hedge_modules_atlas.png`
- `source_assets/2d/production/wall_modules_atlas.png`

The hedge prompt requested top-down storybook pixel-art horizontal, vertical, four corner, tapered-end and open-gate hawthorn modules with warm greens, blossom and transparent separation. The wall prompt requested the same module order for honey-grey Cotswold drystone with irregular courses, capstones, moss and timber gate details. `npm run assets:world2d` extracts the source cells into named runtime images. The active map currently uses horizontal, vertical and end pieces on the four-metre planning grid; the corner/gate cells remain review material until their route-state presentation is approved.

## 2026-09-28 cohesive terrain production

Built-in image generation used the approved cohesive farm overview as reference for three coordinated images: a grass/earth/gravel/water atlas; transparent hedge, wall and verge modules; and a second short-grass surface replacing the first atlas quadrant's oversized foliage. Prompts requested original warm English countryside artwork, overhead gameplay projection, no buildings/actors/text in terrain and transparent backgrounds for isolated modules. Full-resolution sources remain in source_assets/2d/production. The deterministic extraction script crops measured source regions, preserves alpha, downsamples to runtime assets and constructs a layout-driven blend mask. No generated whole-map image is used as the game background.

## Reference-led foliage prompts — 2026-09-28

Built-in image generation, reference: source_assets/2d/concepts/farm-overview-cohesive-v1.png.

1. Coordinated 3×2 transparent sprite atlas: two rounded dense oaks, apple tree, horizontal hawthorn, blossom tree and willow; overhead three-quarter camera, upper-left sun, warm painted pixel illustration, clean opaque crowns and no ground islands/text. Saved as reference_foliage_v2.png. Alpha inspection confirmed transparent pixels despite the preview showing background RGB. A subsequent background-extraction attempt was unnecessary and is not consumed.
2. Seamless olive meadow surface with tiny white daisies, buttercups and occasional grass clumps; mostly calm turf, no trees, actors, roads or shadows. Saved as reference_meadow_v2.png.

Extraction is reproducible through scripts/build-reference-foliage.mjs. Tree dimensions and collisions stay independent. This is a reference-led derivative art set authorized for application, with final runtime acceptance still pending.

## Coordinated building atlas — 2026-09-28

Built-in image generation; input reference: farm-overview-cohesive-v1.png. Prompt: six separate original buildings in a 3×2 transparent sheet—honey stone barn with open double doors, sage-roof open machinery shed, stone repair workshop, feed store with lean-to, twin galvanized silos, slate packing canopy. Match warm painted pixel countryside rendering, high overhead three-quarter view, upper-left light, clean silhouettes, no ground patches, actors, vehicles or labels. Save source as reference_buildings_v3.png; extract measured regions with build-reference-buildings.mjs. Source art remains unchanged.
