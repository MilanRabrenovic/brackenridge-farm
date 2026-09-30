import math
import os
import random
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "game" / "assets" / "buildings"
GLB = OUT / "bracken_grain_store.glb"
PREVIEW = ROOT / "docs" / "previews" / "bracken-grain-store.png"
TRACTOR = ROOT / "game" / "assets" / "vehicles" / "bracken_tractor.glb"
SHED_TEXTURES = ROOT / "game" / "assets" / "textures" / "machinery_shed"
SHARED_TEXTURES = ROOT / "game" / "assets" / "textures" / "storybook_shared"
OUT.mkdir(parents=True, exist_ok=True)
PREVIEW.parent.mkdir(parents=True, exist_ok=True)
random.seed(8426)

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
        shader.inputs["Emission Strength"].default_value = 1.6
    return mat


stone = painted("Painted honey limestone", SHED_TEXTURES / "painted_limestone.png", (1.5, 1.3))
timber = painted("Painted chestnut grain-store timber", SHED_TEXTURES / "painted_timber.png", (2.0, 1.35))
sage = painted("Painted sage grain-store metal", SHED_TEXTURES / "painted_sage_metal.png", (2.4, 1.7), 0.78, 0.08)
concrete = painted("Painted warm concrete", SHED_TEXTURES / "painted_cream_concrete.png", (2.4, 2.4), 0.96)
slate = painted("Painted blue slate", SHARED_TEXTURES / "painted_slate.png", (2.0, 1.5), 0.9)
steel = flat("Deep green structural steel", (0.07, 0.24, 0.15), 0.72, 0.16)
cream = flat("Warm cream trim", (0.88, 0.72, 0.42), 0.88)
ochre = flat("Intake safety ochre", (0.96, 0.57, 0.06), 0.8)
red = flat("Warm warning red", (0.75, 0.10, 0.045), 0.78)
blue = flat("Friendly indicator blue", (0.10, 0.42, 0.68), 0.72)
grain = flat("Stored barley gold", (0.83, 0.57, 0.13), 0.98)
dark = flat("Intake shadow", (0.045, 0.065, 0.052), 0.98)
grate = flat("Intake grate steel", (0.19, 0.29, 0.25), 0.62, 0.3)
lamp = flat("Golden work light", (1.0, 0.62, 0.14), 0.32, emission=(1.0, 0.48, 0.10))

root = bpy.data.objects.new("BrackenGrainStore", None)
bpy.context.collection.objects.link(root)


def parent(obj, target=root):
    obj.parent = target
    return obj


def bevel(obj, width=0.04, segments=2):
    if width <= 0:
        return obj
    mod = obj.modifiers.new("Soft storybook edge", "BEVEL")
    mod.width = width
    mod.segments = segments
    mod.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.select_set(False)
    return obj


def cube(name, loc, size, mat, edge=0.04, rot=(0, 0, 0), target=root):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(mat)
    return parent(obj, target)


def cylinder(name, loc, radius, depth, mat, rot=(0, 0, 0), vertices=18, edge=0.035, target=root):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge)
    obj.data.materials.append(mat)
    return parent(obj, target)


def beam(name, start, end, thickness, mat, target=root):
    a, b = Vector(start), Vector(end)
    delta = b - a
    obj = cube(name, (a + b) * 0.5, (thickness, thickness, delta.length), mat, min(0.045, thickness * 0.18), target=target)
    obj.rotation_euler = delta.to_track_quat("Z", "Y").to_euler()
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


# A broad slab proves that a tractor and trailer can approach, cross the pit,
# and leave through the rear instead of reversing in a tight decorative yard.
cube("Working apron", (0, -1.0, 0.04), (28.0, 22.0, 0.16), concrete, 0.09)
for x in (1.6, 10.4):
    cube("Ochre lane edge", (x, -2.0, 0.145), (0.18, 18.0, 0.035), ochre, 0.012)
for y in (-9.0, 7.0):
    cube("Lane threshold", (6.0, y, 0.15), (8.8, 0.20, 0.04), ochre, 0.012)

# Left: enclosed grain hall with a large open front bay and visible contents.
HALL_LEFT, HALL_RIGHT = -13.0, 1.0
FRONT, BACK = -7.0, 7.0
EAVE, RIDGE = 6.0, 8.35
cube("Grain hall rear wall", (-6.0, BACK - 0.12, 3.0), (14.0, 0.30, 6.0), timber, 0.05)
cube("Grain hall left wall", (HALL_LEFT + 0.13, 0, 3.0), (0.30, 14.0, 6.0), timber, 0.05)
cube("Grain hall right wall", (HALL_RIGHT - 0.13, 0, 3.0), (0.30, 14.0, 6.0), timber, 0.05)
cube("Front wall left pier", (-11.0, FRONT + 0.12, 3.0), (4.0, 0.32, 6.0), timber, 0.05)
cube("Front wall right pier", (-1.0, FRONT + 0.12, 3.0), (4.0, 0.32, 6.0), timber, 0.05)
cube("Front door head", (-6.0, FRONT + 0.12, 5.55), (6.1, 0.34, 0.90), steel, 0.05)

# Stone plinth courses visually connect the newer store to the old farmyard.
for side_x in (HALL_LEFT - 0.03, HALL_RIGHT + 0.03):
    for row in range(2):
        for index in range(12):
            y = -6.35 + index * 1.12
            cube("Hall plinth stone", (side_x, y, 0.34 + row * 0.48), (0.28, 0.96, 0.40), stone, 0.025)
for row in range(2):
    for index in range(16):
        x = -12.55 + index * 0.82 + (0.20 if row else 0)
        if -9.0 < x < -3.0:
            continue
        cube("Front plinth stone", (x, FRONT - 0.06, 0.34 + row * 0.48), (0.72, 0.28, 0.40), stone, 0.025)

# Friendly slate gable roof, deliberately distinct from the mint machinery shed.
pitch = math.atan2(RIDGE - EAVE, 7.0)
slope = math.sqrt(7.0 ** 2 + (RIDGE - EAVE) ** 2)
for side in (-1, 1):
    y = side * 3.52
    z = (RIDGE + EAVE) * 0.5
    cube("Hall slate roof", (-6.0, y, z), (14.7, slope + 0.45, 0.20), slate, 0.045, (-side * pitch, 0, 0))
    for index in range(9):
        x = -12.35 + index * 1.59
        cube("Roof seam", (x, y - side * 0.035, z + 0.105), (0.045, slope + 0.14, 0.04), steel, 0.01, (-side * pitch, 0, 0))
cube("Hall ridge cap", (-6.0, 0, RIDGE + 0.08), (14.7, 0.40, 0.25), steel, 0.055)

# Open roller door and visible grain state make the building's purpose legible.
cube("Raised roller door", (-6.0, FRONT - 0.18, 5.30), (6.2, 0.18, 0.62), sage, 0.04)
for x in (-8.82, -3.18):
    cube("Roller door guide", (x, FRONT - 0.22, 3.05), (0.18, 0.18, 5.10), steel, 0.025)
for index in range(7):
    cylinder("Stored grain mound", (-8.2 + index * 0.72, 2.1 + 0.20 * (index % 2), 0.65), 1.55 - abs(index - 3) * 0.12, 1.20 + 0.18 * (index % 3), grain, vertices=18, edge=0.10)
cube("Low grain retaining wall", (-6.0, -0.25, 0.72), (11.0, 0.34, 1.35), cream, 0.08)

# Right: a straight-through intake canopy with generous vehicle clearance.
LANE_CENTER = 6.0
for x in (1.55, 10.45):
    for y in (-6.6, 6.6):
        cube("Intake canopy post", (x, y, 3.25), (0.48, 0.48, 6.50), steel, 0.075)
        cube("Canopy post foot", (x, y, 0.17), (0.82, 0.82, 0.25), cream, 0.08)
for y in (-6.6, 6.6):
    beam("Intake roof beam", (1.55, y, 6.45), (10.45, y, 6.45), 0.34, steel)
for x in (1.55, 10.45):
    beam("Intake side beam", (x, -6.6, 6.45), (x, 6.6, 6.45), 0.30, steel)
cube("Intake canopy roof", (LANE_CENTER, 0, 6.62), (9.6, 14.4, 0.24), sage, 0.08)
for index in range(12):
    cube("Canopy roof rib", (1.9 + index * 0.75, 0, 6.77), (0.07, 14.1, 0.08), cream, 0.015)

# The unloading pit is oversized and colour-framed so it remains readable on TV.
cube("Intake pit shadow", (LANE_CENTER, -1.0, 0.01), (5.0, 7.2, 0.18), dark, 0.14)
for index in range(15):
    cube("Intake grate bar", (3.75 + index * 0.32, -1.0, 0.14), (0.18, 6.55, 0.16), grate, 0.028)
for x in (3.42, 8.58):
    cube("Intake safety frame", (x, -1.0, 0.23), (0.22, 7.25, 0.20), ochre, 0.025)
for y in (-4.62, 2.62):
    cube("Intake safety frame", (LANE_CENTER, y, 0.23), (5.35, 0.22, 0.20), ochre, 0.025)

# Auger and transfer pipe explain where tipped grain goes.
cylinder("Intake auger tower", (1.15, 1.8, 3.95), 0.48, 7.50, sage, vertices=18, edge=0.06)
cylinder("Intake auger cap", (1.15, 1.8, 7.78), 0.68, 0.24, cream, vertices=18, edge=0.06)
beam("Overhead grain pipe", (1.15, 1.8, 7.55), (-4.2, 1.8, 8.15), 0.46, sage)
cylinder("Hall drop pipe", (-4.2, 1.8, 6.65), 0.26, 3.10, sage, vertices=16, edge=0.045)
for z in (1.1, 2.45, 3.8, 5.15, 6.5):
    cube("Auger ladder rung", (0.60, 1.8, z), (0.62, 0.12, 0.10), cream, 0.02)
for x in (0.32, 0.88):
    cube("Auger ladder rail", (x, 1.8, 3.85), (0.10, 0.12, 6.30), cream, 0.02)

# A bold sign and three fill lights give instant state feedback during quests.
cube("Intake sign panel", (LANE_CENTER, -6.88, 5.30), (5.4, 0.24, 1.25), cream, 0.09)
for x in (4.55, 6.0, 7.45):
    cylinder("Friendly grain emblem", (x, -7.04, 5.30), 0.30, 0.12, grain, (math.pi / 2, 0, 0), 14, 0.04)
for index, mat in enumerate((blue, ochre, red)):
    cylinder("Store fill indicator", (-1.3 + index * 0.72, -7.13, 4.55), 0.23, 0.12, mat, (math.pi / 2, 0, 0), 16, 0.035)
    cube("Indicator hood", (-1.3 + index * 0.72, -7.03, 4.88), (0.52, 0.40, 0.16), steel, 0.035)
for x in (2.2, 9.8):
    cube("Golden intake lamp", (x, -6.86, 5.85), (0.52, 0.28, 0.34), lamp, 0.08)

# Small chunky props keep the industrial building warm and family friendly.
for x, mat in ((-11.7, red), (-10.8, blue), (-9.9, ochre)):
    cylinder("Colourful grain drum", (x, -5.75, 0.66), 0.36, 1.16, mat, vertices=18, edge=0.06)
for index in range(3):
    cube("Stacked grain sack", (-2.15 + 0.48 * index, 5.65, 0.38), (0.85, 1.25, 0.52), cream, 0.16, (0, 0, (-0.08 + index * 0.07)))

join_material_groups(root)

bpy.ops.object.select_all(action="DESELECT")
root.select_set(True)
for obj in root.children_recursive:
    obj.select_set(True)
bpy.context.view_layer.objects.active = root
bpy.ops.export_scene.gltf(filepath=str(GLB), export_format="GLB", use_selection=True, export_apply=True, export_yup=True)

# Review render with the real tractor and a neutral trailer-size reference.
bpy.ops.mesh.primitive_plane_add(size=55, location=(0, 0, -0.08))
bpy.context.object.data.materials.append(flat("Review meadow", (0.34, 0.51, 0.20), 0.98))
if TRACTOR.exists():
    before = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=str(TRACTOR))
    imported = [obj for obj in bpy.data.objects if obj not in before]
    for imported_root in [obj for obj in imported if obj.parent is None]:
        imported_root.location = (LANE_CENTER, -5.4, 0.16)
        imported_root.rotation_euler[2] = math.radians(180)
preview = bpy.data.objects.new("TrailerSizeReference", None)
bpy.context.collection.objects.link(preview)
cube("Trailer reference bed", (LANE_CENTER, -10.3, 1.45), (3.0, 6.5, 2.1), sage, 0.12, target=preview)
for x in (4.6, 7.4):
    for y in (-8.7, -11.9):
        cylinder("Trailer reference wheel", (x, y, 0.65), 0.62, 0.34, dark, (0, math.pi / 2, 0), 18, 0.05, preview)

bpy.ops.object.light_add(type="AREA", location=(-12, -15, 20))
bpy.context.object.data.energy = 3200
bpy.context.object.data.size = 11
bpy.ops.object.light_add(type="AREA", location=(14, -2, 11))
bpy.context.object.data.energy = 1400
bpy.context.object.data.size = 9
bpy.ops.object.camera_add(location=(29, -35, 24))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 2.8)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 36.0
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1400
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(PREVIEW)
scene.world = bpy.data.worlds.new("Grain store preview world")
scene.world.color = (0.18, 0.30, 0.34)
scene.view_settings.look = "AgX - Medium High Contrast"
bpy.ops.render.render(write_still=True)
print("WROTE", GLB)
print("WROTE", PREVIEW)
