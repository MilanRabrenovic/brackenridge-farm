# Game direction

## 2026-09-28 — Tractor interaction presentation

Tractor phone mode is a distinct dashboard: drag direction to drive, release to stop, separate EXIT. Gauge measures input strength, not authoritative vehicle speed. Host remains movement authority. Event mode messages cannot replace tractor controls while driving. Exit restores latest private clue. Work areas use connected textured cells, clipped to field polygon. Directional vehicle art awaits approval; current main art stays upright.


## Solo development override — 2026-09-28

At the user's request, events now start with the first admitted connected phone for solo testing. Two-player private roles and cooperative completion rules remain. A second phone joining does not restart the active incident. This overrides the older two-phone start requirement below, not the cooperative release concept.


## Implemented event sequence — 2026-09-28

Two admitted players trigger sheep guide-and-gate, then repair eight seconds after either outcome. Mechanic identifies the belt; runner locates parts. Inspection, correct delivery and both holding nearby for six seconds are required; deadline 180 seconds. Wrong parts rejected. R resets both events; free farming follows. Weather/crop and dispatch remain planned. Interiors reveal measured floor/wall cutaways independent of sprite bounds while either farmer is inside.


Last reviewed: 2026-09-28

## Placement contract

Layout v5 is the single placement source for buildings, props, trees, boundaries, roads and destinations. Machinery lanes reserve ground from crop work and plant growth. Interaction destinations are clear approach points, not prop centres. The bridge and ford are the only river crossings; each has a connected path. Run `npm run test:map` after placement changes to check actual collision clearance and destination connectivity.


## One-sentence concept

A chaotic asymmetric couch-cooperative game where everyone sees the same English countryside farm, but nobody has all the information needed to save it.

## Player experience

- Two to four people play together around a Fire TV; two players are the first optimisation target.
- One admitted phone may enter the farm for development and the short guided sample. The complete weekend remains a cooperative experience and requires two or more players for its asymmetric decisions.
- The tone and controls welcome families and children without simplifying away the cooperative decisions adults can enjoy.
- The television shows the shared farm, characters, problems, work, and consequences.
- Each phone controls one player and privately reveals role-specific facts.
- Players must speak, combine information, assign work, and coordinate physical actions.
- A complete hackathon session should last approximately 12–15 minutes.
- Calm farm work alternates with short, understandable bursts of chaos.
- Mistakes cost time, money, resources, or quality; they do not eliminate a player.

## Core proof of originality

Every major situation must include all four steps:

1. Different players receive different useful facts.
2. They communicate and make a joint decision.
3. They perform coordinated actions in the world.
4. The farm visibly changes because of the decision.

The phones cannot be decorative gamepads. At least one private fact must materially affect each major decision.

## Committed vertical slice

The playable weekend contains:

- A short arrival/tutorial.
- Friday, Saturday, and Sunday work phases.
- Two short planning/improvement choices.
- A coordinated final dispatch.
- Results, contribution summary, and replay seed.

The farm supports these four incident families:

1. Animal trouble.
2. Equipment failure.
3. Weather hazard.
4. Market pressure.

Parameters create variety inside these families. Do not add another incident category until all four are fun and generate meaningfully different situations.

## Signature cooperative interactions

### Guide and gate

One player guides escaped animals while another physically holds or operates a gate. Leaving the gate changes the situation visibly.

### Diagnose and supply

One player receives a machine diagnosis and performs repair steps while another finds and delivers the correct part under a competing deadline.

## Farming systems direction

Fields are interactive systems with readable states:

1. Untouched ground.
2. Cultivated or ploughed ground.
3. Seedbed prepared.
4. Seeded rows.
5. Growing crop.
6. Mature crop.
7. Harvested stubble.
8. Weather- or vehicle-damaged variant where required.

Arable crops include grass, wheat, barley, and maize/corn where the selected scenario needs them. Crop fields use headlands for turning and tramlines for later spraying or fertilising passes. Machinery routes and gates must fit their intended vehicles.

Vehicles may become drivable, but driving must serve cooperation. Entering a tractor or combine changes that player's phone controller while preserving private information and contextual actions.

The first implemented vehicle loop is the tractor: a nearby player enters with the contextual phone action, drives with screen-aligned steering, receives tractor-specific private information and exits back to their role. Tractor coverage now prepares untouched soil, seeds prepared ground and harvests mature crop. Attachments, treatment passes and shared-resource constraints still need implementation.

The production map now provides named physical anchors for every committed loop: animal care and pasture gate, repair bay and parts crate, barley gate and tramlines, grain intake and trailer, apiary, packing pallet, dispatch van, bridge and ford. Proximity reveals the destination on the television; the contextual phone action explains its purpose. Incident code should attach to these anchors instead of adding duplicate scenery or moving the map footprint.

## Active first cooperative loop

`Guide and Gate` is the first complete incident on the active 2D production map:

1. Player one privately learns that storm wind is approaching and that sheep move away from a nearby farmer.
2. Player two privately learns that the pasture latch will not remain open and must be held with the phone action.
3. Five sheep escape into the meadow. The herder approaches from the far side and guides them toward the marked pasture.
4. The gate keeper stands at the gate and continuously holds the action while the flock crosses.
5. The television shows the countdown, sheep returned, gate state and clear success or failure. Pressing `R` restarts the incident for development and playtesting.

The active pass lasts 1:45, changes both phone controller modes and uses the real pasture boundary. It is deterministically verified start-to-finish; a physical two-phone pacing test is the next acceptance step.

## Earlier cooperative proof

`Rain Before Barley` was the earlier five-minute 3D proof of the core hook:

1. Player one privately learns that heavy rain will damage the mature barley.
2. Player two privately learns that the tractor has fuel for one trip and must use the east gate and paired tramlines.
3. One player holds the field gate while the other drives through.
4. The driver completes two marked passes while the other player calls the route.
5. Completion changes the field to protected barley; timeout changes it to damaged barley under storm lighting.

That proof established the private-fact and held-action pattern but is not the active 2D incident. A two-phone playtest succeeded on 2026-09-23. Its useful decisions will be adapted later into the active weather-hazard family instead of reviving its old 3D route.

## Player-character direction

- The 3D Grower, Mechanic, Milo and Pip experiments are rejected as the production presentation. They remain historical files only.
- The active 2D proof has a rust-and-sage Grower and a cream-and-teal Mechanic with visibly different faces, hair, hats, body silhouettes, clothing and boots.
- Build personality through large readable faces, strong silhouettes, clothing, colour, pose and animation. Do not create recoloured versions of one sprite.
- Production characters need four-direction idle, walk and run loops plus role-specific carry, interact, drive, repair, harvest, plant, water and celebration actions.
- The current Grower and Mechanic use four-direction, four-frame walk cycles with physics movement and gameplay-scale foot collision. Subtle procedural idle breathing and input-speed walk playback are present. Authored directional idle/run and role action frames remain.
- The first live implementation remains optimised for two players. Players three and four remain future work after the first two live roles are approved and readable at gameplay scale.

## Phone controller modes

The controller retains a stable movement area and changes its contextual controls:

- On foot: interact, carry, drop, role facts.
- Tractor: steering, throttle/brake, attach, fuel/fault/route information.
- Combine: steering, header, unload, moisture/grain/quality information.
- Animal handling: guide or whistle, flock stress and gate information.
- Beekeeping: smoker and collect, hive mood and weather risk.
- Repair: inspect, select part, fit, tighten, private diagnosis.

## Camera

- Use a close top-down three-quarter 2D camera during ordinary play.
- Nearby players share one view.
- When players separate beyond the readable shared range, divide the television into distinct views with a farm-themed border.
- Merge views again with hysteresis so the screen does not flicker between modes.
- The overview exists as a development and planning tool, not the default gameplay presentation.

## World character

- Fictional working farm in the English countryside.
- Connected irregular fields bounded by hedgerows, walls, ditches, lanes, gates, and natural contours.
- A believable central farmyard with broad machinery access and clear storage flow.
- The world should suggest a larger estate beyond the playable area.
- Sheep are one incident source, not the theme or main activity of the whole game.

## Current scope exclusions

Do not build these before the vertical slice works start-to-finish:

- Cattle or dairy production.
- Farm shop or brewery simulation.
- Freeform construction.
- Breeding systems.
- Multiple farms.
- General-purpose AI farmhand.
- Realistic vehicle physics.

See `docs/GAME_PLAN.md` for the full schedule, fairness constraints, validation targets, Bedrock role, and submission requirements.
