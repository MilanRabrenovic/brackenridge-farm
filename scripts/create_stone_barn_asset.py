import bpy
import math
import os
import random
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GLB = os.path.join(ROOT, "game/assets/buildings/bracken_stone_barn.glb")
PREVIEW = os.path.join(ROOT, "docs/previews/bracken-stone-barn.png")
random.seed(4127)

bpy.ops.wm.read_factory_settings(use_empty=True)
os.makedirs(os.path.dirname(GLB), exist_ok=True)
os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)


def material(name, color, roughness=0.72, metallic=0.0, emission=None):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1)
        shader.inputs["Emission Strength"].default_value = 2.0
    return value


limestone = [
    material("Cotswold Limestone Honey", (0.29, 0.16, 0.065), 0.92),
    material("Cotswold Limestone Gold", (0.40, 0.24, 0.09), 0.90),
    material("Cotswold Limestone Pale", (0.48, 0.34, 0.15), 0.88),
    material("Cotswold Limestone Shade", (0.20, 0.12, 0.06), 0.94),
]
mortar = material("Warm Lime Mortar", (0.24, 0.20, 0.14), 0.97)
slate = material("Weathered Blue Grey Slate", (0.035, 0.055, 0.065), 0.89)
slate_light = material("Sunlit Slate", (0.075, 0.105, 0.115), 0.86)
slate_edge = material("Slate Course Shadow", (0.018, 0.026, 0.03), 0.93)
oak = material("Aged English Oak", (0.22, 0.105, 0.035), 0.91)
oak_light = material("Worn Oak Edge", (0.38, 0.20, 0.075), 0.88)
iron = material("Black Forged Iron", (0.025, 0.031, 0.030), 0.63, 0.42)
glass = material("Dusty Barn Glass", (0.12, 0.28, 0.30), 0.28, 0.04)
interior = material("Deep Barn Interior", (0.035, 0.026, 0.018), 0.98)
hay = material("Dry Straw", (0.70, 0.43, 0.10), 0.94)
hay_light = material("Sunlit Straw", (0.88, 0.64, 0.20), 0.90)
moss = material("Roof Moss", (0.19, 0.29, 0.10), 0.96)
leaf = material("Ivy Leaf", (0.12, 0.31, 0.105), 0.90)
leaf_light = material("Ivy Tip", (0.27, 0.48, 0.14), 0.88)
lamp = material("Warm Barn Lamp", (0.75, 0.43, 0.12), 0.35, emission=(1.0, 0.45, 0.12))

root = bpy.data.objects.new("BrackenStoneBarn", None)
bpy.context.collection.objects.link(root)


def parent(obj, target=root):
    obj.parent = target
    return obj


def bevel(obj, width=0.04, segments=2):
    if width <= 0:
        return obj
    mod = obj.modifiers.new("Soft hand-built edge", "BEVEL")
    mod.width = width
    mod.segments = segments
    mod.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=mod.name)
    obj.select_set(False)
    return obj


def cube(name, loc, size, mat, edge=0.035, rot=(0, 0, 0), target=root):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge, 2)
    obj.data.materials.append(mat)
    return parent(obj, target)


def cylinder(name, loc, radius, depth, mat, rot=(0, 0, 0), vertices=16, edge=0.02, target=root):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge, 2)
    obj.data.materials.append(mat)
    return parent(obj, target)


def gable(name, x, mat):
    # Triangular masonry end, ridge aligned along X.
    vertices = [(x, -4.0, 4.0), (x, 4.0, 4.0), (x, 0.0, 6.25)]
    thickness = 0.34
    verts = [(vx + side * thickness / 2, vy, vz) for side in (-1, 1) for vx, vy, vz in vertices]
    faces = [(0, 1, 2), (5, 4, 3), (0, 3, 4, 1), (1, 4, 5, 2), (2, 5, 3, 0)]
    mesh = bpy.data.meshes.new(name + "Mesh")
    mesh.from_pydata(verts, [], faces)
    mesh.materials.append(mat)
    obj = bpy.data.objects.new(name, mesh)
    bpy.context.collection.objects.link(obj)
    parent(obj)
    bevel(obj, 0.025, 2)
    return obj


def stone_courses_front():
    # The visible facade is actual relief geometry, merged into four material batches.
    collections = [[] for _ in limestone]
    y = -4.17
    z = 0.25
    course = 0
    while z < 4.05:
        height = random.uniform(0.34, 0.48)
        x = -6.85 + (0.20 if course % 2 else 0.0)
        while x < 6.85:
            width = random.uniform(0.46, 0.92)
            center = x + width / 2
            doorway = abs(center) < 2.23 and z < 3.52
            left_window = -5.25 < center < -3.75 and 1.25 < z < 2.65
            right_window = 3.75 < center < 5.25 and 1.25 < z < 2.65
            if not doorway and not left_window and not right_window:
                depth = random.uniform(0.10, 0.17)
                obj = cube("FacadeStone", (center, y - depth / 2, z), (width - 0.045, depth, height - 0.055), limestone[random.randrange(4)], 0.025)
                obj.rotation_euler[1] = random.uniform(-0.012, 0.012)
            x += width
        z += height
        course += 1


def side_stones(x_side):
    z = 0.28
    course = 0
    while z < 4.02:
        height = random.uniform(0.36, 0.50)
        y = -3.80 + (0.17 if course % 2 else 0.0)
        while y < 3.80:
            length = random.uniform(0.55, 1.05)
            center = y + length / 2
            depth = random.uniform(0.10, 0.16)
            # The structural wall reaches x +/-7.18, so the relief must sit beyond it.
            face_x = x_side + math.copysign(0.20 + depth / 2, x_side)
            obj = cube("GableStone", (face_x, center, z), (depth, length - 0.05, height - 0.06), limestone[random.randrange(4)], 0.025)
            obj.rotation_euler[1] = random.uniform(-0.012, 0.012)
            y += length
        z += height
        course += 1


def framed_window(x, y, z, rot_z=0):
    holder = bpy.data.objects.new("MullionedWindow", None)
    holder.location = (x, y, z)
    holder.rotation_euler[2] = rot_z
    bpy.context.collection.objects.link(holder)
    parent(holder)
    cube("WindowRecess", (0, 0, 0), (1.46, 0.14, 1.46), interior, 0.03, target=holder)
    cube("WindowGlass", (0, -0.085, 0), (1.20, 0.035, 1.19), glass, 0.012, target=holder)
    for xx in (-0.68, 0.68):
        cube("StoneJamb", (xx, -0.12, 0), (0.20, 0.24, 1.62), limestone[2], 0.028, target=holder)
    cube("StoneLintel", (0, -0.12, 0.80), (1.58, 0.24, 0.20), limestone[2], 0.028, target=holder)
    cube("StoneSill", (0, -0.13, -0.80), (1.66, 0.28, 0.19), limestone[1], 0.028, target=holder)
    cube("WindowMullion", (0, -0.125, 0), (0.07, 0.07, 1.20), oak, 0.012, target=holder)
    cube("WindowMullion", (0, -0.128, 0), (1.20, 0.07, 0.07), oak, 0.012, target=holder)


def timber_door(name, x, angle):
    pivot = bpy.data.objects.new(name + "Pivot", None)
    pivot.location = (x, -4.24, 1.73)
    pivot.rotation_euler[2] = math.radians(angle)
    bpy.context.collection.objects.link(pivot)
    parent(pivot)
    direction = 1 if x < 0 else -1
    cube(name, (direction * 1.08, 0, 0), (2.10, 0.15, 3.38), oak, 0.035, target=pivot)
    for local_x in (-1.72, -1.15, -0.58, 0.0, 0.58, 1.15, 1.72):
        cube("DoorPlankGap", (direction * 1.08 + local_x * 0.50, -0.086, 0), (0.026, 0.018, 3.22), iron, 0.004, target=pivot)
    cube("DoorBrace", (direction * 1.08, -0.105, 0), (2.02, 0.08, 0.14), oak_light, 0.018, (0, math.radians(direction * 34), 0), pivot)
    for local_z in (-1.22, 1.22):
        cube("IronStrap", (direction * 1.08, -0.135, local_z), (1.88, 0.045, 0.09), iron, 0.012, target=pivot)
    for local_z in (-1.22, 1.22):
        cylinder("IronBolt", (direction * 0.26, -0.17, local_z), 0.055, 0.045, iron, (math.pi / 2, 0, 0), 12, 0.008, pivot)


# Core shell, deliberately sized to replace the 17 x 10 metre greybox barn.
cube("BarnInterior", (0, 0, 2.0), (13.8, 7.8, 4.0), interior, 0.06)
cube("BackWall", (0, 4.0, 2.0), (14.0, 0.36, 4.0), mortar, 0.04)
cube("LeftWall", (-7.0, 0, 2.0), (0.36, 8.0, 4.0), mortar, 0.04)
cube("RightWall", (7.0, 0, 2.0), (0.36, 8.0, 4.0), mortar, 0.04)
cube("FrontLeftWall", (-4.63, -4.0, 2.0), (4.74, 0.36, 4.0), mortar, 0.04)
cube("FrontRightWall", (4.63, -4.0, 2.0), (4.74, 0.36, 4.0), mortar, 0.04)
cube("FrontLintelWall", (0, -4.0, 3.76), (4.55, 0.36, 0.48), mortar, 0.04)
gable("LeftGable", -7.0, mortar)
gable("RightGable", 7.0, mortar)
stone_courses_front()
side_stones(-7.0)
side_stones(7.0)

# Dressed stone makes the functional opening read clearly from the game camera.
for x in (-2.38, 2.38):
    for z in (0.32, 0.94, 1.56, 2.18, 2.80, 3.42):
        cube("DoorQuoin", (x, -4.25, z), (0.43, 0.30, 0.54), limestone[2 if int(z * 10) % 2 else 1], 0.035)
cube("DoorLintel", (0, -4.28, 3.62), (5.08, 0.38, 0.38), limestone[2], 0.045)
cube("Threshold", (0, -4.38, 0.09), (4.74, 0.78, 0.18), limestone[1], 0.04)
framed_window(-4.55, -4.28, 2.02)
framed_window(4.55, -4.28, 2.02)
timber_door("LeftBarnDoor", -2.26, -63)
timber_door("RightBarnDoor", 2.26, 63)

# Timber frame remains visible through the open entrance.
for x in (-2.05, 2.05):
    cube("InteriorPost", (x, -3.72, 2.08), (0.20, 0.22, 4.15), oak, 0.025)
cube("InteriorBeam", (0, -3.70, 3.72), (4.22, 0.24, 0.22), oak, 0.025)
for x in (-1.88, 1.88):
    cube("RoofBrace", (x, -3.68, 3.40), (0.18, 0.20, 1.15), oak, 0.025, (0, math.radians(x * 9), 0))

# Layered slate roof with irregular highlights and proper eaves.
pitch = math.radians(29)
slope = 4.55
for side in (-1, 1):
    y = side * math.cos(pitch) * slope / 2
    z = 4.0 + math.sin(pitch) * slope / 2
    panel = cube("SlateRoof", (0, y, z), (14.75, slope, 0.20), slate, 0.045, (-side * pitch, 0, 0))
    for row in range(9):
        distance_from_ridge = 0.38 + row * 0.43
        yy = side * distance_from_ridge
        zz = 6.18 - distance_from_ridge * math.tan(pitch) + 0.07
        strip = cube("SlateCourse", (0, yy, zz), (14.86, 0.52, 0.075), slate_light if row % 3 == 0 else slate_edge, 0.014, (-side * pitch, 0, 0))
        strip.location.x += random.uniform(-0.025, 0.025)
cube("StoneRidge", (0, 0, 6.22), (14.88, 0.38, 0.30), slate_light, 0.07)
for x in range(-6, 7):
    cylinder("RidgeCap", (x + 0.5, 0, 6.30), 0.22, 0.96, slate_light, (0, math.pi / 2, 0), 12, 0.025)

# Chimney, rainwater goods and exterior lamp.
cube("Chimney", (4.72, 0.82, 6.13), (0.72, 0.74, 1.55), limestone[1], 0.045)
cube("ChimneyCap", (4.72, 0.82, 6.92), (0.92, 0.93, 0.16), limestone[2], 0.035)
for y in (-4.18, 4.18):
    cylinder("RainGutter", (0, y, 3.91), 0.09, 14.55, iron, (0, math.pi / 2, 0), 12, 0.012)
for x in (-6.72, 6.72):
    cylinder("Downpipe", (x, -4.19, 1.98), 0.08, 3.85, iron, vertices=12, edge=0.012)
cube("LampBracket", (0, -4.47, 3.98), (0.10, 0.28, 0.24), iron, 0.018)
cylinder("BarnLamp", (0, -4.64, 3.87), 0.17, 0.24, lamp, (math.pi / 2, 0, 0), 16, 0.025)

# Readable storytelling props at the entrance.
for i, (x, y, z) in enumerate([(-1.40, -3.15, 0.34), (-0.55, -3.05, 0.34), (-0.98, -3.15, 1.02)]):
    cube("HayBale", (x, y, z), (0.76, 0.98, 0.64), hay_light if i == 2 else hay, 0.08)
    for band in (-0.22, 0.22):
        cube("BaleTwine", (x + band, y - 0.50, z), (0.025, 0.02, 0.57), oak, 0.003)
for x in (3.25, 3.82):
    cylinder("OakBarrel", (x, -4.55, 0.46), 0.34, 0.86, oak, vertices=16, edge=0.035)
    for z in (0.18, 0.72):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.34, minor_radius=0.025, major_segments=16, minor_segments=6, location=(x, -4.55, z), rotation=(0, 0, 0))
        hoop = bpy.context.object
        hoop.name = "BarrelHoop"
        hoop.data.materials.append(iron)
        parent(hoop)

# A controlled amount of ivy softens the geometry and ties it into the countryside.
for i in range(34):
    x = -6.94 + random.uniform(-0.04, 0.06)
    y = -3.95 + random.uniform(0.0, 2.0)
    z = 0.25 + i * 0.095 + random.uniform(-0.08, 0.08)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=random.uniform(0.10, 0.19), location=(x, y, z))
    ivy = bpy.context.object
    ivy.name = "IvyLeafCluster"
    ivy.scale = (0.45, 1.0, 0.72)
    ivy.data.materials.append(leaf_light if i % 5 == 0 else leaf)
    parent(ivy)
for x in (-5.8, -4.6, 5.5):
    cube("RoofMoss", (x, -3.83, 4.10), (1.05, 0.28, 0.10), moss, 0.04, (pitch, 0, 0))


def join_static_meshes_by_material():
    """Collapse hundreds of masonry pieces into a small Fire TV draw-call budget."""
    animated_roots = {obj for obj in root.children if obj.name.endswith("BarnDoorPivot")}
    animated = set(animated_roots)
    for animated_root in animated_roots:
        animated.update(animated_root.children_recursive)
    groups = {}
    for obj in list(root.children_recursive):
        if obj.type != "MESH" or obj in animated or not obj.data.materials:
            continue
        key = obj.data.materials[0].name
        groups.setdefault(key, []).append(obj)
    for key, objects in groups.items():
        if len(objects) < 2:
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        active = objects[0]
        bpy.context.view_layer.objects.active = active
        bpy.ops.object.join()
        active.name = "Static_" + key.replace(" ", "_")
        world_matrix = active.matrix_world.copy()
        active.parent = root
        active.matrix_world = world_matrix


join_static_meshes_by_material()

# Export only the authored asset hierarchy.
bpy.ops.object.select_all(action="DESELECT")
root.select_set(True)
for obj in root.children_recursive:
    obj.select_set(True)
bpy.context.view_layer.objects.active = root
bpy.ops.export_scene.gltf(filepath=GLB, export_format="GLB", use_selection=True, export_apply=True, export_yup=True)

# Preview stage is excluded from the GLB.
bpy.ops.mesh.primitive_plane_add(size=38, location=(0, 0, -0.03))
ground = bpy.context.object
ground.data.materials.append(material("Preview Yard", (0.38, 0.42, 0.26), 0.98))
bpy.ops.object.light_add(type="AREA", location=(-8, -10, 13))
key = bpy.context.object
key.data.energy = 1450
key.data.shape = "DISK"
key.data.size = 8
bpy.ops.object.light_add(type="AREA", location=(9, -1, 7))
fill = bpy.context.object
fill.data.energy = 520
fill.data.size = 7
bpy.ops.object.camera_add(location=(15.8, -19.5, 12.8))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0, 2.7)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 17.5
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1200
scene.render.resolution_y = 820
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = PREVIEW
scene.world = bpy.data.worlds.new("Barn Preview World")
scene.world.color = (0.07, 0.10, 0.09)
scene.view_settings.look = "AgX - Medium High Contrast"
bpy.ops.render.render(write_still=True)
print("WROTE", GLB)
print("WROTE", PREVIEW)
