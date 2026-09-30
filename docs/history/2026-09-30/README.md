# Countryside Co-op

An asymmetric couch-cooperative farming game prototype for the Amazon Fire TV track. Two phones join a TV-hosted Godot session and move independent characters through a WebSocket relay. Players share one farm while receiving different private facts needed to solve cooperative problems.

## Start here

Every development chat and contributor should read the root project documents before making changes:

- [PROJECT_STATE.md](PROJECT_STATE.md) — current reality and the next task.
- [GAME_DIRECTION.md](GAME_DIRECTION.md) — product and gameplay direction.
- [ART_DIRECTION.md](ART_DIRECTION.md) — visual target and asset approval rules.
- [ASSET_CATALOG.md](ASSET_CATALOG.md) — complete asset list and production status.
- [USEFUL_COMMANDS.md](USEFUL_COMMANDS.md) — run, test, export, and preview commands.
- [AGENTS.md](AGENTS.md) — required workflow for future Codex chats.

## Run the input probe

Requirements: Node.js 20+, Godot 4.7.2, and two phones on the same local network.

```bash
npm install
npm run dev
```

The server prints controller and browser-host URLs. The native Godot host discovers the relay automatically over local UDP broadcast:

```bash
godot --path game
```

If broadcast discovery is unavailable on the network, provide the relay explicitly:

```bash
FARM_RELAY_URL=ws://YOUR_COMPUTER_LAN_IP:8787/ws godot --path game
```

Scan the QR code shown by Godot with each phone. It opens the Wi-Fi-reachable controller URL and joins the correct room automatically. Then press Enter/Select on the host to admit pending players. The six-character code remains as a fallback, and each controller reports round-trip latency after Godot processes its input.

The relay uses plain HTTP/WebSocket only for local development. Any public deployment must use HTTPS/WSS.

## Verify

```bash
npm run typecheck
npm test
npm run test:godot
```

To produce the browser test build after installing Godot web export templates:

```bash
npm run export:web
npm run dev
```

Then open the printed `/host/` URL on a laptop or TV browser.

## Fire OS debug build

The local toolchain uses Temurin JDK 17, Android SDK 36, and Godot 4.7.2 export templates under the ignored `.tools/` directory. Once those dependencies are present, build the signed debug APK with:

```bash
npm run export:fireos
```

The output is `artifacts/countryside-coop-debug.apk`. With ADB connected to a Fire TV on the same network as this computer:

```bash
.tools/android-sdk/platform-tools/adb install -r artifacts/countryside-coop-debug.apk
.tools/android-sdk/platform-tools/adb shell am start -n com.countrysidecoop.probe/com.godot.game.GodotAppLauncher
```

Start `npm run dev` first. The Fire OS host discovers its WebSocket relay, creates a six-character room, and shows that code on the TV. The debug APK is a sideloadable platform probe. Store-ready Fire TV launcher metadata will use Godot's custom Gradle export after the hardware route is confirmed.

## Current playable presentation

The host now opens on a close isometric camera in **Brackenridge Farm**, an irregular hedged English countryside layout. Nearby players share the camera. At 32 metres apart, the host changes to two close views with a strong central divider; it merges again below 25 metres so the boundary does not flicker.

The phone stick is transformed through the isometric camera axes, so up, down, left and right always match the television image. The field parcels meet along shared, winding hedge boundaries to form one continuous patchwork rather than isolated plots. Split views are separated by a small hedge-and-fence motif.

Development controls: `M` toggles the whole-farm overview, `T` places the two characters far apart to test split screen, `G` opens the grain-store review, `H` opens the isolated machinery-shed review, `J` opens the five-asset storybook review, and `K` opens the modular boundary-kit review. In `J`, keys `1`–`5` switch assets; in `K`, keys `1`–`3` switch hawthorn, wall and oak-base views. `F` frames the current farmyard prototype, and `L` transitions between prototype clear and overcast lighting. `V` and `B` jump directly to the tractor and barn review pages. These controls are only presentation helpers; normal players move through their phones.

The playable farmyard now contains the machinery shed, stone barn, red tractor, mature oak with an authored courtyard base, connected modular hawthorn boundaries, and a visible drystone west-yard boundary with a matching gate. The assets use shared hand-painted materials. Inspect `docs/previews/storybook-existing-assets-review.png`, press `J` for the original asset set, or press `K` for the modular boundary kit.

The machinery shed is a hand-painted storybook benchmark at `game/assets/buildings/bracken_machinery_shed.glb`. It is placed on the playable farm's east yard; press `H` to inspect it separately with the tractor for scale. It uses four optimised painted material textures.

The current host includes the measured 120 × 80 metre logistics greybox. Press `M` to switch between the complete farm overview and the shared gameplay camera. Layout data lives in `game/data/world_layout.json`; its combine clearances and logistics references are covered by automated tests.

## Platform status

The hackathon requires the final video to show the app on an actual Fire TV device or the Fire TV/Vega simulator. The native, ARM-compatible Fire OS APK is built and signed; installation and play on a qualifying device remain pending because none is currently connected. The game design and milestone plan are in [docs/GAME_PLAN.md](docs/GAME_PLAN.md).

## License

MIT. See [LICENSE](LICENSE).
