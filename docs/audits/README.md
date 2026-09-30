# Farm visual and UX audit

Date: 2026-09-24

## Scope

Review of the exported browser host at the normal shared camera, full-map development overview, forced split-screen camera and seedling crop state. The target experience is a polished family-friendly two-player Fire TV farming game.

## Evidence

1. `01-gameplay-camera.png` — waiting-room overlay over the normal shared gameplay camera.
2. `02-farm-overview.png` — complete 170 × 120 metre development overview.
3. `03-split-screen.png` — two players at opposite map areas.
4. `04-crop-state.png` — seedling presentation in the right split view.

## Overall verdict

The map now reads as one farm with credible functional zoning. It is substantially better than the scattered test layout. It is not visually ready to publish: asset scale, terrain scale, road blending, crop rendering and water presentation still reveal the prototype construction.

Structural readiness: **strong foundation**. Visual readiness: **mid-production**.

## Correction pass status

Implemented and re-inspected on 2026-09-24:

- Reduced terrain and field texture scale to calm grass, gravel and soil detail.
- Replaced uniform crop dots with deterministic irregular plant clusters, varied height/colour and explicit tramline gaps.
- Added route tyre wear, layered river channel/reflection detail and shared soft contact shadows.
- Corrected boundary-sprite anchoring and reduced farmer/tractor scale against the buildings.
- Replaced colour-only player rings with round and diamond identity markers.
- Moved QR joining into a centred full-screen pregame presentation. A follow-up one-phone test corrected its dismissal rule: it now hides after the first admitted phone, while the copy still recommends two farmers.

Still open after the correction pass:

- Roads need authored junction and verge pieces rather than only runtime line layering.
- Bridge, ford and riverbank art remain visibly functional rather than finished.
- Boundary runs still need authored corner/end modules and a physical collision review.
- Television overscan, accessibility, real Fire TV performance and full-route two-phone play remain unverified.

## Strengths

- The U-shaped yard gives the farm a clear centre and understandable circulation.
- Crop, orchard, pasture, loading yard and river are distinct without becoming disconnected islands.
- The palette is warm, welcoming and suitable for children.
- Characters remain readable against most ground surfaces.
- Split-screen separation is immediate and the farm-themed divider is more distinctive than a plain line.
- The QR code and room code have strong contrast and a clear waiting state.

## Highest-impact risks

### P0 — Asset scale is inconsistent

The tractor is nearly as visually tall as the machinery shed. The silo set is close to character height, and the smaller buildings read like decorative miniatures. Establish one metre-to-pixel scale and rebuild every structure, vehicle and character against a shared scale sheet.

### P0 — Terrain texture scale is too large

Grass blades, flowers, soil clods and gravel stones are comparable to heads and boots. Reduce terrain texture scale substantially and keep hero details as separate props. This will also calm the screen and make characters easier to follow.

### P0 — Crop stages do not yet look like crops

Seedlings form a perfectly uniform dot matrix. Use short plant sprites in slightly irregular row groups, preserve clear tramline gaps, and add subtle height/colour variation between cells. Mature crops need stronger stalk volume and edge motion.

### P1 — Roads still look painted on

Roads are broad single-colour ribbons with abrupt forks and hard boundaries against detailed grass. Add feathered verges, compacted centres, paired tyre wear and authored junction pieces. Keep the proven collision width unchanged.

### P1 — Water and crossings are visibly unfinished

The river is a flat blue strip. It needs bank textures, a darker channel, highlights or slow animation, reeds and a bridge that visually meets the road on both banks.

### P1 — Boundary modules do not form clean continuous lines

Several stone-wall and hedge pieces appear offset, angled or detached near the southern yard. Use endpoint-snapped modules, corner pieces and clear gate posts. Review the collision against the visible base after placement.

### P1 — Lobby obscures the hero composition

The waiting panel covers much of the barn, tractor and Player 1 area. Keep the QR large, but move the waiting state to a dedicated pre-game screen or compress it into a top band. Validate the hidden state after two phones join.

### P2 — Camera framing needs safe areas

In split view, Player 1 sits under the waiting panel while Player 2 is centred. Add per-camera UI-safe offsets and clamp cameras so players, entrances and objectives stay away from screen edges and overlays.

### P2 — Objects need stronger grounding

Buildings, silos and boundary pieces need consistent contact shadows. Current lighting and perspective vary between generated assets, which makes some objects appear pasted onto the terrain.

## Accessibility risks

- Status and helper copy is small for television viewing distance.
- Player identity relies heavily on red/blue colour rings; add distinct symbols or shapes.
- Crop state changes rely mainly on colour and texture; pair them with a concise status announcement and contextual phone feedback.
- QR joining has a room-code alternative, which is good, but focus order, screen-reader output and remote-only operation were not verifiable from screenshots.
- Motion, flashing, audio cues and colour-contrast ratios require implementation-level testing.

## Recommended order

1. Lock scale for characters, tractor, silos and every building.
2. Reduce terrain texture scale and rebuild crop-stage rendering.
3. Replace road ribbons with blended road/junction pieces.
4. Snap boundary modules and align every gate opening.
5. Finish water, bridge and ford presentation.
6. Move the QR lobby to a dedicated waiting screen.
7. Add contact shadows, weather variants and final set dressing.
8. Run a two-phone television-distance playtest and Fire TV performance pass.

## Evidence limits

This review covers visible exported states only. It does not prove collision accuracy, controller focus, screen-reader behaviour, Fire TV frame rate, television overscan, doorway traversal or two-phone camera behaviour under real play.
