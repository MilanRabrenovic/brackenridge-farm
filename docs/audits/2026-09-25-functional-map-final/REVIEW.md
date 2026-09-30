# Functional production-map review

Date: 2026-09-25

## Result

The active 2D estate now gives every committed hackathon activity a deliberate, reachable location. The map is suitable as the stable physical baseline for incident development: central work yard, animal pasture, barley field, orchard/apiary, packing area, grain intake, dispatch lay-by and two river crossings are connected and remain readable in shared and split cameras.

## Captures inspected

- `01-working-yard.png` — scale, open manoeuvring court, tractor, trailer, repair parts, grain grate and contextual labels.
- `02-pasture.png` — pasture route, open gate, five sheep anchors, boundary collision and edge-safe camera.
- `03-orchard-dispatch.png` — apiary, orchard rows, packing court, dispatch van and delivery route.
- `04-operational-split.png` — barley gate and dispatch shown simultaneously with the farm-themed split divider.
- `05-overview.png` — full estate composition and route continuity.

All captures are native 1280 × 720 Godot renders from the active runtime world.

## Functional evidence

- Ten data-driven destinations are queryable by id and position.
- A nearby player sees the destination label; the contextual phone action reports its purpose.
- Operational objects are separate named nodes, so incidents can replace or animate them without repainting terrain.
- Camera targets clamp to the playable surface at north, south, east and west destinations.
- Building, tree, boundary, stream and world-edge collision remain active; bridge and ford gaps remain passable.

## Verification

- `npm run typecheck` — passed.
- `npm run test:2d` — passed, including operational props and contextual destinations.
- `arch -arm64 /usr/local/bin/node --import tsx --test tests/*.test.ts` — 9/9 passed.
- `npm run export:web` — passed.
- Godot relay integration — passed at 18.7 ms; two-player private clues, screen axes and tractor phone mode verified.
- Exported browser host — lobby, QR and revised world rendered; no warnings or errors in the browser console.

## Remaining scope

This review freezes the map footprint. It does not approve every asset as final art or implement the incidents. Static sheep, trailer, van, apiary and work props now provide the anchors for those systems. Weather surface variants, movable gates, animal simulation, grain load states and vehicle attachments remain gameplay work.
