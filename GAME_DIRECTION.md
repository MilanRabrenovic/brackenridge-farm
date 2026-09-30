# Brackenridge Farm — game direction

Updated 2026-09-30. This document describes the implemented two-player hackathon slice. Prior documents are retained under `docs/history/2026-09-30/`; their older status and 3D instructions are historical.

## Promise

A chaotic asymmetric couch-cooperative game where everyone sees the same English countryside farm, but nobody has all the information needed to save it. Original fictional setting; friendly illustrated 2D art. Fire TV is the primary target; Mac/native/browser is the development route.

## Current release scope

Exactly two human farmers, each controlled by a phone. One phone launches a clearly labelled full assisted solo test weekend. Four-player support is a future expansion, not implemented or advertised. The host owns simulation, seeded variation, crop state, movement, deadlines and outcomes. Phones send input and receive private clues. Share clue on TV is an explicit player action.

One connected 170 × 120 metre farm: yard, barn, workshop, feed store, silo/intake, pasture, barley, orchard/apiary, packing, dispatch, river and crossings. Placement comes from `game/data/world_layout.json`. Buildings have structural collisions, doorway gaps and measured cutaway interiors; trees have trunk collision and canopy occlusion. Farmers walk behind foreground objects. Adaptive cameras stay close and split when farmers separate.

## Complete weekend

| Stage | Rules | Cooperative information |
|---|---|---|
| Arrival | Walk, check hay; enter/exit tractor | Different controls/job introductions |
| Sheep | Guide five sheep through a continuously held gate | Herder versus gate instructions |
| Planning | Meet and both hold ACTION at animal care or repair bay; £20 improvement or save by timeout | Rain cover effort versus maintenance effect |
| Repair | Inspect, collect correct part, deliver, both hold six seconds | Mechanic knows the seeded belt/gasket fault; runner knows both supply locations |
| Weather | Prepare, sow, grow, harvest and store barley; cover apples | Grower receives forecast; partner receives storage/protection facts |
| Planning | Same affordable improvement choice | Shared decision and explicit consequence |
| Dispatch | Carry two buyer-approved loads to packing; inspect buyer; both hold at van | Dry stock availability versus buyer's chosen goods |
| Results | Outcomes, contributions, balance, seed, replay | Same seed with R; next seed through focused TV button |

Shelter halves apple-cover effort. Maintenance reduces repair effort. Seeds choose one of three bounded timer/order variants, including a slipping-drive belt fault or leaking-pump gasket fault; this is not a sophisticated adaptive AI Director. Deadline failures advance the run and leave reserve apples for final delivery. No elimination or irrecoverable stock shortage. Pause stops mission clocks and crop growth. A missing required farmer automatically pauses, including the only farmer in solo testing. Reconnect token restores the slot and latest private clue/controller mode; reconnect preserves a manual pause that was already active.

Cooperative deadline budget is approximately 14–15 minutes; successful jobs can finish much sooner. Real two-phone pacing has not been measured. Solo testing uses the normal mission deadlines and the same unprepared → prepared → seeded → seedlings → young → mature → harvested lifecycle. A helper holds the sheep gate, supplies repair diagnosis/second hold and assists final loading. The lone player still herds, collects/delivers the belt, drives the tractor, stores grain, covers apples and packs both loads. This supports complete local testing; it does not establish the human cooperative experience.

## Movement and farming

Phone stick directions follow screen axes. Walking uses four directional four-frame animation, boot anchoring, idle breathing, identity marker and foot collision. Tractor uses four upright directional views, side-view wheel animation and movement-driven suspension. Driving is direct directional control, not steering physics. Tractor entry hides the farmer; safe exit restores collision at an unobstructed nearby point.

Barley states: unprepared → prepared → seeded → seedlings → young → mature → harvested, plus damaged. Each work stage requires 16 distinct tractor cells; TV objectives show the current step, cell progress or growth countdown, and markers advance from field to intake to apple cover. Grower phone guidance changes with crop/stock state while the partner keeps their private storage facts; timed growth is accelerated for the demo (10/12/15 seconds). Paired tramlines remain clear visually, but tool attachment/spraying validation is deferred. Crop work excludes the machinery headland. It is a compact gameplay abstraction rather than a complete agricultural simulation.

## Phone controls

Movement, contextual ACTION/EXIT, Share clue on TV, Drop item, Pause/resume. Tractor mode changes to a wheel/dashboard UI with input gauge. Drop returns cargo to its store. The host buffers a short action tap until the next simulation tick. Released/stale/disconnected inputs are neutralized. No microphone, account or text chat required.

## Deliberately deferred

Four players, drivable combine/trailers, attachments, pesticide mechanics, cattle/dairy, shops/brewery, construction, inventory economy, NPCs, authored carry/repair/boarding animation sheets, extensive interiors, Bedrock recaps, adaptive incident scheduling and hosted internet matchmaking. Do not claim these exist. Cloud relay deployment and optional AWS features must not be introduced without separate testing.
