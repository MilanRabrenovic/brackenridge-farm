import math
import os
import random
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
GAME_ASSETS = ROOT / "game" / "assets"
PREVIEW_DIR = ROOT / "docs" / "previews"
SHARED_TEXTURES = GAME_ASSETS / "textures" / "storybook_shared"
SHED_TEXTURES = GAME_ASSETS / "textures" / "machinery_shed"

RED = SHARED_TEXTURES / "painted_red_enamel.png"
SLATE = SHARED_TEXTURES / "painted_slate.png"
STEEL = SHARED_TEXTURES / "painted_farm_steel.png"
RUBBER = SHARED_TEXTURES / "painted_tractor_rubber.png"
OAK_BARK = SHARED_TEXTURES / "painted_oak_bark.png"
OAK_FOLIAGE = SHARED_TEXTURES / "painted_oak_foliage.png"
HAWTHORN = SHARED_TEXTURES / "painted_hawthorn.png"
DRYSTONE = SHARED_TEXTURES / "painted_drystone.png"
LIMESTONE = SHED_TEXTURES / "painted_limestone.png"
TIMBER = SHED_TEXTURES / "painted_timber.png"

for path in (RED, SLATE, STEEL, RUBBER, OAK_BARK, OAK_FOLIAGE, HAWTHORN, DRYSTONE, LIMESTONE, TIMBER):
    if not path.exists():
        raise FileNotFoundError(path)

PREVIEW_DIR.mkdir(parents=True, exist_ok=True)


def reset() -> None:
    bpy.ops.wm.read_factory_settings(use_empty=True)


def painted_material(name: str, texture_path: Path, roughness: float = 0.88, metallic: float = 0.0, texture_scale=(1.0, 1.0)):
    material = bpy.data.materials.new(name)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    image_node = material.node_tree.nodes.new("ShaderNodeTexImage")
    image_node.image = bpy.data.images.load(str(texture_path), check_existing=True)
    image_node.extension = "REPEAT"
    image_node.interpolation = "Linear"
    coordinates = material.node_tree.nodes.new("ShaderNodeTexCoord")
    mapping = material.node_tree.nodes.new("ShaderNodeMapping")
    mapping.vector_type = "POINT"
    mapping.inputs["Scale"].default_value = (texture_scale[0], texture_scale[1], 1.0)
    material.node_tree.links.new(coordinates.outputs["UV"], mapping.inputs["Vector"])
    material.node_tree.links.new(mapping.outputs["Vector"], image_node.inputs["Vector"])
    material.node_tree.links.new(image_node.outputs["Color"], shader.inputs["Base Color"])
    return material


def flat_material(name: str, color, roughness: float = 0.88, metallic: float = 0.0, emission=None):
    material = bpy.data.materials.new(name)
    material.diffuse_color = (*color, 1)
    material.use_nodes = True
    shader = material.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1)
        shader.inputs["Emission Strength"].default_value = 1.25
    return material


def replace_materials(replacements: dict[str, object]) -> None:
    for obj in bpy.context.scene.objects:
        if obj.type != "MESH":
            continue
        for slot in obj.material_slots:
            if slot.material and slot.material.name in replacements:
                slot.material = replacements[slot.material.name]


def selected_export(path: Path, root) -> None:
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for child in root.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )


def point_camera(camera, target) -> None:
    camera.rotation_euler = (Vector(target) - camera.location).to_track_quat("-Z", "Y").to_euler()


def render_preview(path: Path, camera_location, target, ortho_scale: float, ground_color=(0.32, 0.45, 0.25)) -> None:
    ground = flat_material("Review meadow", ground_color, 0.98)
    bpy.ops.mesh.primitive_plane_add(size=40, location=(0, 0, -0.035))
    bpy.context.object.data.materials.append(ground)

    bpy.ops.object.light_add(type="AREA", location=(-5.5, -6.0, 10.5))
    key = bpy.context.object
    key.data.energy = 900
    key.data.shape = "DISK"
    key.data.size = 7.5
    bpy.ops.object.light_add(type="AREA", location=(6.0, 1.5, 6.0))
    fill = bpy.context.object
    fill.data.energy = 420
    fill.data.size = 6.0

    bpy.ops.object.camera_add(location=camera_location)
    camera = bpy.context.object
    point_camera(camera, target)
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = ortho_scale

    scene = bpy.context.scene
    scene.camera = camera
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 1000
    scene.render.resolution_y = 800
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(path)
    scene.render.film_transparent = False
    scene.world = bpy.data.worlds.new("Warm review sky")
    scene.world.color = (0.12, 0.19, 0.20)
    scene.view_settings.look = "AgX - Medium High Contrast"
    bpy.ops.render.render(write_still=True)
    print(f"WROTE {path}")


def import_root(path: Path, expected_name: str):
    bpy.ops.import_scene.gltf(filepath=str(path))
    root = bpy.data.objects.get(expected_name)
    if root is None:
        roots = [obj for obj in bpy.context.scene.objects if obj.parent is None]
        root = roots[0]
    return root


def upgrade_barn() -> None:
    reset()
    path = GAME_ASSETS / "buildings" / "bracken_stone_barn.glb"
    root = import_root(path, "BrackenStoneBarn")

    limestone = painted_material("Storybook Honey Limestone", LIMESTONE, 0.94, texture_scale=(1.35, 1.35))
    slate = painted_material("Storybook Blue Grey Slate", SLATE, 0.92, texture_scale=(5.5, 3.5))
    timber = painted_material("Storybook Chestnut Oak", TIMBER, 0.94, texture_scale=(1.8, 1.4))
    steel = painted_material("Storybook Forged Iron", STEEL, 0.78, 0.18, texture_scale=(1.4, 1.4))
    foliage = painted_material("Storybook Ivy", OAK_FOLIAGE, 0.96, texture_scale=(1.4, 1.4))
    replacements = {}
    for material in bpy.data.materials:
        name = material.name
        if name.startswith("Cotswold Limestone") or name == "Warm Lime Mortar" or name.startswith("Storybook Honey Limestone"):
            replacements[name] = limestone
        elif "Slate" in name or name == "Roof Moss" or name.startswith("Storybook Blue Grey Slate"):
            replacements[name] = slate
        elif name in ("Aged English Oak", "Worn Oak Edge") or name.startswith("Storybook Chestnut Oak"):
            replacements[name] = timber
        elif name == "Black Forged Iron" or name.startswith("Storybook Forged Iron"):
            replacements[name] = steel
        elif name in ("Ivy Leaf", "Ivy Tip") or name.startswith("Storybook Ivy"):
            replacements[name] = foliage
    replace_materials(replacements)
    selected_export(path, root)
    render_preview(PREVIEW_DIR / "bracken-stone-barn-storybook.png", (13.5, -17.0, 11.5), (0, 0, 2.65), 19.0)


def upgrade_tractor() -> None:
    reset()
    path = GAME_ASSETS / "vehicles" / "bracken_tractor.glb"
    root = import_root(path, "BrackenTractor")

    enamel = painted_material("Storybook Warm Red Enamel", RED, 0.68, 0.08, texture_scale=(1.35, 1.35))
    steel = painted_material("Storybook Farm Steel", STEEL, 0.72, 0.24, texture_scale=(1.6, 1.6))
    rubber = painted_material("Storybook Agricultural Rubber", RUBBER, 0.94, texture_scale=(1.2, 1.2))
    replacements = {}
    for material in bpy.data.materials:
        name = material.name
        if name in ("Deep Red Enamel", "Sunlit Red Enamel", "Shadow Red", "Safety Red") or name.startswith("Storybook Warm Red Enamel"):
            replacements[name] = enamel
        elif name in ("Graphite Chassis", "Weathered Steel") or name.startswith("Storybook Farm Steel"):
            replacements[name] = steel
        elif name == "Agricultural Rubber" or name.startswith("Storybook Agricultural Rubber"):
            replacements[name] = rubber
    replace_materials(replacements)
    selected_export(path, root)
    render_preview(PREVIEW_DIR / "bracken-tractor-storybook.png", (8.3, -10.8, 6.8), (0, -0.15, 1.55), 6.9)


def bevel(obj, width=0.04, segments=2) -> None:
    modifier = obj.modifiers.new("Soft storybook edge", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)


def parent(obj, root):
    obj.parent = root
    return obj


def cube(name, location, size, material, root, edge=0.04, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, root)


def tapered_branch(name, start, end, base_radius, tip_radius, material, root):
    start_v = Vector(start)
    end_v = Vector(end)
    delta = end_v - start_v
    bpy.ops.mesh.primitive_cone_add(
        vertices=14,
        radius1=base_radius,
        radius2=tip_radius,
        depth=delta.length,
        location=(start_v + end_v) * 0.5,
    )
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = delta.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(material)
    return parent(obj, root)


def irregular_blob(name, location, scale, material, root, seed):
    random.seed(seed)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1, location=location)
    obj = bpy.context.object
    obj.name = name
    for vertex in obj.data.vertices:
        direction = vertex.co.normalized()
        factor = 1.0 + 0.12 * math.sin(direction.x * 7.3 + seed) + 0.07 * math.sin(direction.y * 11.1 - seed)
        vertex.co *= factor
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    return parent(obj, root)


def create_oak() -> None:
    reset()
    random.seed(4021)
    root = bpy.data.objects.new("BrackenEnglishOak", None)
    bpy.context.collection.objects.link(root)
    bark = painted_material("Storybook Oak Bark", OAK_BARK, 0.98, texture_scale=(1.25, 1.4))
    foliage = painted_material("Storybook Oak Foliage", OAK_FOLIAGE, 0.96, texture_scale=(1.35, 1.35))

    tapered_branch("Broad tapered trunk", (0, 0, 0), (0.05, 0, 4.35), 0.72, 0.38, bark, root)
    branch_data = [
        ((0, 0, 3.25), (-2.05, 0.10, 5.15), 0.31, 0.11),
        ((0.02, 0, 3.55), (2.30, 0.25, 5.25), 0.34, 0.12),
        ((0.0, 0.05, 3.7), (-0.45, 1.95, 5.35), 0.27, 0.10),
        ((0.0, -0.03, 3.85), (0.55, -1.75, 5.45), 0.25, 0.09),
        ((0.02, 0, 4.0), (0.25, 0.25, 6.35), 0.28, 0.08),
    ]
    for index, data in enumerate(branch_data):
        tapered_branch(f"Tapered branch {index + 1}", *data, bark, root)
    for index, angle in enumerate((0.15, 1.85, 3.35, 4.95)):
        start = Vector((math.cos(angle) * 0.34, math.sin(angle) * 0.34, 0.35))
        end = Vector((math.cos(angle) * 1.18, math.sin(angle) * 1.18, 0.08))
        tapered_branch(f"Buttress root {index + 1}", start, end, 0.20, 0.05, bark, root)
    crown_data = [
        ((-2.0, 0.0, 5.65), (2.25, 1.65, 1.55)),
        ((0.0, -0.45, 6.15), (2.45, 1.95, 1.75)),
        ((2.15, 0.18, 5.70), (2.18, 1.70, 1.52)),
        ((-0.40, 1.65, 5.65), (2.10, 1.55, 1.40)),
        ((0.55, -1.65, 5.45), (1.95, 1.48, 1.38)),
        ((-1.15, 0.65, 6.90), (1.78, 1.48, 1.32)),
        ((1.15, 0.65, 6.85), (1.72, 1.45, 1.28)),
    ]
    for index, (location, scale) in enumerate(crown_data):
        irregular_blob(f"Hand shaped crown lobe {index + 1}", location, scale, foliage, root, 410 + index)
    selected_export(GAME_ASSETS / "environment" / "english_oak.glb", root)
    render_preview(PREVIEW_DIR / "english-oak-storybook.png", (10.0, -13.0, 8.2), (0, 0, 3.8), 10.7)


def hedgerow_mesh(material, root):
    xs = (-3.2, -2.4, -1.5, -0.55, 0.35, 1.3, 2.25, 3.2)
    heights = (1.65, 1.92, 1.72, 2.03, 1.78, 1.98, 1.70, 1.84)
    widths = (0.72, 0.88, 0.80, 0.92, 0.79, 0.91, 0.76, 0.70)
    vertices = []
    ring = 6
    for x, height, width in zip(xs, heights, widths):
        vertices.extend([
            (x, -width, 0.16),
            (x, -width, height * 0.70),
            (x, -width * 0.46, height),
            (x, width * 0.46, height * 0.98),
            (x, width, height * 0.68),
            (x, width, 0.16),
        ])
    faces = []
    for section in range(len(xs) - 1):
        for side in range(ring):
            nxt = (side + 1) % ring
            a = section * ring + side
            b = section * ring + nxt
            c = (section + 1) * ring + nxt
            d = (section + 1) * ring + side
            faces.append((a, b, c, d))
    faces.append(tuple(range(ring - 1, -1, -1)))
    last = (len(xs) - 1) * ring
    faces.append(tuple(last + index for index in range(ring)))
    mesh = bpy.data.meshes.new("Irregular hedgerow mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(material)
    obj = bpy.data.objects.new("Continuous hand-shaped hawthorn", mesh)
    bpy.context.collection.objects.link(obj)
    parent(obj, root)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.03)
    bpy.ops.object.mode_set(mode="OBJECT")
    obj.select_set(False)
    bevel(obj, 0.10, 3)


def create_hedge() -> None:
    reset()
    root = bpy.data.objects.new("BrackenHawthornHedge", None)
    bpy.context.collection.objects.link(root)
    foliage = painted_material("Storybook Flowering Hawthorn", HAWTHORN, 0.96, texture_scale=(1.8, 1.3))
    bark = painted_material("Storybook Hedge Twigs", OAK_BARK, 0.98, texture_scale=(1.2, 1.5))
    hedgerow_mesh(foliage, root)
    for index, x in enumerate((-2.65, -1.55, -0.35, 0.95, 2.20)):
        lean = -0.14 if index % 2 else 0.12
        tapered_branch(f"Visible hedge stem {index + 1}", (x, 0, 0.05), (x + lean, 0.05, 1.28), 0.095, 0.035, bark, root)
    selected_export(GAME_ASSETS / "environment" / "hawthorn_hedge.glb", root)
    render_preview(PREVIEW_DIR / "hawthorn-hedge-storybook.png", (7.6, -10.0, 5.2), (0, 0, 0.95), 8.0)


def create_wall() -> None:
    reset()
    random.seed(8851)
    root = bpy.data.objects.new("BrackenDryStoneWall", None)
    bpy.context.collection.objects.link(root)
    stone = painted_material("Storybook Cotswold Drystone", DRYSTONE, 0.98, texture_scale=(0.8, 0.8))
    moss = flat_material("Warm olive wall moss", (0.27, 0.38, 0.09), 0.98)
    course_z = (0.22, 0.58, 0.91)
    course_h = (0.38, 0.34, 0.30)
    for course, (z, height) in enumerate(zip(course_z, course_h)):
        x = -3.30 + (0.22 if course % 2 else 0)
        while x < 3.28:
            width = random.uniform(0.52, 1.02)
            center = min(x + width * 0.5, 3.10)
            actual = min(width - 0.045, 3.32 - x)
            depth = random.uniform(0.62, 0.76) - course * 0.05
            obj = cube(
                "Irregular hand-stacked stone",
                (center, random.uniform(-0.035, 0.035), z),
                (actual, depth, height - 0.035),
                stone,
                root,
                random.uniform(0.045, 0.075),
                (random.uniform(-0.025, 0.025), random.uniform(-0.025, 0.025), random.uniform(-0.045, 0.045)),
            )
            x += width
    x = -3.15
    while x < 3.18:
        width = random.uniform(0.72, 1.15)
        cube("Broad uneven capstone", (x + width * 0.5, 0, 1.14 + random.uniform(-0.025, 0.025)), (width - 0.04, 0.82, 0.27), stone, root, 0.07, (0, 0, random.uniform(-0.04, 0.04)))
        x += width
    for x in (-2.4, -0.55, 1.45):
        cube("Moss pocket", (x, -0.405, 0.88), (0.42, 0.035, 0.10), moss, root, 0.035)
    selected_export(GAME_ASSETS / "environment" / "dry_stone_wall.glb", root)
    render_preview(PREVIEW_DIR / "drystone-wall-storybook.png", (7.0, -9.0, 4.7), (0, 0, 0.62), 7.7)


upgrade_barn()
upgrade_tractor()
create_oak()
create_hedge()
create_wall()
print("STORYBOOK_EXISTING_ASSETS_COMPLETE")
