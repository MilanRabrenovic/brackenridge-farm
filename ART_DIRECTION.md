# Art direction and approval

Updated 2026-09-30.

## Active visual benchmark

Original warm illustrated 2D countryside, grounded in the approved `source_assets/2d/concepts/farm-overview-cohesive-v1.png`. Honey stone, slate, sage metal, worn golden gravel, olive turf, flowering hawthorn, drystone walls and rounded foliage. Characters and tractor are separate animated actors; the map is not one flattened image. No copying Stardew Valley or Clarkson's Farm branding/assets.

The six coordinated `reference_*` structures, reference foliage, layered ground/wear masks, hedge/wall modules, original Grower/Mechanic walk sheets and red tractor define the runtime. World shadows are economical 2D silhouette/contact projections. Rain is a restrained screen shader with overcast tint; water and foliage have subtle motion. The split divider is a thin painted-timber seam with cream trim. The launch splash uses the original stone barn and a deep green background; the app icon is an original vector barn mark. Mission UI uses deep green and warm cream with readable outlined text.

## September 30 integration

The user's explicit instruction to finish/add the remaining game authorizes integrating the already-created matching directional tractor candidate. This records integration authorization, not a separate invented aesthetic approval. Four upright directions and isolated native captures verified. Side-view wheel sprites are extracted from the original tractor art and rotate independently; front/rear wheels remain drawn in the directional view. Enter/exit is a visibility/mode change, not an authored boarding sequence.

Cutaway interiors follow measured structural floor/wall dimensions. Existing hay, tool, parts and produce art dresses rear walls, with the entrance/centre aisle kept clear. These are compact functional cutaways, not bespoke furnished rooms.

## Asset workflow

Retain originals under `source_assets/`; optimized runtime assets under `game/assets/2d/`. Generate coherent individual assets or coordinated sets; inspect at gameplay scale before integration. Respect user approval requirements for new unrequested directions. Decorative art must never alter tested route clearance silently. Rejected 3D shapes/characters are legacy only.

## Honest quality limits

No pixel-identical reference claim. Repeated foliage, baked illustration perspective and simplified water remain visible. Characters have authored walk cycles, but no dedicated carry, repair, harvest or boarding frames. Static sheep art moves under simulation without a full gait sheet. No measured Fire TV performance yet. September 30 native staged mission views and browser review are under `docs/audits/2026-09-30-release/`. Earlier evidence is historical, not current approval.

## Full solo review — September 30

Actual accelerated motor-route captures under `docs/audits/2026-09-30-solo/` show repair, harvested field and successful results without teleporting actors into the scenes. Objective status/feedback now stack vertically within the panel, preventing right-edge overflow; the duplicate repair waypoint was removed. Existing art/placement remains unchanged. These are automated local rendered-route frames, not human acceptance or qualifying TV footage.

Farming objectives now use the same green/cream panel for stage-specific instructions and measured cell/growth progress. The existing text marker points to field, intake or apiary according to the job state; no new asset or landscape placement was introduced.

## Mission readability audit

Eight refreshed staged cooperative screens and private cards are under `docs/audits/2026-09-30-missions/`. Purchase confirmation, readable result beats, visible plot targets and local worked patches now supply task feedback. Private facts remain separate from current-action hints; tractor controls were inspected at 390×780. Old completed-event markers are cleared during result/planning. No new art or map placement was introduced. Split-screen offscreen navigation and human/TV readability remain acceptance gaps. See `docs/MISSION_EXPERIENCE_AUDIT.md`.

## Sheep motion pass

Existing approved/integrated sheep images now use `sheep_gait.gdshader` to move diagonal leg pairs independently. Body bob is restrained; jump height changes the sprite relative to the ground shadow rather than rotating the whole image. Four native gameplay frames were inspected under `docs/audits/2026-09-30-sheep/`. No new raster art was generated or approval invented. Grazing/alert silhouettes remain fixed perspectives; bespoke multi-direction animal frames remain a quality limitation.

## Co-op repair instrument

Repair now has a compact deep-green gauge, sage safe band and cream needle in the existing mission panel. Low/green/hot staged native captures were inspected at 1280×720 under `docs/audits/2026-09-30-repair-play/`. No new raster art or machine animation was created. Gauge changes represent test pressure; physical repair and character work poses remain visually simplified.

## Adaptive farm minimap

The minimap is a schematic UI chart built from the authored layout, with sage field shapes, golden tracks, muted building footprints and blue river. Its deep-green frame and cream trim match the mission UI. Farmer colors/shapes match their world identities; public task crosses pulse gently. Bottom-centre placement straddles the split seam; shared view moves it to bottom-right with a short transition. Shared, split and merged native views were inspected at 1280×720. No new raster asset or world placement was generated. The diagram abstracts scenery and gives orientation, not collision-aware route directions or an exact illustrated overview.

## Actual cooperative route review — October 5

Repair, split harvest and results captures in `docs/audits/2026-10-05-coop-route/` were produced during a complete accelerated two-slot input/physics run, rather than staging actors directly. Native frames were inspected with the shared/split minimap and task/result panels. No raster art, world placement or animation direction changed. These establish local rendered-route evidence; user aesthetic approval, human fun and TV rendering remain separate acceptance requirements.

## TV wrapper startup text — October 5

Native loading/error text uses the established deep-green/cream interface palette. No raster asset, world placement or animation changed. The development diagnostic strip was inspected through Appium, but the farm surface was flat-coloured in that capture; no TV art/color-fidelity approval is claimed.

## October 15 laptop presentation pass

Added deep-green/cream, farmer-coloured bottom action cards and small matching compass pointers. They avoid the shared/split minimap and hide for lobby/results. The shared clue sits above them. The expanded result report is centred within 1280×720; phone results use a compact green/cream card with a large ready button. Native shared/split/results and actual co-op route frames were inspected under `docs/audits/2026-10-15-finish/`. No new raster assets or placement changes; no new asset approval is asserted. Phone fixture captures are labelled development review, not gameplay footage.

## October 19 — Promotional cover

Devpost cover v1 follows the original illustrated characters and honey-stone/slate/olive/golden palette. It is a composed illustration, not a gameplay screenshot or new runtime art. Large cream/gold title on a green timber sign remains readable at gallery-card scale. Source and generation prompt: `source_assets/2d/marketing/`. Generated/final JPEG inspected; user approval pending.

## October 19 — Submission gallery

Four promotional gallery layouts use actual native-route screenshots, established deep green/cream/gold typography and labelled reproduced private clues. No generated replacement gameplay or new runtime assets. Full viewport preserved; reviewed contact sheet and validated 3:2 JPEG sizes. Files/provenance are under `source_assets/2d/marketing/gallery-v1/` and `artifacts/submission/gallery-v1/`. User aesthetic approval pending.

## October 20 — renderer compatibility

The Vega WebGL1 port reuses the existing approved 2D art; no new world asset or visual approval is introduced. Godot 3 RGBA/ARGB colour conversion preserves translucent guidance colours; scalable Noto Sans (SIL-OFL) supplies TV text. Actual guest farm/UI/tractor frames are in `docs/audits/2026-10-20-vega-port/`. Rendering evidence is not final visual approval or sustained performance acceptance.

## Vega static presentation caching — October 20

The compatibility build derives terrain and six building cleanup textures from the existing shaders/art, preserving their authored placement and colours. This is an optimization of existing integrated art, not a new art direction or approval. Buildings/actors/collision/cutaway layers remain separate; animated water is clipped to the authored channel bounds. Derived files live in the generated build and are recreated from maintained source, not copied into the Godot 4 art tree. Isolated baked barn and actual host-backend gameplay were inspected. See `docs/audits/2026-10-20-vega-performance/`.

## October 20 — demo media only

Genuine Vega gameplay video uses existing runtime art, simple editorial captions and a labelled reproduction of actual private clues; no new runtime asset or approval state changed. CC0 TinyWorlds Forest Ambience is demo-only audio; provenance is `source_assets/audio/demo/ATTRIBUTION.md`. Video/check scope: `docs/DEMO_VIDEO.md`.
