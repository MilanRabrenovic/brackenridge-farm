from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
PREVIEWS = ROOT / "docs" / "previews"
OUTPUT = PREVIEWS / "storybook-existing-assets-review.png"
ITEMS = [
    ("MACHINERY SHED · BENCHMARK", PREVIEWS / "bracken-machinery-shed.png"),
    ("STONE BARN · REVISED", PREVIEWS / "bracken-stone-barn-storybook.png"),
    ("RED TRACTOR · REVISED", PREVIEWS / "bracken-tractor-storybook.png"),
    ("ENGLISH OAK · REBUILT", PREVIEWS / "english-oak-storybook.png"),
    ("HAWTHORN HEDGE · REBUILT", PREVIEWS / "hawthorn-hedge-storybook.png"),
    ("DRYSTONE WALL · REBUILT", PREVIEWS / "drystone-wall-storybook.png"),
]

font_paths = [
    Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf"),
    Path("/System/Library/Fonts/Supplemental/Arial.ttf"),
]
font_path = next((path for path in font_paths if path.exists()), None)
title_font = ImageFont.truetype(str(font_path), 36) if font_path else ImageFont.load_default()
label_font = ImageFont.truetype(str(font_path), 22) if font_path else ImageFont.load_default()

cell_w, cell_h = 600, 480
header_h, label_h, gap = 86, 42, 18
canvas = Image.new("RGB", (cell_w * 2 + gap * 3, header_h + (cell_h + label_h + gap) * 3), "#18251f")
draw = ImageDraw.Draw(canvas)
draw.text((gap, 22), "BRACKENRIDGE FARM · STORYBOOK ASSET REVIEW", font=title_font, fill="#f3e5bd")

for index, (label, path) in enumerate(ITEMS):
    row, column = divmod(index, 2)
    x = gap + column * (cell_w + gap)
    y = header_h + row * (cell_h + label_h + gap)
    source = Image.open(path).convert("RGB")
    source.thumbnail((cell_w, cell_h), Image.Resampling.LANCZOS)
    tile = Image.new("RGB", (cell_w, cell_h), "#718368")
    tile.paste(source, ((cell_w - source.width) // 2, (cell_h - source.height) // 2))
    canvas.paste(tile, (x, y))
    draw.rectangle((x, y + cell_h, x + cell_w, y + cell_h + label_h), fill="#26382f")
    draw.text((x + 14, y + cell_h + 8), label, font=label_font, fill="#f3e5bd")

canvas.save(OUTPUT, optimize=True)
print(f"WROTE {OUTPUT}")
