import { mkdir } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import path from 'node:path';
const root = path.resolve(import.meta.dirname, '..');
await mkdir('build/web', { recursive:true });
const result=spawnSync('godot',['--headless','--path','game','--export-debug','Web','../build/web/index.html'],{
  cwd: root,
  env: { ...process.env, HOME: path.join(root, '.tools', 'godot-home') },
  stdio:'inherit'
});
if (result.status !== 0) process.exit(result.status ?? 1);
// Exercise the exported pack, not the source tree: scene-only exports can omit
// dynamically loaded scripts/assets even when the editor tests pass.
const smoke = spawnSync('godot', ['--headless', '--main-pack', path.join(root, 'build/web/index.pck'), '--quit-after', '3'], {
  cwd: root, env: { ...process.env, HOME: path.join(root, '.tools', 'godot-home') }, encoding: 'utf8', timeout: 30000
});
const output = (smoke.stdout ?? '') + (smoke.stderr ?? '');
if (smoke.status !== 0 || /SCRIPT ERROR|Failed to load|does not exist|Error loading/.test(output)) {
  console.error(output);
  process.exit(1);
}
console.log('Exported pack startup smoke check passed.');
