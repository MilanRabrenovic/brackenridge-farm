# Hackathon source handoff

Updated October 19, 2026. The user explicitly authorized GitHub publication and selected **public** visibility.

## October 20 Vega release

Current prerelease: [v0.9.2-vega-candidate](https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.2-vega-candidate), targeting verified public source commit `fc55d150ebf70124884a10d03bc2fddad0dc779c`. All three assets reported uploaded and SHA-256 matched local files. It includes the 156,102-byte ordinary Vega package, 34,299,533-byte WebGL1 bundle and checksums. Original Godot 4 source remains authoritative; maintained compatibility adapter is `platform/vega-gles2/`. No toolchain/cache/signing keys were published. Scoped credential-pattern scan passed for 166 text files in the 834-file source snapshot.

Actual full automated guest weekend passed and is shown in the public demo https://youtu.be/EOK7y4zPDx4; Devpost embeds that ID. Current publication follow-up updates documentation only. Older v0.9.1 notes below describe a superseded candidate. Physical TV/human acceptance and longer-session stability remain open.

## Repository

[Brackenridge Farm](https://github.com/MilanRabrenovic/brackenridge-farm) was created under the verified `MilanRabrenovic` account. The source was pushed to `main`; GitHub commit verification matched local initial publication commit `b76d4959fa9b1398dfcbe57e4f85958a6e32c6f1`. The dependency-fix candidate is [v0.9.1-candidate](https://github.com/MilanRabrenovic/brackenridge-farm/releases/tag/v0.9.1-candidate). It replaces the initial v0.9.0 candidate with a patched Vega dependency tree and rebuilt wrapper; game source/Web/APK behavior is unchanged. Publication verification is recorded in PROJECT_STATE.

The main development workspace has no Git checkout. Its curated publishing checkout is `artifacts/submission-source/brackenridge-farm/`, retaining the previous local commits. Update it from `artifacts/brackenridge-farm-source.zip` after changes, compare every archive file, then commit and push `main` from that checkout. Do not publish the surrounding development directory or toolchain caches.

## Included material

Godot game/runtime art, retained original art, controller/relay/protocol, tests/scripts, Vega wrapper and run/submission/provenance documentation. Toolchains, installed dependencies, generated builds, environment files and signing keys are excluded. Code is MIT; retain `THIRD_PARTY_NOTICES.md` and third-party licences. The active art is original generated/edited project work; disclose AI assistance where required.

October 19 verification: all 783 files in the previous source candidate matched the workspace and prepared checkout. A credential-pattern scan passed for 143 text source/document files; signing-key/environment/toolchain exclusions were checked. This is a scoped scan, not a universal secrets guarantee. Publication documentation updates increase the final source set only if new files are added.

## Candidate downloads

The published prerelease includes a Web bundle, signed Fire OS debug APK, Vega aarch64 wrapper and SHA-256 checksums. GitHub automatically provides the curated tracked source archives from the release commit. The separate local source ZIP remains a handoff artifact. GitHub reported all four uploaded assets complete and its SHA-256 digests matched local files. Web bundle extraction creates `build/web/`; the laptop Node relay is still required. GitHub source publication does not deploy a live game backend.

Human cooperative acceptance, physical Fire TV execution/performance/audio/remote, qualifying video and Devpost submission remain pending. Publishing the repository does not establish those gates.

Dependency follow-up: v0.9.1-candidate targets `554232d3d5a5f8dcf016eb4cef89876d4cf9ced4`. GitHub confirmed 14/16 alerts fixed, retaining two unpatched upstream advisories. All four uploaded asset sizes/SHA-256 digests matched local files; source candidate is now 784 files and passed CRC/exclusions/exact snapshot checks. Final documentation-only follow-up preserves the tagged build.
