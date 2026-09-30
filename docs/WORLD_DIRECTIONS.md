# World visual directions

Status note, 2026-09-24: these remain mood and composition references from the earlier 3D phase. The active game is 2D; use [`ART_DIRECTION.md`](../ART_DIRECTION.md), [`2D_WORLD_PRODUCTION_PLAN.md`](2D_WORLD_PRODUCTION_PLAN.md) and [`ASSET_CATALOG.md`](../ASSET_CATALOG.md) before producing or integrating environment art.

These concepts establish composition, camera, material language, and world density. They are original targets for a modular Godot environment, not images to copy literally or ship as game assets.

## Direction 1 — Pastoral Miniature

![Pastoral Miniature](concepts/world-01-pastoral-miniature.png)

- Most picturesque and lush.
- Strong sense of a large, prosperous English farm.
- Highest environment-production cost because of dense vegetation and small detail.
- Best reference for distant scenery, streams, bridges, and the warm countryside mood.

## Direction 2 — Carved Countryside

![Carved Countryside](concepts/world-02-carved-countryside.png)

- Chunkier buildings, fields, characters, and props.
- Clearest gameplay routes and interaction points.
- Tactile painted-wood and clay character gives the project a more original identity.
- Most achievable baseline for a polished Fire TV vertical slice.

## Direction 3 — Weathered Patchwork

![Weathered Patchwork](concepts/world-03-weathered-patchwork.png)

- Strongest contrast between peaceful farm and incoming chaos.
- Large field shapes remain readable while weather changes.
- Best reference for the Chaos Director's visual storytelling: moving shadows, rain fronts, mud, and changing light.
- Slightly more dramatic and less cosy than Direction 2.

## Recommended combination

Translate Direction 2's clear shapes, paths and material simplicity into the active hand-painted 2D style. Add Direction 3's cloud shadows and weather contrast. Borrow Direction 1's distant layered fields and stream-side beauty sparingly.

The playable farm remains compact around the central yard while decorative hills and fields create the impression of a much larger estate.

## Adaptive phone controller

The controller keeps a stable frame so players retain muscle memory:

- Player identity, connection, and private information at the top.
- Movement control in the same lower-left position.
- One large contextual control area on the lower right.
- Mode name and one-line instruction when the activity changes.

The contextual area changes with the player's activity:

| Mode | Movement | Context controls | Private phone value |
| --- | --- | --- | --- |
| On foot | Joystick | Interact, carry, drop | Role clues and task information |
| Tractor | Steering control | Throttle, brake, attach | Fuel, fault warning, route constraint |
| Combine | Steering control | Engage header, unload | Crop moisture, grain level, quality risk |
| Animal handling | Joystick | Whistle or guide | Flock stress, target field, gate warning |
| Beekeeping | Careful touch movement | Smoker and collect | Hive mood, weather risk, correct hive |
| Repair | Joystick or part selector | Inspect, fit, tighten | Fault diagnosis and required part |

The host tells each phone which mode to show. A player entering a vehicle changes only that player's controller. Activities should also expose useful private information; changing button art alone would make the phone feel like a decorative gamepad.

Touch remains the primary input. Haptics can confirm engine strain, collisions, successful repairs, or angry bees, but accelerometer controls should remain optional.
