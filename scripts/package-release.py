"""Package the project source without toolchains, secrets or generated builds."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import hashlib
import json
from datetime import date

root = Path(__file__).resolve().parents[1]
output = root / 'artifacts' / 'brackenridge-farm-source.zip'
selected = list(root.glob('*.md')) + [root / name for name in ('package.json', 'package-lock.json', 'tsconfig.json', 'LICENSE', '.gitignore')]
for directory in ('game', 'controller', 'server', 'shared', 'scripts', 'tests', 'source_assets', 'platform'):
    selected.extend((root / directory).rglob('*'))
selected.extend(p for p in (root / 'docs').rglob('*') if p.suffix in ('.md', '.svg') or '2026-09-30-release' in p.parts or '2026-09-30-solo' in p.parts or '2026-09-30-missions' in p.parts or '2026-09-30-sheep' in p.parts or '2026-09-30-repair-play' in p.parts or '2026-09-30-minimap' in p.parts or '2026-10-05-coop-route' in p.parts or '2026-10-05-tv-inspection' in p.parts)
excluded = {'.godot', '.git', 'node_modules', '__pycache__', '.DS_Store', 'build', 'dist'}
output.parent.mkdir(exist_ok=True)
count = 0
with ZipFile(output, 'w', ZIP_DEFLATED, compresslevel=6) as archive:
    for path in sorted(set(selected)):
        if not path.is_file() or excluded.intersection(path.relative_to(root).parts):
            continue
        if path.name in ('buildinfo.json', 'CMakeUserPresets.json') or path.name.startswith('.env') or path.suffix in ('.jks', '.keystore', '.pem', '.key'):
            continue
        archive.write(path, Path('brackenridge-farm') / path.relative_to(root))
        count += 1
manifest = {'date': date.today().isoformat(), 'status': 'candidate; qualifying Fire TV testing and submission pending', 'source_files': count, 'artifacts': {}}
for path in (output, root / 'artifacts' / 'countryside-coop-debug.apk', root / 'build' / 'web' / 'index.pck', root / 'artifacts' / 'brackenridge-farm-vega-aarch64.vpkg'):
    if path.exists():
        manifest['artifacts'][str(path.relative_to(root))] = {'bytes': path.stat().st_size, 'sha256': hashlib.file_digest(path.open('rb'), 'sha256').hexdigest()}
(root / 'artifacts' / 'release-manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')
print(f'{output}: {count} source files')
