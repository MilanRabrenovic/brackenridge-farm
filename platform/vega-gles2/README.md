# Vega WebGL1 compatibility build

The normal game remains Godot 4 in `game/`. Vega's tested WebView cannot create its required WebGL2 context, so this route generates a **Godot 3.6.3 GLES2/WebGL1** project from the same active 2D source. Simulation, rendering, collisions, cameras and missions run in Vega's WebView. The Mac serves static assets and relays phone packets; it does not run or stream the game's simulation.

## Build

Install the official [Godot 3.6.3 editor and export templates](https://godotengine.org/download/archive/3.6.3-stable/), and verify their official SHA-512 sums. This machine stores the editor at `.tools/godot3/Godot.app/Contents/MacOS/Godot` and the extracted template at `.tools/godot3/templates/webassembly_release.zip`. Other installations can set `GODOT3_BIN` and `GODOT3_WEB_TEMPLATE`.

From the project root:

```sh
npm run test:vega-gles2
npm run export:vega-gles2
npm run dev
node scripts/configure-vega.mjs http://127.0.0.1:8787/host/vega-gles2/index.html
```

The generated editor project is `build/vega-gles2-source/`; do not edit it. `prepare.py`, `patch.py`, `normalise.py` and `compat/` are the maintained adapter. Export is served at `/host/vega-gles2/index.html`. The normal `/host/` route stays Godot 4.

Then, in `platform/vega`, run the established `vega exec npm run build:release` command. Rebuilding only native packaging may reuse stale JavaScript.

## Simulator

Create a virtual device once using Amazon's official CLI. Stop it before changing graphics backends. The project's launcher uses an existing official image/instance and the SDK's bundled graphics libraries:

```sh
python3 scripts/start-vega-simulator.py \
  --sdk-root .tools/vega-sdk/vega-sdk/main/0.24.12112 \
  --gpu host
```

This is the tested Apple Silicon setup; it is not a general claim for every platform. If more than one instance exists, pass its directory with `--instance`. The launcher refuses a busy device port; keep its terminal open and use Ctrl+C to stop its owned child. `host` is now the locally tested responsive default; `swiftshader_indirect` remains a slower fallback. `angle_indirect` reduced latency but the host emulator later crashed (signal 11), so it is not the stable recommendation. `swangle_indirect` also rendered two-player gameplay but was similarly slow in the short check. Neither command modifies SDK/image files.

In another terminal, after the device is connected:

```sh
vega exec vda reverse tcp:8787 tcp:8787
vega run-app platform/vega/build/aarch64-release/brackenridgefarm_aarch64.vpkg com.brackenridge.farm.main -d VirtualDevice
```

Phones use the same Wi-Fi and the current QR. TV Enter/Select admits them. For a browser-only two-controller test, use separate browser profiles/engines or separate `127.0.0.1` / `localhost` origins: tabs in one profile share a reconnect token and represent the same phone.

## Verification and limits

See `docs/audits/2026-10-20-vega-port/`. Strict test runs reject script/renderer errors even if the engine exits zero. Reused tests cover complete mission success/failure/private information, map and animation state, and full solo/co-op input/physics routes through results/replay. Those automated routes run on the Mac's GLES2 renderer; they are not full Vega playthroughs or human fun tests. Actual Vega lobby, admission, phone movement and events have been visually inspected separately.

No gameplay scope or world art is added by the port. Godot 3's font lifetime, colour format, layout aliases, physics/socket APIs, camera zoom and shader uniform limitations are adapted explicitly. Only a visible, working test on the actual simulator counts as platform evidence. Physical Fire TV performance and the revised public demo/submission remain separate acceptance items.

Noto Sans is distributed under the included SIL Open Font License in `fonts/OFL.txt`.

Local packaged candidates and checksums are in `artifacts/vega-gles2/`; Web ZIP preserves `build/web/vega-gles2/` under project root. They are not published and do not replace sustained runtime acceptance.

## Static presentation cache / measured host backend

The builder bakes unchanged static terrain at 2040×1440 and existing alpha cleanup into six independent building images. A separate river shader retains motion and is clipped to the mask's channel bounds. Digest invalidation includes source textures, shaders, authored layout and baker. It uses complete export imports before the tests, because early editor quit can abort resource scanning. No actor/collision/mission is flattened into terrain.

Host OpenGL (`--gpu host`, launcher default) showed actual guest startup samples of 44–53.1 fps and controller medians mostly 35–78 ms in the observed walking/split/tractor checks. The Debug native strip labels bounded first-minute startup samples; it is not a permanent live FPS measurement. Release omits the strip. Software alternatives remain slower, and previous Metal ANGLE crash is not a passed stability result. Exact evidence/limits: `docs/audits/2026-10-20-vega-performance/README.md`.
