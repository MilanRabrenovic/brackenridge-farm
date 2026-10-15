# Brackenridge Farm — game direction

Updated 2026-09-30. This document describes the implemented two-player hackathon slice. Prior documents are retained under `docs/history/2026-09-30/`; their older status and 3D instructions are historical.

## Promise

A chaotic asymmetric couch-cooperative game where everyone sees the same English countryside farm, but nobody has all the information needed to save it. Original fictional setting; friendly illustrated 2D art. Fire TV is the primary target; Mac/native/browser is the development route.

## Current release scope

Exactly two human farmers, each controlled by a phone. One phone launches a clearly labelled full assisted solo test weekend. Four-player support is a future expansion, not implemented or advertised. The host owns simulation, seeded variation, crop state, movement, deadlines and outcomes. Phones send input and receive private clues. Share clue on TV is an explicit player action.

One connected 170 × 120 metre farm: yard, barn, workshop, feed store, silo/intake, pasture, barley, orchard/apiary, packing, dispatch, river and crossings. Placement comes from `game/data/world_layout.json`. Buildings have structural collisions, doorway gaps and measured cutaway interiors; trees have trunk collision and canopy occlusion. Farmers walk behind foreground objects. Adaptive cameras stay close and split when farmers separate. A schematic minimap sits at the bottom centre across the divider when split, and moves to the bottom-right in shared view. It shows roads, fields, building footprints, both farmer identities and public task destinations; private diagnosis/buyer preferences remain on phones.

## Complete weekend

| Stage | Rules | Cooperative information |
|---|---|---|
| Arrival | Walk, check hay; enter/exit tractor | Different controls/job introductions |
| Sheep | A seeded, staggered four-second fence breakout starts the event. Rushing close makes sheep jink; calm guiding keeps a reliable route. Guide five sheep through a gate opened for eight seconds by ACTION; refresh or hold to keep open | Herder versus gate instructions |
| Planning | Meet and both hold ACTION for three continuous seconds at animal care or repair bay; £20 improvement, owned-upgrade guard, or save by timeout | Rain cover effort versus maintenance effect |
| Repair | Mechanic inspects to reveal fault, then HOLD pumps/RELEASE cools test pressure. Runner fetches/delivers and holds to fit. Both stay at bay; fitting advances only at 40–75% green pressure for six seconds (three with maintenance). | Mechanic learns seeded belt/gasket fault through inspection; runner knows both supply locations |
| Weather | Work 16 marked plots per operation; deliberately engage sow/harvest; seal intake, store barley, cover apples; optional packing crates | Grower receives forecast; partner receives storage/protection facts |
| Delivery briefing | Ready at packing/dispatch or advance after 25 seconds; no purchases | Buyer and storage roles |
| Dispatch | Carry two buyer-approved loads to packing; inspect buyer; both hold at van | Dry stock availability versus buyer's chosen goods |
| Results | Outcomes, deduplicated task recognition, balance, seed, replay | Same seed with R; next seed through focused TV button |

Three-second result beats separate completed jobs. Storage sealing takes four seconds, apple covering six (three with shelter), and optional crate preparation four. Shelter halves apple-cover effort. Maintenance reduces repair effort. Seeds choose one of three bounded timer/order variants, including a slipping-drive belt fault or leaking-pump gasket fault; this is not a sophisticated adaptive AI Director. Deadline failures advance the run and leave reserve apples for final delivery. No elimination or irrecoverable stock shortage. Pause stops mission clocks and crop growth. A missing required farmer automatically pauses, including the only farmer in solo testing. Reconnect token restores the slot and persistent mission fact/current task hint/controller mode; reconnect preserves a manual pause that was already active.

Cooperative deadline budget is approximately 14–15 minutes; successful jobs can finish much sooner. Real two-phone pacing has not been measured. Solo testing uses the normal mission deadlines and the same unprepared → prepared → seeded → seedlings → young → mature → harvested lifecycle. A helper holds the sheep gate, supplies repair diagnosis/pressure balancing and assists final loading. The lone player still herds, collects/delivers the belt, drives the tractor, stores grain, covers apples and packs both loads. This supports complete local testing; it does not establish the human cooperative experience.

## Movement and farming

Phone stick directions follow screen axes. Walking uses four directional four-frame animation, boot anchoring, idle breathing, identity marker and foot collision. Tractor uses four upright directional views, side-view wheel animation and movement-driven suspension. Driving is direct directional control, not steering physics. Tractor entry hides the farmer; safe exit restores collision at an unobstructed nearby point.

Barley states: unprepared → prepared → seeded → seedlings → young → mature → harvested, plus damaged. Each work stage requires the same 16 authored gold plot targets. Local worked patches appear as plots are completed; the overall field stage still changes after all 16. Preparation stops before sowing, and maturity stops before harvesting until the driver explicitly engages the phone tool button; TV objectives show the current step, cell progress or growth countdown, and markers advance from field to intake to apple cover. Grower phone guidance changes with crop/stock state while the partner keeps their private storage facts; timed growth is accelerated for the demo (10/12/15 seconds). Paired tramlines remain clear visually, but tool attachment/spraying validation is deferred. Crop work excludes the machinery headland. It is a compact gameplay abstraction rather than a complete agricultural simulation.

## Phone controls

Movement, contextual ACTION/EXIT, Share clue on TV, Drop item, Pause/resume. Tractor mode changes to a wheel/dashboard UI with input gauge and Engage field tool button. The original mission fact remains readable separately from the current task hint. Drop returns cargo to its store. The host buffers a short action tap until the next simulation tick. Released/stale/disconnected inputs are neutralized. No microphone, account or text chat required.

## Mission quality review — September 30

The audited defects have been addressed locally: acknowledged hay check, three-second purchase confirmation and readable result beats, delivery briefing replacing ineffective late purchases, persistent private facts, marked farming plots and explicit tool handoffs, storage sealing/crate preparation, and task recognition that cannot be inflated by repeated clue/intake commands. Gate opening windows let the keeper help herd. Failed repair increases final loading from six to ten seconds; prepared crates reduce either duration by two. Four successful outcomes receive care bonuses; delivery alone does not earn the perfect-weekend heading. These changes add no new incident family.

The solo input route and mission regressions pass. Human enjoyment, typical duration and child comprehension remain unmeasured. The mechanic can pre-charge and regulate pressure while the runner travels; human participation balance is still unmeasured; split-screen destination markers can leave view; farming remains a compact field-stage abstraction. See `docs/MISSION_EXPERIENCE_AUDIT.md` for current evidence and acceptance steps.

## Deliberately deferred scope

Four players, drivable combine/trailers, attachments, pesticide mechanics, cattle/dairy, shops/brewery, construction, inventory economy, NPCs, authored carry/repair/boarding animation sheets, extensive interiors, Bedrock recaps, adaptive incident scheduling and hosted internet matchmaking. Do not claim these exist. Cloud relay deployment and optional AWS features must not be introduced without separate testing.

## Sheep personality and motion

A bounded opening fence escape occurs once per sheep event. All five jump with staggered seeded order, then scatter to the existing escape positions. Sheep evade rushed approaches, but gate route assistance remains, and safely returned sheep never repeatedly escape. This preserves solo testing and the co-op herder/gate-window roles. Leg pairs are deformed independently using the existing art, with speed-dependent cadence, subtle body movement, horizontal facing and a grounded shadow during jumps. This is a lightweight animation treatment, not a new hand-drawn directional gait sheet. Human fun remains unverified.

## Active co-op repair

The mechanic alone learns the faulty part through ACTION inspection. Test pressure starts at 50% after inspection; HOLD raises it at 22 percentage points/second, RELEASE cools it at 12. The green band is 40–75%, visible on TV and named in phone instructions. The runner collects/delivers the correct part, then holds ACTION while both remain at the bay. Pressure outside green pauses fitting without losing progress. Continuous holding alone cannot complete the job. The mechanic can prepare the gauge during the fetch trip; it is not a mandatory separate waiting task. Solo assistance balances at 55%. Overheat messages provide playful feedback, without damage or additional stock penalties.

## Result-transition input rule — October 5

During the three-second mission result message, context interactions are ignored so a new ACTION hold cannot silently board nearby equipment. Movement remains responsive. Normal interactions resume with the next mission. A full two-slot input/physics route now verifies the weekend without solo assistance or actor/crop teleporting; this is automated technical evidence, not a human pacing/fun study.

## TV startup presentation — October 5

The Vega wrapper provides friendly native loading and connection/startup error text while the game page initializes. Development builds can show a canvas-status strip; release gameplay omits that technical detail. Startup-overlay removal/nonzero canvas bounds are diagnostic readiness only, not gameplay or TV acceptance. Phones and host simulation are unchanged.

## October 15 laptop completion / acceptance order

The user explicitly wants the laptop implementation finished first; human co-op and Fire TV tests happen at the end. Public per-farmer action/destination cards and offscreen compass arrows now supplement the minimap. They never select the repair part or buyer goods using private facts. Nearest public supply guidance still requires reading/communicating the phone clue.

At results, players stop moving/animating. Phones show the farm-report/replay screen: each co-op farmer votes ready, tapping again cancels, and disconnect clears that farmer's vote. Both connected farmers must agree; solo uses one vote. The TV button can also start the next seed. Room code is visible on phones. These are locally tested behavior improvements; enjoyment remains a final human test.

October 15 admission clarity: a connected pending phone now explicitly says to press Enter/Select on the host; the host roster shows waiting phones and the same admission action. Admission authority is unchanged. The hint hides after admission. The finishing regression checks the host prompt. Final exports/package are refreshed after this change.
