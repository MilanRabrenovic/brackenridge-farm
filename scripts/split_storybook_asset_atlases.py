from pathlib import Path

from PIL import Image, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "source_assets" / "textures"
OUTPUT = ROOT / "game" / "assets" / "textures" / "storybook_shared"


def split_atlas(source_name: str, names: tuple[str, str, str, str]) -> None:
    source_path = SOURCE / source_name
    image = Image.open(source_path).convert("RGB")
    width, height = image.size
    half_w, half_h = width // 2, height // 2
    boxes = (
        (0, 0, half_w, half_h),
        (half_w, 0, width, half_h),
        (0, half_h, half_w, height),
        (half_w, half_h, width, height),
    )
    for name, box in zip(names, boxes):
        target = OUTPUT / name
        target.parent.mkdir(parents=True, exist_ok=True)
        cropped = image.crop(box).resize((512, 512), Image.Resampling.LANCZOS)
        if name == "painted_red_enamel.png":
            # The generated source contains attractive brush wear but also a few
            # strong horizontal joins. Soften them into paint variation before
            # the material is tiled across large bonnet and roof surfaces.
            softened = cropped.filter(ImageFilter.GaussianBlur(radius=13))
            cropped = Image.blend(softened, cropped, 0.28)
        cropped.save(target, optimize=True)
        print(f"WROTE {target}")


split_atlas(
    "heritage_machinery_storybook_atlas_v1.png",
    ("painted_red_enamel.png", "painted_slate.png", "painted_farm_steel.png", "painted_tractor_rubber.png"),
)
split_atlas(
    "countryside_nature_storybook_atlas_v1.png",
    ("painted_oak_bark.png", "painted_oak_foliage.png", "painted_hawthorn.png", "painted_drystone.png"),
)
