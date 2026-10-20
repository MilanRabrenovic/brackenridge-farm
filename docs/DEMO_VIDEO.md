# Genuine Vega simulator gameplay demo — October 20, 2026

- **Current replacement:** `artifacts/demo-vega/brackenridge-farm-vega-demo.mp4`, 111.0 seconds, H.264 1280×720/30 fps, AAC, 29,042,710 bytes.
- Silent alternative: `artifacts/demo-vega/brackenridge-farm-vega-silent.mp4`; English on-screen captions and sidecar `brackenridge-farm-vega-demo.en.srt`.
- SHA-256: `7bb607e667c2ae582c52834da497eaa25d5ead822a27b4d0a81eae1aae3dd21a`.
- Published through the user-approved Mozilla window: https://youtu.be/EOK7y4zPDx4. Public visibility/YouTube publication confirmation and actual playback verified. The user confirmed general audience (not made for kids). Devpost embeds this exact ID; its story was updated and entry remains submitted.

## Publication verification

YouTube copyright checks reported no issues. Watch-page player shows 1:51, genuine Vega gameplay/banner and current captioned edit. Public Devpost iframe uses `EOK7y4zPDx4`; project story is retained in `SUBMISSION_STORY.md`. Evidence: `artifacts/demo-vega/published-vega-player.png` and `published-devpost.png`. Older Mac videos remain historical and are not the submitted platform proof.

## Provenance and checks

OBS 32.2.2 records only `[vega-virtual-device] Vega Virtual Device`. Camera absent, cursor hidden, microphone/source audio muted. The title bar identifies the actual simulator in the introduction; the remaining footage uses a consistent viewport crop. Simulation/rendering execute inside official SDK 0.24.12112 guest WebView via the maintained Godot 3.6.3 GLES2/WebGL1 adapter. Mac supplies static files and input relay only. This is not a Mac game capture dressed as a simulator.

Normal-speed automated two-player inputs use the existing host movement/collision/mission route, without actor/crop teleports or solo helper. All four outcomes/results/replay checks passed: zero errors, 355.783333 simulated seconds / 364.0233 elapsed seconds. Persistent captions disclose automated inputs. Different private repair facts are reproduced from this run and explicitly labelled. Moving excerpts retain normal speed; crop stages are edited together. This is not a two-human fun/pacing test or a physical Fire TV acceptance claim.

Final file fully decoded without reported errors; ffprobe checked streams/duration; six sample frames inspected in `artifacts/demo-vega/review-sheet.jpg`. Audio is **Forest Ambience** by TinyWorlds, CC0, https://opengameart.org/content/forest-ambience , at reduced volume with two-second in/four-second out fades. Mean −29.6 dBFS / peak −6.9 dBFS. No narration or rejected synthesized score. The agent cannot subjectively audition the track; user listening review remains appropriate.

## Reproduction

See `USEFUL_COMMANDS.md`: prepare isolated route, collect local timing markers, record the simulator window with OBS, then run `scripts/render-vega-demo.py /absolute/path/to/recording.mov` with Pillow/ffmpeg/ffprobe. Editor requires a successful guest result. Timing/cut provenance is `artifacts/demo-vega/manifest.json`. Ordinary wrapper configuration was restored, rebuilt and QR-lobby verified after recording.

## Known limits

In-page WebGL stream capture lost context; canvas readback was very slow and hung. Those recordings are rejected. A host-mode emulator later exited signal 11 during a prolonged tool stall; causation is unproven. A restarted host-mode guest completed this automated run. Sustained general stability and human acceptance remain open. Do not guarantee organizer eligibility: update the actual Devpost entry and let organizers review.

---

## Historical Mac preview — superseded for platform evidence

# Music-only English gameplay preview — October 19, 2026

## Deliverable

- Current video: `artifacts/demo/brackenridge-farm-demo-music.mp4` — 115.12 seconds, 1920×1080, 30 fps, H.264/AAC, original instrumental and English explanatory subtitle track. No narration or vocals.
- Fully silent alternative: `artifacts/demo/brackenridge-farm-demo-silent.mp4` — same video/subtitles, no audio stream.
- Current sidecar captions: `artifacts/demo/brackenridge-farm-demo-music.en.srt`.
- Script/edit provenance: `artifacts/demo/music-manifest.json` (current), `artifacts/demo/manifest.json` and `artifacts/demo/narration.txt` (superseded voice edit).
- SHA-256: `cad4044cb41ea205e2db6ac05b471853beea9b31998758020722f6dbbeb77eef`.
- YouTube upload is in progress; public visibility and processing must be verified before sharing as published.

## What it proves

Actual Mac-native Godot 4.7.2 gameplay captured through the existing deterministic two-player input/physics route. Both actors use the real motors/collisions and mission rules. Full route passed all four jobs and replay, with 355.8 simulated seconds including a six-second results hold. The raw movie is 355.6 seconds / 10,668 frames at 30 fps; it is edited to the preview duration. Playback excerpts retain normal speed. Crops are shown with cuts between real growth stages. The private-clue card reproduces facts from the recorded run and is labelled accordingly.

Persistent video banner, English explanatory captions and YouTube description disclose Mac capture and automated inputs. This is **not qualifying Fire TV/Vega footage**, not two-human playtest evidence, and not a submitted Devpost entry. No Fire TV was connected when recording; `vega device list` reported no devices. Existing unsupported simulator capture attempts were not repeated.

## Editorial sequence

| Start | Chapter |
|---|---|
| 0:00 | BRACKENRIDGE FARM |
| 0:06 | TOGETHER, WITH HALF THE STORY |
| 0:15 | THE FLOCK HAS OTHER PLANS |
| 0:26 | TWO ROLES, ONE GOAL |
| 0:35 | COMMUNICATION IS THE MECHANIC |
| 0:48 | DIFFERENT CLUES ON EACH PHONE |
| 0:59 | A FIELD THAT CHANGES AS YOU WORK |
| 1:10 | FROM SEEDS TO HARVEST |
| 1:22 | BEAT THE WEATHER TOGETHER |
| 1:33 | FINISH AS A TEAM |
| 1:44 | ONE WEEKEND. SHARED SUCCESS. |

## Verification

Recorder GDScript parsed; full rendered route completed successfully. Final MP4 decoded completely with ffmpeg without reported errors; ffprobe verified H.264 1920×1080/30 fps, AAC, subtitle track and duration below two minutes. Current audio is an original instrumental, mean -21.7 dBFS and peak -9 dBFS (no clipping). The remux maps only the newly synthesized WAV; no original speech audio is used. H.264 elementary-stream hash matches the approved-for-edit earlier composition; the silent alternative has no audio stream. Sampled actual/composed frames and six-frame review sheet were inspected for layout, readable captions and complete gameplay viewport. The user rejected the synthetic Daniel narration; it is superseded and its YouTube upload remains an unpublished private draft. The current original instrumental is synthesized locally from authored notes, sine partials and envelopes at 88 BPM, with no samples, stock music or vocals. Composition source is `scripts/score-demo.py`, under the project MIT license. No unrelated desktop/browser content was recorded. No new game art or runtime behavior was changed.

## Reproduce

1. `mkdir -p artifacts/demo/raw`
2. `godot --path game --script res://tests/record_demo.gd --write-movie ../artifacts/demo/raw/co-op-native.avi --fixed-fps 30 --disable-vsync`
3. Run `python3 scripts/render-demo.py` using a Python environment with Pillow. Requires macOS `say` with Daniel, Avenir Next font, `ffmpeg` and `ffprobe` in PATH. Desktop graphics/speech permissions are needed.
4. Run `python3 scripts/score-demo.py` with NumPy and ffmpeg to replace narration, generate original music and export the silent alternative.
5. Review MP4/SRT/manifest before uploading. The script generates files; it does not publish or claim device acceptance. Raw/edit files are local artifacts, excluded from curated source.

## Superseded narration script (historical; not in the current audio)

### BRACKENRIDGE FARM

Brackenridge Farm. One farm. Two phones. Half the story each.

### TOGETHER, WITH HALF THE STORY

A cooperative farming weekend where both players share one farm, but each holds different information. Success starts with talking to your partner.

### THE FLOCK HAS OTHER PLANS

The sheep jump the fence. One farmer guides the flock, while the other opens the gate. Rush too close, and the sheep scatter.

### TWO ROLES, ONE GOAL

Keep the gate open and bring everyone home. When farmers separate, the camera splits. The minimap helps both players find their next job.

### COMMUNICATION IS THE MECHANIC

The packing machine breaks down. The mechanic diagnoses the fault and balances pressure. Their partner finds the correct part, then fits it while the gauge stays green.

### DIFFERENT CLUES ON EACH PHONE

One player knows which part is broken. The other knows where the spares are. Neither clue solves the problem alone. That is the heart of Brackenridge Farm.

### A FIELD THAT CHANGES AS YOU WORK

Climb into the tractor, prepare the soil, and deliberately engage the next field tool. Work the marked plots to turn unprepared ground into a growing crop.

### FROM SEEDS TO HARVEST

Seeds become seedlings, then young plants and mature barley. These are the actual crop stages, edited together. Meanwhile, your partner seals storage and protects the apples.

### BEAT THE WEATHER TOGETHER

Harvest the barley and move it safely into storage. Different responsibilities keep both players useful, even when they are working on opposite sides of the farm.

### FINISH AS A TEAM

For the final delivery, combine buyer requirements with stock information. Pack both loads, meet at the van, and hold together to send the order on its way.

### ONE WEEKEND. SHARED SUCCESS.

Results recognise the team’s work, with another seeded weekend ready to play. This preview was recorded on a Mac; Fire TV verification remains pending.
