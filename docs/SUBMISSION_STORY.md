# Published Devpost story

Updated October 20, 2026. Public project: https://devpost.com/software/brackenridge-farm . Video: https://youtu.be/EOK7y4zPDx4 .

## Inspiration

We wanted to create a family game where playing together means more than sharing a screen.

Brackenridge Farm imagines a family gathered around the television, using their phones to work on the same English countryside farm. The twist: everyone can see the farm, but nobody has all the information needed to keep it running.

One farm. Two phones. Half the story each.

## What it does

Brackenridge Farm is a cooperative farming adventure designed for family fun, conversation and shared problem-solving.

The current version supports two players. Each phone acts as both a controller and a source of private information. Players must explain what they know, divide responsibilities and help each other through a busy farming weekend.

Activities include:

- Bringing escaped sheep back to their pasture while a partner operates the gate.
- Repairing machinery: one player diagnoses the fault and manages test pressure, while the other finds and fits the correct part.
- Driving a tractor to prepare soil, sow crops and harvest barley as it grows through different stages.
- Protecting supplies, combining buyer and stock information, packing goods and loading a delivery together.

The camera follows players closely, splitting when they separate and merging when they reunite. A minimap and contextual guidance help them find their next task.

Missed deadlines do not eliminate players. The weekend continues, giving the team opportunities to recover and finish together.

## How we built it

We built the illustrated 2D game in Godot, with a TypeScript and Node.js WebSocket relay connecting browser-based phone controllers.

The game host owns movement, collisions, crop growth, mission timing and outcomes. Phones send inputs and receive role-specific clues. Keeping the simulation on the host gives both players one consistent farm while preserving their different information.

The world uses separate terrain, buildings, collision shapes, foreground layers and animated characters. This allows farmers to walk behind objects, enter buildings and operate the tractor.

The current Fire TV route runs the game inside the official Vega Virtual Device, SDK 0.24.12112. Our maintained Godot 3.6.3 GLES2/WebGL1 compatibility port runs simulation and rendering inside the Vega guest WebView. The laptop serves static files and relays phone inputs; it does not render or stream the farm to Vega.

A normal-speed automated two-player guest route completed all four outcomes, results and replay checks with zero reported errors. Two independent phone controllers, private clues, adaptive cameras and tractor controls were also inspected in the guest. The downloadable Vega candidate and setup instructions are linked below. This developer setup requires a laptop relay with reverse port forwarding. Physical Fire TV testing, sustained stability and normal-speed human family playtesting remain outstanding.

The embedded demo shows the actual game running inside the official Vega simulator, with English on-screen captions and quiet CC0 ambience, without narration. It uses automated two-player inputs through the real movement, collision and mission systems. Moving excerpts play at normal speed, with cuts between crop stages; the private-clue cards reproduce facts from the recorded run. This is platform execution evidence, not a two-human playtest or physical Fire TV certification.

AI-assisted coding and artwork generation supported development, alongside project-specific editing, integration and testing.

## Challenges we ran into

Our biggest design challenge was making cooperation necessary without making the game difficult to understand. Giving players different clues only works when both roles have useful actions and a clear reason to communicate.

We also moved from early 3D experiments to illustrated 2D, then rebuilt the map around consistent scale, connected routes, collisions and foreground occlusion.

Other challenges included responsive phone input, reconnect handling, adaptive split-screen cameras, contextual tractor controls and ensuring exported builds contained dynamically loaded resources.

The tested Vega WebView could not create the WebGL2 context needed by our original Godot 4 export. We built a repeatable GLES2/WebGL1 compatibility port and cached static terrain to reduce rendering cost. The official host OpenGL backend completed the recorded guest route, but a separate long-running simulator session later exited with signal 11; sustained emulator stability remains an open acceptance check.

## Accomplishments that we're proud of

- A complete farming weekend connecting four incident families, shared outcomes and replay.
- Private clues that turn familiar farm jobs into communication challenges.
- Two-player cooperation across herding, repairs, crop work and delivery.
- A connected illustrated farm with working collisions, crop stages and directional character animation.
- Phone controls, adaptive cameras, a minimap and reconnect handling.
- Automated solo and two-player input routes that exercise real movement, physics and mission completion.

These checks establish functional behavior; family enjoyment and pacing still need normal-speed human playtesting.

## What we learned

The strongest cooperative moments come from giving players different knowledge and complementary responsibilities.

We also learned that attractive individual assets are not enough: scale, placement, animation, collision and readable guidance must work together to make a convincing game world.

Finally, producing a package is different from proving a platform experience. Device gameplay, performance and usability require their own verification.

## What's next for Brackenridge Farm

Our immediate priorities are family playtesting, tuning instructions and pacing, and verifying physical Fire TV performance and longer-session stability.

The current game supports two players. Our planned next expansion is four-player family co-op, with responsibilities distributed across animal care, machinery, crops and logistics. Each player would receive useful private information and meaningful tasks, while remaining part of the same shared farm.

We also want to improve character and animal animations, offer adjustable difficulty and develop more weekend variations.

The goal is a welcoming family game where different ages can contribute, laugh at the farm’s mishaps and succeed together.
