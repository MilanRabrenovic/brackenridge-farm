# Devpost gallery v1 — October 19, 2026

Four 1536×1024 (3:2) JPEGs under 5 MB each, composed from actual frames of the native co-op recording. Runtime art/game behavior is unchanged. English headlines explain the family/co-op goal; four players are explicitly future scope. Private clue panels reproduce the recorded run's facts rather than impersonating live phone screenshots. All cards identify Mac/automated inputs and outstanding TV verification.

- `01-family-teamwork.jpg` — 775,857 bytes; actual source frame at 28s.
- `02-private-clues.jpg` — 543,694 bytes; actual source frame at 110s.
- `03-farming-together.jpg` — 711,138 bytes; actual source frame at 271s.
- `04-shared-results.jpg` — 649,751 bytes; actual source frame at 351s.

Inspected the rendered four-card contact sheet for framing, complete gameplay viewport, readable text, clue-panel bounds and accurate results. JPEG decoding, exact 3:2 dimensions and upload-size assertions passed. ZIP contains only the four gallery upload JPEGs; do not upload the contact sheet as a fifth image.

Reproduce with `python3 scripts/build-submission-gallery.py` in an environment with Pillow, ffmpeg and Avenir Next. Requires the retained local raw movie at `artifacts/demo/raw/co-op-native.avi`. Source frames are preserved beside this README; upload files/manifest/review sheet are under `artifacts/submission/gallery-v1/`. ZIP: `artifacts/submission/brackenridge-farm-gallery.zip`.
