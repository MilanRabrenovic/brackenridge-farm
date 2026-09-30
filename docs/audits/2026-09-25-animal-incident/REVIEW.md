# Guide-and-gate animal incident review

Date: 2026-09-25

## Result

The active 2D host now contains one complete asymmetric incident. Five sheep escape into the meadow. Player one receives the private herding rule and guides them from the far side. Player two receives the gate-latch constraint, stands in the marked gate zone and holds the phone action while the flock crosses. The television shows a 1:45 countdown, returned count, current gate state and success or failure.

## Native 1280 × 720 evidence

- `01-active-guide-and-gate.png` — shared close camera with flock, both farmers, objective panel, gate marker and visible held-gate feedback.
- `02-separated-flock-view.png` — adaptive split camera with the herder near the flock, the gate keeper at the pasture and the farm-themed divider.

Both captures were inspected at their native gameplay scale. The objective remains readable without hiding the herding route, and the two required roles remain understandable in split screen. The ordinary pasture destination label is suppressed during the incident so it does not compete with the gate instruction.

## Verification

- `npm run typecheck` — passed.
- `npm run test:2d` — passed, including sustained gate hold and a deterministic route returning all five sheep.
- Arm64 Node suite — nine tests passed.
- `npm run export:web` — passed; the export includes `animal_incident_2d.gdc`.
- Godot relay integration — passed at 19.9 ms with FLOCK/GATE clues, 1:45 deadline, screen axes and tractor controller mode.
- Exported browser host — rendered with no warnings or errors.

## Remaining acceptance work

The interaction is mechanically complete and deterministically verified. Sheep steering radius, movement speed and the 1:45 allowance still need a structured physical two-phone playtest. The sheep sprites and static gate art remain review assets rather than final approved production art; weather wind and audio are not yet presented.
