# Vega dependency remediation — October 19, 2026

Scope: the 16 open GitHub alerts on `platform/vega/package-lock.json`, inspected through the GitHub advisory API. No gameplay/art changes.

## Changes

- React Native Community CLI 20.0.0 → 20.2.0 uses patched fast-xml-parser 5.11.2 through its own supported dependency range.
- Explicit overrides: Handlebars 4.7.10, Lodash 4.18.1, UUID 11.1.1, TOML 4.2.0, Ajv 8.18.0 for majors 7/8, minimatch 3.1.5 for old major 3 and 9.0.7 for major 9. Ajv 6 and minimatch 10 retain their own API versions.
- TOML 4.2.0 also covers the newer uncontrolled-recursion advisory found by npm audit. Both Debug and Release manifest compilation passed after the TOML major upgrade.
- Declared Node minimum is now 22.14.0, matching the existing Amazon React Native package requirement. Clean install used Node 24.19.0. SDK-executed checks/builds used Node 20.19.5 successfully; that success does not override the package's supported installation engine.

## Verification

- Fresh `npm ci --no-audit` passed (1,072 packages), retaining deprecation notices from upstream tools. Initial installation under an older shell Node emitted engine warnings; clean verification used Node 24.19.0. No `npm audit fix --force` or SDK downgrade.
- ESLint and `tsc --noEmit` passed.
- Three Jest tests in two suites passed with `--runInBand --watchman=false`.
- Debug and Release builds passed for aarch64, armv7 and x86_64. SDK still prints its nonfatal package-lock comparison and empty asset-copy warnings; these are not device gameplay verification.
- Release source map contains 79 sources; no source paths from braces, sprintf-js, Handlebars, TOML, fast-xml-parser or Lodash were present. This is scoped bundle evidence, not a general guarantee about third-party embedded code.
- Rebuilt aarch64 candidate: 155,574 bytes. Web and Fire OS APK are unchanged.
- npm audit exits 1: **two underlying advisories remain**. Its dependency propagation counts changed from 81 affected package entries (1 critical, 65 high, 15 moderate) to 68 (0 critical, 61 high, 7 moderate). These counts include every affected ancestor and must not be described as 68 separate vulnerabilities or zero remaining risk.

## Upstream blockers retained, not dismissed

| Package | Advisory | Latest published version checked | Path / exposure |
|---|---|---|---|
| braces | [stack exhaustion](https://github.com/advisories/GHSA-vfj7-8cjw-p6xm), high | 3.0.3; no patched version | micromatch → Metro/Jest/fast-glob/SDK workspace tools; nested glob patterns |
| sprintf-js | [unbounded precision denial of service](https://github.com/advisories/GHSA-hp3w-g68c-fv3c), moderate | 1.1.3; no patched version | argparse 1 → js-yaml 3/Jest coverage configuration and Rushstack CLI → Amazon tooling; format strings |

The application does not accept player-supplied glob patterns or format strings. Nevertheless, keep build/test configuration trusted and retain both open alerts. Removing all these paths requires upstream tool replacements or maintained patches, not a guessed version override. Do not suppress alerts or claim this toolchain is fully vulnerability-free. Check for upstream fixes before release-toolchain upgrades.

The 14 patchable GitHub findings are addressed in the lockfile, including both critical alerts; remote rescan/published artifact verification is recorded in PROJECT_STATE. Human/Fire TV acceptance remains deferred.
