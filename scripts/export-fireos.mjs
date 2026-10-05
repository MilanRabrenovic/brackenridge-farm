import { mkdir, symlink, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { spawn, spawnSync } from "node:child_process";
import path from "node:path";
import process from "node:process";

const root = path.resolve(import.meta.dirname, "..");
const toolingHome = path.join(root, ".tools", "godot-home");
const editorDir = path.join(toolingHome, "Library", "Application Support", "Godot");
const editorSettings = path.join(editorDir, "editor_settings-4.7.tres");
const sdk = path.join(root, ".tools", "android-sdk");
const java = path.join(root, ".tools", "jdk17", "Contents", "Home");
const localTemplates = path.join(editorDir, "export_templates", "4.7.2.stable");
const systemTemplates = path.join(
  process.env.HOME,
  "Library",
  "Application Support",
  "Godot",
  "export_templates",
  "4.7.2.stable",
);
const output = path.join(root, "artifacts", "countryside-coop-debug.apk");

for (const required of [
  path.join(java, "bin", "java"),
  path.join(sdk, "platform-tools", "adb"),
  path.join(sdk, "build-tools", "36.1.0", "apksigner"),
  path.join(systemTemplates, "android_debug.apk"),
]) {
  if (!existsSync(required)) throw new Error(`Missing Android export dependency: ${required}`);
}

await mkdir(path.dirname(localTemplates), { recursive: true });
await mkdir(path.dirname(output), { recursive: true });
if (!existsSync(localTemplates)) await symlink(systemTemplates, localTemplates, "dir");

const settings = `[gd_resource type="EditorSettings" format=3]\n\n[resource]\nexport/android/java_sdk_path = "${java}"\nexport/android/android_sdk_path = "${sdk}"\n`;
await writeFile(editorSettings, settings);

const child = spawn(
  "godot",
  ["--headless", "--path", path.join(root, "game"), "--export-debug", "Fire OS Debug", output],
  {
    cwd: root,
    env: {
      ...process.env,
      HOME: toolingHome,
      JAVA_HOME: java,
      ANDROID_HOME: sdk,
      ANDROID_SDK_ROOT: sdk,
    },
    stdio: "inherit",
  },
);

const exitCode = await new Promise((resolve) => child.once("exit", resolve));
if (exitCode !== 0) process.exit(exitCode ?? 1);

const smoke = spawnSync("python3", [path.join(root, "scripts", "verify-fireos-assets.py"), output], {
  cwd: root,
  env: { ...process.env, HOME: toolingHome },
  stdio: "inherit",
});
if (smoke.status !== 0) process.exit(smoke.status ?? 1);

console.log(`Fire OS debug APK: ${output}`);
