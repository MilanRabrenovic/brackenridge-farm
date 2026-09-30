# Brackenridge Farm map review

Date: 2026-09-24

## Audit scope

Current exported 2D host at the native 1280 × 720 game viewport. The review covers the central farmyard, whole-map composition, adaptive split screen and mature crop state. QR joining was also inspected in the live browser. Collision correctness, physical-phone comfort, sound and Fire TV frame rate cannot be proven from screenshots.

## Verdict

The map now has a usable navigation skeleton, but it is not visually publishable. The yard, field and route locations are understandable and the split screen works. The terrain transitions, boundary art, crop presentation, small structures, water crossing and activity dressing still read as prototype assembly. Do not add the hackathon incident layer yet; fix the visible world kit first.

Current assessment:

- Navigation/layout foundation: **6/10**
- Camera and split-screen foundation: **7/10**
- Visual cohesion: **4/10**
- Publish readiness: **3/10**

## Step 1 — Central farmyard

![Central farmyard](02-central-farmyard.png)

**Health: Needs major revision**

Strengths:

- Barn, machinery shed, tractor and silos create a readable equipment hub.
- The open court gives vehicles turning space.
- Player markers use both colour and shape.

Problems:

- The gravel court is much too empty and has no readable work zones or activity anchors.
- Workshop and feed-store sprites are miniature beside the barn, tractor and yard footprint.
- The west wall reads as disconnected stone pillars rather than a continuous boundary.
- Dirt lanes end as flat rounded ribbons; the crop entrance creates an artificial triangular junction.
- Hard terrain seams and unrelated texture densities make the farm look assembled from separate images.
- Farmers are physically plausible but too small and visually weak for a child-focused television game.

## Step 2 — Whole-map overview

![Whole-map overview](03-overview.png)

**Health: Structurally understandable, visually unfinished**

Strengths:

- The yard, barley field, orchard, meadow, loading yard and stream occupy distinct areas.
- Main routes connect the activity districts.
- Irregular district outlines avoid a pure rectangular grid.

Problems:

- Field boundaries are largely absent visually, so districts meet through hard texture cuts rather than hedges, walls or verges.
- Multiple roads have rounded dead ends at the world edge or stop without a destination.
- The lower packing yard and stream feel detached from the farm rather than part of one estate.
- The overview exposes large undecorated areas and inconsistent object scale.
- The river edge, bridge and ford use flat geometric strips that clash with the illustrated vegetation.

## Step 3 — Split-screen field work

![Split-screen field work](04-split-screen.png)

**Health: Camera works; gameplay framing needs guidance**

Strengths:

- Separation activates reliably and each player gets an independent close camera.
- The hedge-and-stone divider is clear, attractive and much stronger than a plain line.
- Player markers remain readable on different terrain.

Problems:

- The left view contains mostly empty grass and an unfinished crossing; the right view contains almost only soil. Neither view tells a player what to do.
- Buildings and trees can dominate the bottom edge while the interaction target remains off-screen.
- There is no TV-side partner direction, objective summary, destination marker or interaction affordance.
- The actors need slightly larger silhouettes and stronger ground contrast at half-screen width.

## Step 4 — Mature barley

![Mature barley](05-mature-crop.png)

**Health: Critical blocker**

Strengths:

- The field can change state independently from its terrain.
- Prepared furrows are visible and the mature colour is distinct.

Problems:

- Mature plants read as repeated yellow sticks rather than barley.
- Density, spacing and plant size expose the procedural pattern immediately.
- Headlands and the paired tractor tramlines are not visually convincing.
- The crop style does not match the painterly buildings, grass or orchard.
- The player is visually lost among the repeated stalk marks.

## Accessibility risks visible in the captures

- Round and diamond player markers are a good non-colour identity cue.
- The split divider has strong contrast and a clear boundary.
- Farmers are small and have inconsistent contrast against grass, gravel and mature crops.
- The TV view has no persistent objective or partner-location assistance.
- Helper copy on the joining card may be small at sofa distance, although the QR code and room code are strong.
- Keyboard focus, screen-reader semantics, controller target sizes, motion comfort and timing require separate testing.

## Recommended correction order

1. Replace the crop drawing with authored staged barley clusters, restrained density, headlands and two clear tractor tramlines.
2. Build a perspective-consistent boundary kit with continuous hedge/wall runs, real corners and open gate modules.
3. Add authored lane edges, junctions, yard aprons and terrain-transition masks; eliminate rounded dead ends and triangular overlaps.
4. Normalize the workshop/feed-store scale and raise farmer presentation to roughly 48–56 screen pixels at the normal 720p camera.
5. Compose the yard into functional zones using a limited set of purposeful props: parking, repair, animal care, grain and dispatch.
6. Replace the geometric bridge/ford and river banks with illustrated reusable sprites.
7. Add contextual destination, partner-direction and interaction markers before attaching incidents.

