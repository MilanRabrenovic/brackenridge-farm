# Completion audit — September 30, 2026

The objective remains the finished committed hackathon game, including tested browser and Fire OS deliverables. Packaging or seeded unit tests are insufficient proof of complete device playability.

| Requirement | Evidence | Scope / remaining gap |
|---|---|---|
| Coherent original farm and map | Authored `world_layout.json`, layered production renderer, native/browser review captures, 468 route-envelope samples and ten connected interaction destinations | Local placement/rendering reviewed. Final TV rendering and user visual acceptance remain open. |
| Complete asymmetric weekend | `weekend_session_2d.gd`; arrival, sheep, planning, repair, weather, dispatch, results/replay. Three scripted success routes and failure recovery tested | Some actors are positioned directly in tests. No complete two-human phone-controlled run this pass. |
| Movement, collision, occlusion | 2D host/map tests; real relay screen-axis input; browser phone quick-tap tractor entry/exit | Native/browser evidence. Device movement/performance unverified. |
| Walking/vehicle animation | Directional walk sheets, foot anchors, four upright tractor views, side wheels and suspension; native captures/assertions | No authored carry/repair/boarding or sheep gait sheets. These are explicit deferred scope, not claimed implemented. |
| Farming/interiors | Soil preparation/sowing/growth/harvest states, tramline gaps, storage; measured structural cutaways and two-occupant repair test | Compact abstraction. No spraying/attachments/drivable combine. |
| Two-phone controls/private facts | Relay/admission/reconnect tests; distinct private cards; tractor dashboard; quick-tap buffer; disconnect pause | Browser/native integration passed. Real Wi-Fi whole-run and TV admission/replay still required. |
| Fire OS deliverable | APK export and v2/v3 signing verification | No physical Fire OS device connected. Runtime, remote, QR, split/crop performance and device audio untested. |
| Vega supplementary route | Debug/release packages, scoped HTTP policy, loopback reverse forwarding, actual PCK/WASM/worklet downloads and Godot room creation | Simulation startup proven. Full rendering/remote/playthrough/recording unverified. |
| Phone-controlled TV inactivity | Supported `useSetTimeoutCallback(1800)` in wrapper; lint, TypeScript, template render test and debug/release builds passed; component reported running >2 minutes after launch | This requests component timeout only. Full 15-minute play and hardware sleep behavior not proven. |
| Release packaging | Source ZIP CRC/exclusion checks and four artifact SHA-256 hashes | Rebuild the source ZIP/hash manifest after document/code changes. |
| Truthful hackathon instructions | `docs/SUBMISSION.md`, `USEFUL_COMMANDS.md`, provenance/notices and explicit limitations | No qualifying video, repository publication or submitted entry. |

## Next acceptance action

Connect a physical Fire TV and play the prepared Fire OS APK with two phones, or establish usable full rendering/remote inspection on the Vega simulator. Run a complete successful weekend and failure/recovery/replay, then record qualifying footage. The existing Mac/browser evidence cannot substitute for these device checks.

Final acceptance blocker: with the component active, the documented framebuffer capture again remained running without an image and was cancelled after the diagnostic deadline. The inspector endpoint returned an empty response. No physical Fire OS device is connected and no two-human full device run or qualifying footage exists. These external verification gates remain unresolved across three goal turns; the finish goal is blocked, not complete. Resume once a usable device/view and playtest evidence are available.

## Solo-first testing decision

The user explicitly deferred real two-player acceptance until final integration. Full solo testing is now available, with normal mission deadlines and no mature-crop shortcut. `test:solo` completed all five sheep, repair, tractor field access, seven natural crop stages, storage, apple covering, packing, delivery/results/replay through real physics movement. It uses accelerated simulation and explicit planning waits; human pacing and device rendering remain separate checks. Continue solo browser review now; the earlier external acceptance blocker does not prevent local implementation.

The full solo route now also passes via received input packets and normal host ticks, including quick down/up ACTION/EXIT messages. Solo disconnect freeze, reconnect resume and preserving manual pause are asserted. Whole-route real browser/network and physical TV execution remain separate evidence gaps.

Crop progression now provides current-step objectives, cell/growth progress and field/intake/apiary markers. Regression assertions check cultivation/storage instructions and that the partner's storage card is preserved. This improves first-play clarity; it does not replace human usability or TV acceptance.

## Seeded repair audit

Corrected a repeat-play gap: variants now select belt/slipping drive or gasket/leaking pump, with mechanic-only diagnosis and runner supply locations. Both correct and wrong-part cases/privacy passed, as did the complete solo/weekend regressions. Staged solo wording views were inspected. This is bounded incident variation, not an adaptive AI Director or additional incident category. No new TV/human/publication evidence exists.

Source handoff is prepared in an isolated local Git snapshot. GitHub authentication was verified, proposed repository absence confirmed and a scoped credential-pattern scan passed. Public/private creation and push remain pending; no repository URL or submitted entry is claimed.
