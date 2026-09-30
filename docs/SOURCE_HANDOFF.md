# Hackathon source handoff

Prepared September 30, 2026. Publication is pending.

## Prepared source

The curated source ZIP is `artifacts/brackenridge-farm-source.zip`. An isolated Git checkout is prepared under `artifacts/submission-source/brackenridge-farm/` for publishing. The main working directory remains the development workspace; the publishing checkout is a snapshot. Refresh the ZIP/snapshot after further implementation before pushing it.

Source includes Godot game/runtime art, original retained art, controller/relay/protocol, tests/scripts, Vega wrapper and project/run/submission/provenance documents. Toolchains, dependencies, generated exports, environment files and signing keys are excluded. Original code is MIT; preserve `THIRD_PARTY_NOTICES.md` and bundled licence files for other material. The largest retained file is approximately 8.1 MB.

On September 30 a scan of 122 text source/doc files found no matches for AWS access keys, GitHub token strings, OpenAI key strings or private-key headers. This records the scan's scope, not a universal secrets guarantee.

## Proposed destination

`MilanRabrenovic/brackenridge-farm` on GitHub. GitHub authentication was verified using normal network access and the intended repository was absent. No remote or published URL exists yet.

Choose public source with the included licences, or private source with explicit reviewer access. Public publication exposes the complete curated source and art to everyone; this choice remains the user's.

After approval, from the prepared publishing checkout:

```sh
gh repo create MilanRabrenovic/brackenridge-farm --public --source . --remote origin --push
```

Use `--private` instead if that is the approved visibility. Verify the resulting remote/branch and repository files before adding its actual URL to `docs/SUBMISSION.md`. Do not invent a repository link before creation.

## Submission still pending

Repository publication alone does not prove game acceptance. Human cooperative play, qualifying TV execution/remote/performance, an actual under-three-minute public demo and Devpost review/submission remain pending.
