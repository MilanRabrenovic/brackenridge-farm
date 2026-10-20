# Fire TV eligibility correction

Updated October 20, 2026. **The organizer warning remains unresolved.** The user reports that Devpost is submitted and the music-only preview is uploaded. Those publication steps were not independently verified in this pass.

## Latest October 20 responsiveness result

The static-presentation optimized WebGL1 build now runs on the official emulator's host OpenGL backend with observed controller medians mostly 35–78 ms; startup frame samples showed 44–53.1 fps. These are scoped samples, not a full-game performance guarantee. Two private controllers, split/merge, cutaways and tractor driving were inspected in the guest. Use `--gpu host` (new launcher default); the earlier software-slowness/Metal-crash notes remain historical results for those different backends. Full strict Mac GLES2 routes and five wrapper tests/all Debug/Release targets passed. Evidence and exact limits: `docs/audits/2026-10-20-vega-performance/README.md` from project root. Genuine qualifying public footage, public candidate refresh and Devpost correction remain next.


## Required evidence

The [official rules](https://amazonappdev2026.devpost.com/rules) require the demo to show the project running on an actual Fire TV device or Fire TV/Vega simulator. Repository build files, an APK/VPKG, startup logs and Mac/browser footage alone do not meet that video requirement. Deadline: **October 23, 2026, 12:00 PDT / 21:00 Belgrade**. Put corrections into the submission form; the organizer's email thread is not submission evidence.

## Current status — local WebGL1 port, October 20

The original Godot 4 WebGL2 failure is bypassed by a maintained Godot 3.6.3 GLES2/WebGL1 compatibility port. Actual farm, QR, TV admission, two independent private controllers, walking, sheep event and tractor/dashboard/drive were inspected inside the confirmed official SDK 0.24.12112 guest. Simulation/rendering execute entirely in Vega; Mac hosts static assets and relays packets. This is not Mac streaming.

Sustained responsive play remains unresolved: software backends showed roughly 300–400 ms median controller frame acknowledgements; Metal ANGLE gave roughly 50–66 ms then the host emulator crashed signal 11. These are samples, not FPS. Full automated solo/co-op routes passed on Mac GLES2, not an entire actual Vega weekend. No physical Fire TV/human acceptance is claimed. Local packages under `artifacts/vega-gles2/` passed archive/hash checks but have not been published. See [port evidence](audits/2026-10-20-vega-port/README.md) and `platform/vega-gles2/README.md` for commands, backend limitations and licences.

No replacement qualifying video or Devpost correction was made. Existing public Mac preview remains a Mac preview; the organizer warning remains open until accurate platform footage/submission corrections are supplied. VS Code/Vega Studio are optional tools; the verified command-line route does not require them.

## October 20 genuine guest weekend and video

The actual Vega automated two-player route completed all four outcomes/results/replay with zero reported errors in 364.0233 elapsed seconds. A 111-second OBS simulator-window demo is rendered and checked; YouTube draft awaits user audience/publication confirmation. Source/candidate refresh and the actual Devpost correction are still required. This does not guarantee eligibility or physical TV acceptance. See `DEMO_VIDEO.md` for exact provenance and later host-mode simulator crash caveat. Ordinary package URL was restored and QR lobby verified.

## Run this candidate

Use `platform/vega-gles2/README.md`. Keep the relay and exactly one official simulator running, use reverse forwarding for 8787, install the current aarch64 Release package and scan its current QR. Select admits phones. Software graphics are the slower fallback; do not represent the Metal backend as stable. Do not run older/newer images together on shared device ports.

## Qualifying recording — up to two minutes

Record the real display, not a Mac gameplay window framed to look like a simulator. Show simulator identity or the physical Fire TV at the beginning.

1. **0:00–0:15:** actual platform/app launch, QR and joined phones; explain family co-op, two players now.
2. **0:15–0:40:** farmer movement and sheep/gate teamwork, with different private facts.
3. **0:40–1:05:** repair diagnosis and partner's part/pressure task; show why communication matters.
4. **1:05–1:30:** tractor controls on the phone and crop work/growth; show split/merge camera.
5. **1:30–1:50:** loading/delivery and shared results, using cuts from actual play.
6. **1:50–2:00:** replay and “Four-player family play planned.”

Use the new CC0 quiet ambience and English captions; no synthetic narration. Disclose any accelerated or automated inputs. Full sustained performance and a human playtest must not be inferred from a short edited demo.

## Devpost correction text — use only AFTER the new footage exists

Replace the bracketed fields with verified facts; do not paste this as a completed claim before recording.

> Brackenridge Farm is a family co-op game built for Fire TV. The updated demo shows the game running on [actual device and Fire OS version OR official Vega simulator and SDK version], with phones providing controls and private role information. The TV hosts the shared farm simulation and adaptive shared/split cameras. The current game supports two players; four-player family play is planned. Source, platform setup instructions and downloadable candidate builds are available in the linked public repository. The Vega developer setup uses a laptop relay with reverse port forwarding.
>
> Qualifying platform demo: [new public YouTube URL].

Update the main video field, Built with tags (Fire OS or Vega OS only as actually demonstrated), platform/testing explanation and try-it/code links. Review the public preview and verify video visibility. An email reply alone is insufficient. Any final acceptance of submission terms is the entrant's action.

## Accurate current product-friction text

> On this Apple Silicon setup, Vega SDK 0.24.12112's tested WebView exposes WebGL1 but fails WebGL2 context creation. Our Godot 3 GLES2 compatibility port now runs real gameplay locally in the guest. Software simulator backends have high controller acknowledgement latency, while the faster bundled Metal ANGLE backend later crashed the host emulator with signal 11. A stable accelerated WebView path and clearer supported WebGL capability diagnostics would help. Sustained full-game performance has not passed.

Hardware-free local guest execution is the user requirement. Mac streaming and borrowing hardware were rejected. An older SDK was installed side by side but is not an established solution. Clean newer-image observations supersede ambiguous overlapping-device tests.