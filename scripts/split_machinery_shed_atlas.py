from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / "source_assets/textures/machinery_shed_storybook_atlas_v1.png"
OUTPUT = ROOT / "game/assets/textures/machinery_shed"
OUTPUT.mkdir(parents=True, exist_ok=True)

image = Image.open(SOURCE).convert("RGBA")
half_width = image.width // 2
half_height = image.height // 2

quadrants = {
    "painted_limestone.png": (0, 0, half_width, half_height),
    "painted_timber.png": (half_width, 0, image.width, half_height),
    "painted_sage_metal.png": (0, half_height, half_width, image.height),
    "painted_cream_concrete.png": (half_width, half_height, image.width, image.height),
}

for filename, crop_box in quadrants.items():
    texture = image.crop(crop_box).resize((512, 512), Image.Resampling.LANCZOS)
    texture.save(OUTPUT / filename, optimize=True)
    print("WROTE", OUTPUT / filename)
