"""Boot the resources shipped inside an APK, independently of the source tree.

This checks desktop Godot resource loading only, not Android/Fire TV execution.
"""
import argparse
from pathlib import Path, PurePosixPath
import re
import subprocess
import tempfile
from zipfile import ZipFile


RESOURCE_ERRORS = re.compile(
    r"SCRIPT ERROR|Parse Error|Failed to load|does not exist|Error loading|"
    r"Cannot open file|No loader found|Failed loading resource", re.IGNORECASE
)


def extract_resources(apk: Path, destination: Path) -> int:
    with ZipFile(apk) as archive:
        broken = archive.testzip()
        if broken:
            raise ValueError(f"APK CRC failure: {broken}")
        count = 0
        for entry in archive.infolist():
            if not entry.filename.startswith("assets/") or entry.is_dir():
                continue
            relative = PurePosixPath(entry.filename.removeprefix("assets/"))
            if relative.is_absolute() or ".." in relative.parts or "\\" in str(relative):
                raise ValueError(f"Unsafe APK resource path: {entry.filename}")
            target = destination.joinpath(*relative.parts)
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_bytes(archive.read(entry))
            count += 1
    if not (destination / "project.binary").is_file():
        raise ValueError("APK has no exported Godot project.binary")
    return count


def boot_resources(directory: Path) -> tuple[bool, str]:
    result = subprocess.run(
        ["godot", "--headless", "--path", str(directory), "--quit-after", "3"],
        capture_output=True, text=True, timeout=30,
    )
    output = result.stdout + result.stderr
    return result.returncode == 0 and not RESOURCE_ERRORS.search(output), output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("apk", type=Path)
    parser.add_argument("--check-detector", action="store_true",
                        help="Also remove a required runtime script to prove failures are detected")
    args = parser.parse_args()
    with tempfile.TemporaryDirectory(prefix="brackenridge-apk-check-") as folder:
        directory = Path(folder)
        count = extract_resources(args.apk, directory)
        ok, output = boot_resources(directory)
        if not ok:
            raise SystemExit("APK game-resource startup failed:\n" + output)
        print(f"APK game-resource startup passed ({count} extracted resources).")
        if args.check_detector:
            # The minimap is created dynamically: scene dependency scanning alone
            # previously missed resources of this kind in release exports.
            script = directory / "scripts" / "farm_minimap.gdc"
            if not script.is_file():
                raise SystemExit("Detector check needs the exported minimap script")
            script.unlink()
            ok, output = boot_resources(directory)
            if ok or not RESOURCE_ERRORS.search(output):
                raise SystemExit("Detector accepted a deliberately incomplete game export")
            print("Detector rejected a deliberately missing dynamic minimap script.")
        print("Scope: desktop resource startup only; Fire OS runtime remains unverified.")


if __name__ == "__main__":
    main()
