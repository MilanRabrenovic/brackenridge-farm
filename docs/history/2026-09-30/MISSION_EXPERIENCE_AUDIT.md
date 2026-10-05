# Historical baseline audit — before mission improvements

Original September 30 findings. The image paths below now contain refreshed implementation captures, so they are not evidence of the old appearance.

# Mission experience audit — September 30, 2026

## Verdict

The weekend is mechanically completable, but **the current mission design is not yet strong enough to call clear, engaging or ready for first-time judges**. The farm and directional tractor are appealing. Herding, private repair diagnosis and parallel crop/protection jobs provide a useful foundation. The main problems are passive partner roles, a meaningless second purchase decision, weak feedback between missions, and farming that changes the whole field after a short arbitrary route.

This is an expert walkthrough supported by fresh rendering, input-route regression and source inspection. It is not a human fun study. No entertainment rating, child preference, real two-human pacing or TV readability has been measured.

## Current-run evidence

- Native `test_solo_playthrough.gd -- --capture` passed: real input-handler/physics movement, five sheep, correct part, tractor access, natural crop stages, grain storage, apple covering, two carried loads, dispatch/results/replay. 221.5 seconds of input simulation plus two explicitly advanced 26-second planning waits; results rendered at 4:33 simulated time. Accelerated execution is not a typical human completion time.
- `npm run test:weekend` passed three scripted cooperative routes, wrong goods, joint loading, failure recovery, solo repair and 1000 stable seed selections. Some cooperative test interactions position actors directly. Restricted macOS log/certificate warnings remain; the check exited successfully.
- Captured and inspected eight current cooperative screens at 1280×720 using `capture_mission_audit.gd`. Actors/outcomes are staged for readability. The staged result's zero elapsed/contributions are fixture values, not a completed run. Private cards were saved alongside images. Actual solo results were separately inspected.
- No game behavior or balancing changed in this audit. No new art was generated. Browser whole-route networking, human cooperative experience and TV execution remain separate gaps.

## Flow review

### 1. Arrival — understandable destination, weak confirmation

![Arrival](audits/2026-09-30-missions/01-arrival.png)

The CHECK HAY marker and short objective show where to go. Phone 1 explains movement and tractor entry. Phone 2 says “follow the blue marker,” which describes its identity rather than a destination. Checking hay shortens the clock to eight seconds, but does not acknowledge success or replace the objective. The tractor lesson is optional; a timeout advances even if neither player learns it. A first-time player can reasonably think ACTION did nothing.

### 2. Sheep — strongest immediate activity, passive gate role

![Sheep](audits/2026-09-30-missions/02-sheep.png)

Visible sheep, a marked gate and 0/5 progress make the objective concrete. Herding creates spatial decisions. The partner's mandatory continuous hold can last most of a 150–170-second deadline; after finding the gate, that player has little to decide. This is a likely boredom risk, not an observed human reaction. Consider short latch windows or role handoffs inside this same incident, preserving the shared problem.

### 3. First planning — useful tradeoff, incomplete affordance

![First planning](audits/2026-09-30-missions/03-planning_gate.png)

Rain covers and maintenance affect later work, so this decision can have meaning. However, the code chooses on one update tick with both ACTION inputs true; “hold” does not have a confirmation duration or visible progress. Already-owned upgrades are not excluded. An expired sheep gate marker remains visible during this phase. Show the benefit, ownership and confirmation explicitly, and clear completed-event markers.

### 4. Repair — clear communication hook, limited activity

![Repair](audits/2026-09-30-missions/04-repair.png)

Different private cards genuinely require the runner to ask the mechanic which part is needed. Wrong-part rejection and fitting progress are useful. The mechanic then waits for the runner and holds for six seconds. The diagnosis is already supplied before inspecting, so inspection is an acknowledgement rather than discovery. There is no visible broken-to-fixed machinery transformation or meaningful downstream dispatch penalty for a failed repair. Keep the two clues, but give inspection and completion visible consequences.

### 5. Weather and farming — best spectacle, poor work balance

![Weather](audits/2026-09-30-missions/05-weather.png)

Growing crops, the tractor, rain and parallel locations offer the best visual variety. Step-specific cultivation/sowing/harvest instructions are readable. However:

- The driver does most of the work. The partner's apple job needs only six seconds (three with covers), plus travel/storage, within a 210-second event. They can help store grain, but the design does not sustain their participation.
- Each preparation/sowing/harvest phase changes the **entire field** after 16 distinct 28-pixel cells. These are a small portion of the field, not 16 marked farming rows. The next operation begins automatically. Players can complete sowing/harvesting while still following an earlier route; in the current solo test the field was already harvested at the end of the nominal sowing route.
- A count without marked target strips does not teach which ground remains unfinished. The result can feel like a hidden trigger rather than farming.
- When barley grows, the instruction is to wait; there is no coordinated side job directed at that driver.
- Apple-cover progress is accumulated, but not visually represented until grain storage changes the main objective. “Hold at apiary” also needs a visible apple/cover target to explain why fruit is being protected there.

Use a few clearly visible work strips with individual completion, explicit operation handoffs, and a partner task that matters throughout the event. Preserve the separate forecast/storage information. Do not inflate the number of required passes simply to lengthen the game.

### 6. Second planning — confirmed broken design decision

![Second planning](audits/2026-09-30-missions/06-planning_machine.png)

It offers the same shelter/maintenance purchases **after both repair and weather have ended**. Those flags affect only fitting and covering, which never recur before results. A £20 purchase therefore has no remaining gameplay benefit. Buying the same upgrade twice still deducts money. Replace this phase with a decision that affects the upcoming dispatch, or omit the purchase and use a short buyer briefing. This is the highest-priority confirmed design defect.

### 7. Dispatch — clear finish, unnecessary guesswork

![Dispatch](audits/2026-09-30-missions/07-dispatch.png)

PACKED 0/2, an identifiable van and a joint final hold provide a finish. Buyer and stock facts differ between phones. However, the marker always targets packing, even when hands are empty and players must first find a store. Collecting a load replaces the private clue with “carrying…”; the original buyer/stock fact cannot be reopened. After the first load is packed, the message tells players to take another even if only their partner needs to carry it. Wrong-goods feedback mentions dry stock even when the actual reason is a buyer's apple preference. Add a persistent clue and a separate current-action hint; guide collect → pack → van, and explain rejection accurately.

### 8. Results — readable recap, weak payoff

![Results](audits/2026-09-30-missions/08-results.png)

The recap and replay button are readable and all four outcomes are present. The heading depends only on dispatch success, so a farm can receive “flourishing” after other missions fail. “Contributions” are not a fair effort measure: sharing clues and repeated intake ACTION can inflate them, while tractor cultivation contributes no comparable count. In solo, “Mechanic: 0” reads like poor performance even though it is an assisted run. Use task-based recognition, distinguish helper participation, and celebrate actual team outcomes rather than raw input counts.

## Cross-mission findings

1. **Results are overwritten in the same simulation update.** Sheep completion immediately enters planning; repair immediately enters weather. Success/failure copy in the incident handlers is not given a readable interval. The handlers also contain obsolete “explore/replay” and “next repair in eight seconds” language. Add a short result beat and clear next-job briefing; do not stop the flow with a large blocking dialog.
2. **Failures are safe but weakly consequential.** Reserve apples prevent dead ends, which is good. However, apple protection is set true on any weather exit and two apple loads are always available. Repair failure has no material later operational effect. Recoverable consequences should change the next task or reward rather than simply report a different recap.
3. **Attention arrives late.** The opening asks players to check hay, without a clear shared weekend goal or immediate small cooperative success. Give a one-sentence farm stakes introduction and an acknowledged action before the first escape. Exact attention retention remains a human measurement.
4. **Spatial clues can leave the viewport.** The barley marker was partially clipped in the split capture. The shared objective covers a substantial part of the right player's view. Verify per-player target direction and panel placement while travelling; a split screen needs each farmer to know its next destination.

## Accessibility and evidence limits

Text has strong visual separation from the background in these captures. Marker shapes distinguish farmers as well as colour. These strengths do not prove accessibility compliance. Reading speed, child comprehension, sustained ACTION hold, phone-to-TV glance switching, motion tolerance, target sizes at actual TV distance and screen-reader behavior need dedicated testing. The game pauses, but fixed deadlines still require comprehension under pressure.

## Recommended implementation order

1. Correct the second planning decision, purchase ownership/confirmation, missing hay acknowledgement and instant mission-result overwrite.
2. Keep both players meaningfully active during weather; make field work visible and deliberate instead of whole-field automatic switches.
3. Preserve private clues alongside short current-action instructions; guide store/packing/van and show covering/fitting feedback in context.
4. Make outcomes affect the following task/reward and improve team recognition. Stay within the four existing incident families.
5. Run one novice solo session for navigation/control clarity, then a two-person session. Record time to understand each objective, wrong turns, idle periods, help requests and replay interest. Do not explain tasks aloud unless they are stuck; record those interventions. These human checks are the evidence needed to claim fun and clarity.

**Single next task:** implement item 1, with tests that prove the late purchase has a real dispatch consequence or is removed, duplicate spending cannot occur, and task acknowledgement/results remain visible.
