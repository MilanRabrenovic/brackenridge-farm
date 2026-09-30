# Map placement review — 28 September 2026

## Scope and verdict

Reviewed fresh 1280 × 720 native gameplay captures, corrected the layout and inspected the resulting map. The map has verified route clearance and destination connectivity. It still needs art finishing before production release; passing placement checks is not visual approval.

## Review steps

1. **Working yard — corrected.** `before-yard.png` showed crowded repair props, a disconnected field approach and excessive labels. `after-yard.png` has deliberate repair/feed/grain zones, a clear central court, repositioned machinery shed and closer-range labels.
2. **Pasture — usable with art limitations.** `after-pasture.png` places water in the livestock field and sizes gate art to its opening. The gate is still a static illustration; it needs separate open/closed art. Existing sheep incident regression passes.
3. **Orchard — corrected.** `before-orchard.png` showed trees covering the path and hives. `after-orchard.png` has clear tree rows, visible hives and an eastern path through a real southern hedge opening.
4. **Packing and dispatch — corrected.** `before-dispatch.png` showed the van on the through lane and crates hidden by the canopy. `after-dispatch.png` places produce beside the canopy and parks the van south of the lane, leaving the route open.
5. **Whole estate — corrected framing.** `after-overview.png` shows the whole footprint. Structure, prop, tree and boundary coordinates now come from layout v5 instead of separate hardcoded placements.
6. **Mature crop — corrected access.** `after-mature-field.png` shows the heavy approach and turning lane clear of growing plants. The previous tree was moved out of the crop. Machinery corridors are excluded from cultivation and planting.
7. **River and split camera — corrected access.** `after-split.png` shows the bridge and apiary simultaneously. Bridge approaches follow the deck, the meadow wall has a matching gap, and a separate path reaches the ford. Actual water collision now permits only these crossings.

## Verification

- `npm run test:map`: 468 samples along roads at walker, tractor or combine clearance; zero blocked samples. All ten interaction points are clear and connected to the yard by a flood through actual physics space.
- `npm run test:2d`: crop lifecycle, buildings, animated players, cameras, destinations and complete sheep incident passed.
- TypeScript and all nine Node tests passed. Network tests needed permission to bind a local loopback server.
- Relay integration passed at 30.4 ms with private clues, screen axes and tractor mode.
- Web export and map-plan regeneration passed. Updated browser host opened and displayed the farm and QR panel.

## Remaining visual and accessibility risks

- Grass texture seams, repetitive hedge modules, hard terrain transitions and flat water are still visible. These need a coordinated art pass, not more scattered props.
- Gate artwork does not yet show its changing state. Do not rely on the static gate image alone to explain passability.
- Close-view labels are readable and appear at shorter distances, but may still cover small objects. Sofa-distance readability and physical Fire TV performance remain unverified.
- Screenshots do not establish controller accessibility or final difficulty. A physical two-phone test is still needed.

Reproduce the after captures with `npm run review:map`. Existing art remains at its previously recorded review status.
