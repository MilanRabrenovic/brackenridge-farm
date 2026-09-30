# Full solo motor route — September 30, 2026

`test_solo_playthrough.gd -- --capture` produced these native game frames during an accelerated scripted run using the actual walker/tractor motors and real collision space. No actor teleports or direct crop state changes. The run herded five sheep, repaired equipment, grew/harvested/stored barley, covered apples, carried two correct loads, delivered and reached results. Two planning waits were advanced explicitly. Results report about 4:30 simulated time.

Inspected repair, harvest and results. Fixed objective feedback overflowing the screen and removed the duplicate repair marker; repeated the rendered route and screen-bounds assertion. These frames prove local scripted behavior/rendering, not human pacing, fun, TV compatibility or qualifying demo footage.

The subsequent input-pipeline pass replaced direct motor/action calls with received movement packets, buffered down/up taps and the normal host simulation tick. The route also verifies solo disconnect freezes, reconnect resumes and manual pause is preserved. The captures were regenerated during the native input-pipeline route and successful results report 4:28 simulated time. The disconnect assertions inject roster messages, so these are not screenshots of a physical phone-loss test.

The crop-guidance pass regenerated arrival, cultivation, repair, harvest/storage and results captures. Inspected cultivation instructions and the post-harvest EXIT/storage objective. The full route and screen-bounds assertions passed; a transient observation delay was followed by completion of the same process.

`repair-belt.png` and `repair-gasket.png` are staged solo wording reviews from `capture_repair_variants.gd`. Each variant is forced in the same scene; neither is a complete or normally seeded playthrough. Both were inspected at gameplay scale.
