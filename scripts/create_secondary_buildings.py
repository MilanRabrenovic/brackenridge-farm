"""Build the authored workshop and feed store for Brackenridge Farm."""

import math
import random
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "game" / "assets" / "buildings"
PREVIEW = ROOT / "docs" / "previews" / "bracken-secondary-buildings.png"
SHED_TEXTURES = ROOT / "game" / "assets" / "textures" / "machinery_shed"
SHARED_TEXTURES = ROOT / "game" / "assets" / "textures" / "storybook_shared"
ASSETS.mkdir(parents=True, exist_ok=True)
PREVIEW.parent.mkdir(parents=True, exist_ok=True)
random.seed(2247)
bpy.ops.wm.read_factory_settings(use_empty=True)


def painted(name, path, scale=(1.0, 1.0), roughness=0.92, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    image = mat.node_tree.nodes.new("ShaderNodeTexImage")
    image.image = bpy.data.images.load(str(path), check_existing=True)
    image.extension = "REPEAT"
    coords = mat.node_tree.nodes.new("ShaderNodeTexCoord")
    mapping = mat.node_tree.nodes.new("ShaderNodeMapping")
    mapping.inputs["Scale"].default_value = (scale[0], scale[1], 1.0)
    mat.node_tree.links.new(coords.outputs["UV"], mapping.inputs["Vector"])
    mat.node_tree.links.new(mapping.outputs["Vector"], image.inputs["Vector"])
    mat.node_tree.links.new(image.outputs["Color"], shader.inputs["Base Color"])
    return mat


def flat(name, color, roughness=0.9, metallic=0.0, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1)
        shader.inputs["Emission Strength"].default_value = 1.5
    return mat


stone = painted("Secondary painted limestone", SHED_TEXTURES / "painted_limestone.png", (1.4, 1.25))
timber = painted("Secondary painted chestnut", SHED_TEXTURES / "painted_timber.png", (1.8, 1.25))
sage = painted("Secondary painted sage metal", SHED_TEXTURES / "painted_sage_metal.png", (2.0, 1.45), 0.80, 0.08)
concrete = painted("Secondary painted concrete", SHED_TEXTURES / "painted_cream_concrete.png", (2.2, 2.2), 0.96)
slate = painted("Secondary painted slate", SHARED_TEXTURES / "painted_slate.png", (2.0, 1.5), 0.92)
red = painted("Secondary painted red enamel", SHARED_TEXTURES / "painted_red_enamel.png", (1.5, 1.2), 0.78, 0.08)
dark = flat("Secondary deep forest frame", (0.055, 0.19, 0.12), 0.78, 0.12)
cream = flat("Secondary warm cream trim", (0.91, 0.76, 0.47), 0.88)
blue = flat("Secondary sky-blue glass", (0.13, 0.45, 0.55), 0.30, 0.02)
ochre = flat("Secondary sunny ochre", (0.94, 0.55, 0.08), 0.82)
grain = flat("Secondary feed sack gold", (0.82, 0.57, 0.20), 0.96)
interior = flat("Secondary warm interior", (0.075, 0.105, 0.065), 0.98)
lamp = flat("Secondary golden lamp", (1.0, 0.64, 0.16), 0.34, emission=(1.0, 0.50, 0.12))


def parent(obj, owner):
    obj.parent = owner
    return obj


def bevel(obj, width=0.04, segments=2):
    if width <= 0:
        return obj
    modifier = obj.modifiers.new("Soft storybook edge", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)
    return obj


def cube(owner, name, loc, size, material, edge=0.04, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, owner)


def cylinder(owner, name, loc, radius, depth, material, rot=(0, 0, 0), vertices=20, edge=0.04):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, owner)


def beam(owner, name, start, end, thickness, material):
    a, b = Vector(start), Vector(end)
    obj = cube(owner, name, (a + b) * 0.5, (thickness, thickness, (b - a).length), material, min(0.045, thickness * 0.16))
    obj.rotation_euler = (b - a).to_track_quat("Z", "Y").to_euler()
    return obj


def join_material_groups(owner):
    groups = {}
    for obj in list(owner.children_recursive):
        if obj.type != "MESH" or not obj.material_slots or obj.material_slots[0].material is None:
            continue
        groups.setdefault((obj.parent, obj.material_slots[0].material.name), []).append(obj)
    for (obj_parent, material_name), objects in groups.items():
        if len(objects) == 1:
            objects[0].name = material_name
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = objects[0]
        bpy.ops.object.join()
        objects[0].name = material_name
        objects[0].parent = obj_parent


def export(owner, path):
    join_material_groups(owner)
    bpy.ops.object.select_all(action="DESELECT")
    owner.select_set(True)
    for obj in owner.children_recursive:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = owner
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True, export_yup=True)


def gable_roof(owner, width, depth, eave, ridge, material, trim_material, prefix):
    rise = ridge - eave
    pitch = math.atan2(rise, depth * 0.5)
    slope = math.sqrt((depth * 0.5) ** 2 + rise ** 2)
    for side in (-1, 1):
        y = side * depth * 0.25
        z = (eave + ridge) * 0.5
        cube(owner, f"{prefix} roof plane", (0, y, z), (width + 0.8, slope + 0.45, 0.20), material, 0.05, (-side * pitch, 0, 0))
        seam_count = max(5, int(width / 1.55))
        for index in range(seam_count):
            x = -width * 0.5 + 0.65 + index * (width - 1.3) / max(1, seam_count - 1)
            cube(owner, f"{prefix} roof seam", (x, y - side * 0.035, z + 0.105), (0.045, slope + 0.12, 0.04), dark, 0.01, (-side * pitch, 0, 0))
    cube(owner, f"{prefix} ridge cap", (0, 0, ridge + 0.08), (width + 0.9, 0.38, 0.24), trim_material, 0.055)


def make_workshop():
    owner = bpy.data.objects.new("BrackenWorkshop", None)
    bpy.context.collection.objects.link(owner)
    width, depth, eave, ridge = 15.5, 10.5, 5.2, 7.2
    front, back = -depth * 0.5, depth * 0.5
    cube(owner, "Workshop apron", (0, -1.0, 0.06), (17.5, 13.0, 0.18), concrete, 0.08)
    cube(owner, "Workshop rear stone wall", (0, back - 0.16, 2.45), (width, 0.34, 4.9), stone, 0.06)
    cube(owner, "Workshop left stone wall", (-width * 0.5 + 0.16, 0, 2.45), (0.34, depth, 4.9), stone, 0.06)
    cube(owner, "Workshop right stone wall", (width * 0.5 - 0.16, 0, 2.45), (0.34, depth, 4.9), stone, 0.06)
    # The front reads as a working two-bay building rather than a decorated cube.
    for x, block_width in ((-7.25, 1.0), (0.0, 0.72), (6.25, 3.0)):
        cube(owner, "Workshop front pier", (x, front + 0.14, 2.45), (block_width, 0.38, 4.9), stone, 0.06)
    cube(owner, "Workshop front head", (-2.7, front + 0.14, 4.78), (8.8, 0.38, 0.55), dark, 0.05)
    cube(owner, "Workshop timber loft band", (0, back - 0.36, 4.52), (width - 0.55, 0.18, 1.0), timber, 0.035)
    gable_roof(owner, width, depth, eave, ridge, slate, cream, "Workshop slate")
    # Open service bay with a warm, legible interior and chunky repair props.
    cube(owner, "Workshop open bay interior", (-3.65, front + 0.28, 2.35), (6.45, 0.12, 4.4), interior, 0.02)
    cube(owner, "Workshop service ramp", (-3.65, front - 1.25, 0.16), (6.7, 3.0, 0.18), concrete, 0.06)
    cube(owner, "Workshop inspection platform", (-3.7, -0.3, 0.28), (5.4, 4.4, 0.38), dark, 0.06)
    for x in (-5.65, -1.75):
        cube(owner, "Workshop platform stripe", (x, -0.3, 0.50), (0.20, 4.0, 0.05), ochre, 0.015)
    cube(owner, "Workshop red tool cabinet", (-6.0, 2.85, 1.05), (1.25, 0.7, 1.9), red, 0.10)
    cube(owner, "Workshop bench", (-2.7, 3.15, 1.05), (4.4, 0.85, 0.25), timber, 0.06)
    for x in (-4.45, -0.95):
        cube(owner, "Workshop bench leg", (x, 3.15, 0.55), (0.22, 0.62, 1.0), dark, 0.03)
    # Enclosed office/tool room with a cheerful red sliding door and window.
    cube(owner, "Workshop sliding door", (3.6, front - 0.09, 2.28), (5.0, 0.17, 4.35), red, 0.06)
    for x in (1.55, 2.35, 3.15, 3.95, 4.75, 5.55):
        cube(owner, "Workshop door rib", (x, front - 0.19, 2.28), (0.055, 0.05, 4.05), cream, 0.01)
    cube(owner, "Workshop side window trim", (width * 0.5 + 0.03, 1.6, 2.75), (0.12, 2.7, 2.05), cream, 0.04)
    cube(owner, "Workshop side window glass", (width * 0.5 + 0.10, 1.6, 2.75), (0.05, 2.35, 1.7), blue, 0.02)
    # Gable truss, round vent and roof chimney break the roof silhouette.
    beam(owner, "Workshop gable beam left", (-7.3, front - 0.08, eave), (0, front - 0.08, ridge), 0.22, cream)
    beam(owner, "Workshop gable beam right", (0, front - 0.08, ridge), (7.3, front - 0.08, eave), 0.22, cream)
    cylinder(owner, "Workshop round gable vent", (0, front - 0.20, 5.78), 0.62, 0.18, blue, (math.pi / 2, 0, 0), 24, 0.06)
    cylinder(owner, "Workshop vent cream rim", (0, front - 0.30, 5.78), 0.78, 0.12, cream, (math.pi / 2, 0, 0), 24, 0.06)
    cylinder(owner, "Workshop vent face", (0, front - 0.38, 5.78), 0.57, 0.05, blue, (math.pi / 2, 0, 0), 24, 0.03)
    cube(owner, "Workshop roof flue", (5.3, 1.1, 7.15), (0.72, 0.72, 2.0), dark, 0.08)
    cube(owner, "Workshop flue cap", (5.3, 1.1, 8.17), (1.0, 1.0, 0.18), cream, 0.07)
    for x in (-6.2, -0.4, 6.0):
        cube(owner, "Workshop golden lamp", (x, front - 0.18, 4.60), (0.50, 0.28, 0.28), lamp, 0.08)
    cube(owner, "Workshop sign board", (3.6, front - 0.22, 4.68), (3.5, 0.16, 0.72), cream, 0.08)
    for x in (2.7, 3.6, 4.5):
        cylinder(owner, "Workshop sign cog", (x, front - 0.34, 4.68), 0.20, 0.08, red, (math.pi / 2, 0, 0), 12, 0.035)
    return owner


def make_feed_store():
    owner = bpy.data.objects.new("BrackenFeedStore", None)
    bpy.context.collection.objects.link(owner)
    width, depth, eave, ridge = 11.2, 7.2, 4.15, 5.75
    front, back = -depth * 0.5, depth * 0.5
    cube(owner, "Feed store apron", (0, -1.0, 0.06), (13.0, 9.8, 0.18), concrete, 0.08)
    cube(owner, "Feed rear wall", (0, back - 0.15, 2.05), (width, 0.34, 4.1), stone, 0.06)
    cube(owner, "Feed left wall", (-width * 0.5 + 0.15, 0, 2.05), (0.34, depth, 4.1), stone, 0.06)
    cube(owner, "Feed right wall", (width * 0.5 - 0.15, 0, 2.05), (0.34, depth, 4.1), stone, 0.06)
    for x, block_width in ((-4.85, 1.5), (4.85, 1.5)):
        cube(owner, "Feed front pier", (x, front + 0.15, 2.05), (block_width, 0.36, 4.1), stone, 0.06)
    cube(owner, "Feed door head", (0, front + 0.15, 3.76), (8.4, 0.36, 0.7), timber, 0.05)
    gable_roof(owner, width, depth, eave, ridge, slate, cream, "Feed store slate")
    # Wide open Dutch-style doors and visible stock make its purpose clear.
    cube(owner, "Feed doorway shadow", (0, front + 0.27, 1.95), (8.1, 0.10, 3.55), interior, 0.02)
    for side in (-1, 1):
        door = cube(owner, "Feed open green door", (side * 4.15, front - 0.65, 1.92), (3.25, 0.18, 3.55), sage, 0.07, (0, 0, side * math.radians(18)))
        for z in (0.8, 1.92, 3.05):
            cube(owner, "Feed door brace", (door.location.x, door.location.y - 0.10, z), (2.8, 0.07, 0.14), cream, 0.02, (0, 0, side * math.radians(18)))
    # Loading porch projects forward with two chunky timber posts.
    cube(owner, "Feed porch roof", (0, front - 1.55, 4.12), (9.8, 3.2, 0.22), sage, 0.07, (math.radians(-6), 0, 0))
    for x in (-4.4, 4.4):
        cube(owner, "Feed porch post", (x, front - 2.85, 2.0), (0.40, 0.40, 4.0), timber, 0.07)
        cube(owner, "Feed porch stone foot", (x, front - 2.85, 0.25), (0.72, 0.72, 0.48), stone, 0.08)
    beam(owner, "Feed porch beam", (-4.5, front - 2.85, 3.95), (4.5, front - 2.85, 3.95), 0.34, timber)
    # Pallets and sacks stay chunky enough to read from the gameplay camera.
    for row in range(2):
        for index in range(5):
            x = -2.8 + index * 1.4 + (0.32 if row else 0)
            y = 1.3 + row * 1.15
            cube(owner, "Feed sack", (x, y, 0.42), (1.15, 0.78, 0.62), grain if index % 2 else cream, 0.22, (0, 0, (-0.07 + index * 0.025)))
    cube(owner, "Feed pallet", (0, 1.9, 0.13), (8.0, 2.8, 0.20), timber, 0.05)
    # An owl-eye vent and straw emblem make the small building memorable.
    cylinder(owner, "Feed round vent rim", (0, front - 0.19, 4.82), 0.66, 0.16, cream, (math.pi / 2, 0, 0), 24, 0.06)
    cylinder(owner, "Feed round vent", (0, front - 0.30, 4.82), 0.50, 0.08, blue, (math.pi / 2, 0, 0), 24, 0.04)
    for x in (-0.18, 0.18):
        cylinder(owner, "Feed vent eye", (x, front - 0.37, 4.84), 0.10, 0.04, dark, (math.pi / 2, 0, 0), 16, 0.02)
    cube(owner, "Feed sign board", (0, front - 2.98, 3.35), (4.2, 0.18, 0.75), cream, 0.08)
    for x in (-0.8, 0, 0.8):
        cube(owner, "Feed sign straw", (x, front - 3.10, 3.35), (0.15, 0.05, 0.45), ochre, 0.03, (0, 0, math.radians(x * 10)))
    for x in (-3.4, 3.4):
        cube(owner, "Feed golden lamp", (x, front - 3.02, 3.70), (0.46, 0.28, 0.26), lamp, 0.08)
    return owner


workshop = make_workshop()
feed_store = make_feed_store()
export(workshop, ASSETS / "bracken_workshop.glb")
export(feed_store, ASSETS / "bracken_feed_store.glb")

# Standalone review composition using the same close isometric direction as gameplay.
workshop.location = (-9.5, 2.5, 0)
workshop.rotation_euler[2] = math.radians(-5)
feed_store.location = (9.0, -1.5, 0)
feed_store.rotation_euler[2] = math.radians(7)
bpy.ops.mesh.primitive_plane_add(size=52, location=(0, 0, -0.08))
bpy.context.object.data.materials.append(flat("Secondary review meadow", (0.34, 0.51, 0.20), 0.98))
bpy.ops.object.light_add(type="AREA", location=(-14, -16, 22))
bpy.context.object.data.energy = 3400
bpy.context.object.data.size = 12
bpy.ops.object.light_add(type="AREA", location=(15, 5, 12))
bpy.context.object.data.energy = 1200
bpy.context.object.data.size = 9
bpy.ops.object.camera_add(location=(27, -34, 24))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 2.7)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 34.0
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1400
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(PREVIEW)
scene.world = bpy.data.worlds.new("Secondary building review world")
scene.world.color = (0.18, 0.29, 0.34)
scene.view_settings.look = "AgX - Medium High Contrast"
bpy.ops.render.render(write_still=True)
print("WROTE", ASSETS / "bracken_workshop.glb")
print("WROTE", ASSETS / "bracken_feed_store.glb")
print("WROTE", PREVIEW)
