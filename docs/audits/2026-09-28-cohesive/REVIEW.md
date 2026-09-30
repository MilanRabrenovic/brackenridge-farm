# Cohesive farm runtime review — 2026-09-28

Inspected final yard, pasture, orchard, dispatch, unprepared overview, mature field, mature overview and split views through the native renderer. Browser export also visibly loaded the updated farm and QR lobby.

The dirt network joins the yard with feathered edges; turf no longer uses oversized leaves. Boundary crowns overlap, and riverbank reeds connect separate textured water and crossing sprites. Soil tint was corrected to avoid double texture multiplication. Mature barley remains separate sprites with tramline and machinery exclusions.

Known gaps: older building alpha speckles, repetitive perimeter trees, static gate art, large river ripples, and missing character work animations. This is closer to the approved composition but not a claim of visual parity or production readiness. The mature overview advances crop state for review only.

Checks: 468 clearance samples, host 2D suite, TypeScript, nine Node tests, relay 11.8 ms and Web export passed.

## 2026-09-28 — Sunlight and grounding polish

Added soft alpha-silhouette shadows cast southeast from static scenery, independent of actor y-sort. Contact shadows stay under actors; farmers now have foot shadows. Shortened the initial projection after native review to reduce detached-looking props. Added subtle crown-weighted tree/reed breeze, reduced yard pebble scale/contrast, and finer slower water texture motion. No collision, placement or incident rules changed.

Verification: native yard and split views inspected, eight capture views saved as `docs/audits/2026-09-28-cohesive/polish-*.png`; 2D host test and all 468 clearance samples pass; Web export succeeds. Initial inferred-type compile error was corrected before final checks. Fire TV performance, physical phone acceptance and final visual approval remain unverified. Shadows are economical 2D projections, not physically reconstructed building volumes. Legacy sprite speckles, repeated trees, directional vehicle art and missing work animations remain.


## 2026-09-28 — Sprite edges and ambient character polish

Applied a connected-alpha shader to existing structure sprites to suppress isolated extraction flecks while preserving source PNGs and reveal transparency. Varied peripheral tree spacing, scale, mirroring and tint, with fewer flowering trees; all variation is deterministic and outside functional routes. Added restrained idle breathing anchored at the feet and stick-speed-driven walking playback. These are presentation refinements, not new authored repair/carry/harvest frames.

Verified: 2D host suite and 468 physics route samples pass; native yard and overview inspected at 1280×720; eight `detail-*.png` captures saved under `docs/audits/2026-09-28-cohesive/`; Web export passed. Existing baked perspective, some connected sprite-edge noise and tree silhouette reuse remain visible. Fire TV performance remains unverified.


## 2026-09-28 — Reference-led foliage and meadow replacement

Used the built-in image-generation tool with the approved overview to create a coordinated rounded oak/oak variant, apple, blossom, willow and flowering hedge atlas, plus a meadow tile. Sources: `source_assets/2d/production/reference_foliage_v2.png` and `reference_meadow_v2.png`. Runtime derivatives are `reference_*.png`; extraction uses measured cells, preserves alpha and limits trees to 384px. User requested applying the reference as closely as possible; this coordinated derivative set is integrated for runtime review under that request, not separately claimed as visually approved.

Replaced sparse tree art, thickened connected boundaries (including overlapping crowns for vertical runs), blended flower meadow with short turf, and increased mature crop density while retaining readable tramline exclusions. Collision footprints, entrances, vehicle lanes and crop headland exclusion remain. No building reconstruction was completed in this pass: the existing structures were retained because the approved reference uses similar buildings. This pass addresses the conspicuous vegetation gap; composition parity is still incomplete.

Verification: 2D host suite, 468 clearance samples, TypeScript and Web export pass. Inspected native overview and yard and corrected sprite-cell bleed plus disconnected hedge stacking. Final captures: `docs/audits/2026-09-28-cohesive/reference-final-*.png`. Mature overview advances growth for review only. Hardware performance and physical two-phone acceptance remain unverified; higher crop sprite density needs Fire TV profiling.

Next task: review the new art at close gameplay scale with two phones, then author a coordinated building/apron scene and work animation set. Do not describe this as visual parity with the reference.


## 2026-09-28 — Coordinated buildings and connected yard

Replaced all six runtime structure illustrations with one coordinated source atlas: stone barn, sage machinery shed, workshop, feed store, twin silos and packing canopy. Clean silhouettes remove the previous floating extraction debris. Layout structure asset references select the new set while measured collision, entrances and reveal areas remain unchanged. Added facade-corner planting, kept centre entrances clear, and joined visual road bends with bounded curves. A separate opaque wear mask adds paired wheel wear along lanes and entrance-to-yard work routes; it cannot be stored in the ground mask alpha because texture import treats alpha as transparency.

Source: `source_assets/2d/production/reference_buildings_v3.png`. Optimized 512px assets: `game/assets/2d/production/reference_{barn,shed,workshop,feed,silos,packing}.png`. Rebuild: `npm run assets:buildings`; terrain mask: `npm run assets:cohesive`. Generated with the built-in image tool using the approved overview as reference. Applied under the user's explicit reference-matching request; final visual acceptance remains theirs.

Verification: inspected native yard, overview and bridge/apiary split; eight views saved as `docs/audits/2026-09-28-cohesive/estate-final-*.png`. 2D host suite, 468 clearance samples, TypeScript, nine Node tests and Web export pass. Relay regression passes at 23.3ms with private clues, screen directions and tractor phone mode.

The farm now translates the reference through independent ground, buildings, foliage, crops, props and actors. It is not pixel-identical: buildings are more front-facing, the playable yard/headland are broader for manoeuvring, trees repeat, river detail is simplified and character/work animations remain incomplete. Fire TV performance is unverified. No finished-game or hardware-ready claim.

Recommended next task: physical two-phone acceptance of the new farm, checking doorway visibility, vehicle clearance and split-camera readability, before adding more incident content.
