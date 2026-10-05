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
