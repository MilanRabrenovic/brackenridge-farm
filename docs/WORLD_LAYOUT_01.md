# World Layout 01 — Central Yard Loop

Status note, 2026-09-24: this early `120 × 80 metre` layout is superseded by the measured `170 × 120 metre` topology in [`game/data/world_layout.json`](../game/data/world_layout.json) and the layered implementation contract in [`2D_WORLD_PRODUCTION_PLAN.md`](2D_WORLD_PRODUCTION_PLAN.md). Retain this page only as historical reasoning for the central loop.

![Central Yard Loop](concepts/world-layout-01-central-yard-loop.png)

This is a buildable level layout, not a visual mood reference. The concept render and the coordinates below describe the same playable world.

## Coordinate system

- Playable footprint: approximately `120 × 80` Godot metres.
- World centre: `(X 0, Z 0)` in the farmyard.
- North is negative Z; south is positive Z.
- Typical farmhand height: `1.7 m`.
- Main vehicle track: `5 m` wide.
- Foot shortcuts: `2.5–3 m` wide.
- Vehicle gates: at least `5 m` clear width.

## Camera

- Orthographic shared camera.
- Yaw: approximately `45°`.
- Downward pitch: approximately `48°`.
- Initial target: `(0, 0, 0)`.
- Initial orthographic size: tune around `95–105` so the complete boundary fits at 16:9.
- Buildings keep their tallest rooflines toward the north and east, away from critical foreground routes.

## Gameplay districts

| District | Approximate centre | Footprint | Purpose |
| --- | ---: | ---: | --- |
| Central yard | `(0, 0)` | `50 × 30` oval | Spawn, coordination, turning space, shared incidents |
| Workshop and vehicle apron | `(-42, 1)` | `28 × 22` | Tractor, combine, trailer, fuel and repairs |
| Barn and handling pen | `(34, -2)` | `28 × 22` | Feed, animals, gates and storage |
| Hay meadow | `(-38, -28)` | `35 × 22` | Hay, wind and collection tasks |
| Livestock pasture | `(0, -29)` | `30 × 22` | Movable temporary paddocks and animal incidents |
| Arable field | `(39, -28)` | `39 × 24` | Combine, crop and weather tasks |
| Orchard and apiary | `(48, 8)` | `20 × 24` | Bees, fruit, pond and careful handling tasks |
| Produce loading | `(4, 24)` | `32 × 14` | Order assembly, crates and loading equipment |
| Delivery entrance | `(43, 33)` | `25 × 12` | Van arrival, deadlines and blocked-access events |
| Stream and crossings | `(-35, 29)` | Southwest edge | Bridge, muddy ford and route disruption |

## Route graph

The main vehicle loop follows these approximate waypoints:

```text
Yard (-12, 0)
→ Workshop (-42, 0)
→ Hay gate (-31, -17)
→ Livestock gate (0, -17)
→ Crop gate (29, -17)
→ Orchard lane (48, 4)
→ Delivery gate (43, 30)
→ Loading yard (10, 22)
→ Yard (0, 10)
```

Two shortcuts prevent every incident from using the same route:

1. A narrow barn-to-crop path between `(25, -8)` and `(28, -20)`.
2. A muddy on-foot ford between approximately `(-18, 25)` and `(-8, 34)`.

The stone bridge around `(-43, 22)` remains the reliable vehicle crossing. Weather can slow or close the ford without blocking the entire map.

## Placement rules

- Vehicles always begin on the workshop apron, never scattered across fields.
- Produce crates originate under the southern loading canopy.
- Sheep begin in the north pasture and can be moved through gates to the hay meadow or barn pen.
- Bee equipment stays in the orchard/apiary district.
- Every operational field has two exits.
- Decorative trees stay outside route sightlines.
- Distant hills extend the perceived farm size but remain inaccessible.
- Incidents may combine districts, but no single incident owns the world.

## First implementation slice

Build the terrain footprint, central yard, workshop block, barn block, three northern fields, main loop, gates, stream crossings and southern delivery entrance as greybox geometry. The same scene then receives modular final assets without redesigning the topology.
