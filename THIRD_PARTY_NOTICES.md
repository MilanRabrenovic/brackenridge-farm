# Provenance and third-party notices

## Active artwork and audio

The active 2D farm, farmers, tractor and original atlases were generated/edited for this project. Full-resolution source and optimized derivatives are retained under `source_assets/2d/` and `game/assets/2d/`. A screenshot/game reference informed general cartoon countryside discussion, but no Stardew Valley or television-show assets/branding ship in the active 2D game. The objective bell is synthesized mathematically in project code; no sampled music/audio library is used. AI-assisted artwork should be disclosed where submission forms ask.

## Engine and libraries

- [Godot Engine](https://godotengine.org/license/): MIT. Engine licence/third-party notices are available in the engine distribution; preserve them in redistributed engine builds.
- [ws](https://github.com/websockets/ws): MIT; local relay dependency.
- [node-qrcode](https://github.com/soldair/node-qrcode): MIT; local QR generation dependency.
- TypeScript, tsx, esbuild, pngjs and jsQR are development/test tooling; their licences remain with the installed packages. `package-lock.json` records exact dependencies.

`LICENSE` applies to project-authored code; it does not relicense third-party dependencies. The retained legacy 3D experiments contain Quaternius source/animation work under CC0 and historical notices, but they are excluded from the active 2D exported game. Do not advertise legacy assets as current character art.

## Vega wrapper candidate

`platform/vega/` was generated from Amazon's official `vegaWebview` SDK template and adapted for this project. Amazon SDK/runtime materials are subject to the [Program Materials License](https://developer.amazon.com/support/legal/pml) and applicable dependency terms. The SDK, simulator and installed dependencies are not included in the source archive. `platform/vega/package-lock.json` records the wrapper dependencies; retain their notices when redistributing. React/React Native and the official Amazon WebView/Kepler runtime are separate from project-authored gameplay code. The root `LICENSE` does not relicense Amazon materials.
