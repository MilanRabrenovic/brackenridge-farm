# Project instructions for every Codex chat

This file is the entry point for all work in this repository. These instructions apply to the entire project.

## Required reading before work

Before planning or editing, read these root documents in this order:

1. `PROJECT_STATE.md` — what currently works, what is unfinished, and the next task.
2. `GAME_DIRECTION.md` — the product promise, scope, and gameplay rules.
3. `ART_DIRECTION.md` — the visual quality bar and asset approval process.
4. `ASSET_CATALOG.md` — every required asset and its production status.
5. `USEFUL_COMMANDS.md` — verified development, test, export, and preview commands.

Read the relevant files under `docs/` when working on world layout, logistics, or the hackathon plan.

## Documentation contract

Documentation is part of the implementation, not optional cleanup.

- At the start of a chat, verify that the requested work agrees with the current documents. If code and documentation disagree, inspect the running project and source, then correct the documentation.
- After every implementation change, update `PROJECT_STATE.md` with the exact result, verification performed, unresolved problems, and the single recommended next task.
- Update every other Markdown file affected by the change. Examples: asset work updates `ASSET_CATALOG.md` and `ART_DIRECTION.md`; gameplay work updates `GAME_DIRECTION.md`; new or changed commands update `USEFUL_COMMANDS.md`.
- Add one dated entry to `CHANGELOG.md` for every completed implementation pass.
- Do not claim that something is finished, polished, approved, tested, or Fire TV compatible unless the recorded evidence supports that wording.
- Keep future ideas clearly separated from the committed hackathon scope.
- Preserve user decisions. Do not silently broaden or reverse them.

## Asset production rules

- The active 2D farmyard, Grower, Mechanic and tractor proof define the current visual direction; the previous 3D art is legacy source.
- Create 2D assets individually or as deliberately coordinated sets, then review them in an isolated view or the real 2D gameplay camera before integration.
- Keep full-resolution generated/source art under `source_assets/` and only optimized runtime images under `game/assets/2d/`.
- Do not assemble final-looking art from primitive boxes, cylinders, spheres or flat debug shapes.
- Do not place an asset in the main world until its row in `ASSET_CATALOG.md` is marked `Approved` by the user.
- `Prototype` and `Rejected` assets may be used only in clearly labelled development views. They must not be described as final art.
- Build the production map from reusable terrain, building, foreground/occlusion, interaction-state and sprite-animation layers. Keep gameplay logic separate from decorative presentation.
- Use original fictional names, shapes, branding, characters, and designs. The English countryside may inspire the setting, but do not copy Clarkson's Farm, Diddly Squat, or another game's identifiable assets or visual style.

## Engineering rules

- Fire TV is the primary release target. The browser host is the fast local development route.
- The host owns simulation. Phones send input and receive private role information.
- Protect the core hook: players share one farm but do not individually possess all information needed to solve a problem.
- Optimise the first complete experience for two players. Preserve the planned path to four players.
- Run the relevant checks from `USEFUL_COMMANDS.md` after code changes. Record results in `PROJECT_STATE.md`.
- Never sacrifice phone joining, movement responsiveness, adaptive cameras, or deterministic gameplay to add decorative scope.

## Definition of done

A task is complete only when:

1. The requested behaviour or asset exists.
2. It has been inspected in its real gameplay or review context.
3. Relevant automated checks pass.
4. The affected Markdown documents reflect reality.
5. `PROJECT_STATE.md` gives the next chat a truthful continuation point.
