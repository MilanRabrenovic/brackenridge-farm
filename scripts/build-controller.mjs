import { build } from 'esbuild';
import { mkdir, copyFile } from 'node:fs/promises';
await mkdir('build/controller', { recursive: true });
await build({ entryPoints: ['controller/main.ts'], outfile: 'build/controller/main.js', bundle: true, target: ['es2022'], sourcemap: true });
await Promise.all(['index.html', 'style.css'].map(name => copyFile(`controller/${name}`, `build/controller/${name}`)));
