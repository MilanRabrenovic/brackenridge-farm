import bpy
import math
import os
import random

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
ASSET_DIR = os.path.join(ROOT, "game/assets/environment")
os.makedirs(ASSET_DIR, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)


def mat(name, color, rough=0.85, metallic=0.0):
    value = bpy.data.materials.get(name) or bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = rough
    shader.inputs["Metallic"].default_value = metallic
    return value


bark = mat("Old Oak Bark", (0.095, 0.045, 0.018), 0.98)
bark_light = mat("Sunlit Oak Bark", (0.18, 0.085, 0.025), 0.96)
leaves = [
    mat("Oak Deep Leaf", (0.045, 0.16, 0.04), 0.91),
    mat("Oak Mid Leaf", (0.085, 0.27, 0.065), 0.89),
    mat("Oak Sun Leaf", (0.19, 0.40, 0.09), 0.87),
]
hedge_leaves = [
    mat("Hawthorn Deep", (0.035, 0.13, 0.035), 0.94),
    mat("Hawthorn Mid", (0.075, 0.25, 0.055), 0.92),
    mat("Hawthorn Tip", (0.18, 0.38, 0.08), 0.90),
]
stone = [
    mat("Wall Stone Shade", (0.16, 0.115, 0.065), 0.98),
    mat("Wall Stone Honey", (0.29, 0.19, 0.085), 0.96),
    mat("Wall Stone Pale", (0.42, 0.31, 0.16), 0.95),
]
moss = mat("Wall Moss", (0.10, 0.21, 0.055), 0.98)
flower_white = mat("Hawthorn Blossom", (0.80, 0.76, 0.60), 0.88)
flower_yellow = mat("Buttercup", (0.90, 0.55, 0.035), 0.86)


def clear_objects():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)


def parent(obj, root):
    obj.parent = root
    return obj


def bevel(obj, width=0.035, segments=2):
    if width <= 0:
        return obj
    modifier = obj.modifiers.new("Natural softened edge", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)
    return obj


def cube(name, loc, size, material, root, edge=0.035, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, root)


def cylinder(name, loc, radius, depth, material, root, rot=(0, 0, 0), vertices=12, edge=0.025):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, root)


def cluster(name, loc, scale, material, root, subdivisions=1):
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=subdivisions, radius=1, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, 0.035, 1)
    obj.data.materials.append(material)
    return parent(obj, root)


def join_by_material(root):
    groups = {}
    for obj in list(root.children_recursive):
        if obj.type == "MESH" and obj.data.materials:
            groups.setdefault(obj.data.materials[0].name, []).append(obj)
    for name, objects in groups.items():
        if len(objects) < 2:
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        active = objects[0]
        bpy.context.view_layer.objects.active = active
        bpy.ops.object.join()
        active.name = "Batched_" + name.replace(" ", "_")
        world = active.matrix_world.copy()
        active.parent = root
        active.matrix_world = world


def export_root(root, filename):
    join_by_material(root)
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for obj in root.children_recursive:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=os.path.join(ASSET_DIR, filename),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )


def make_oak():
    random.seed(715)
    root = bpy.data.objects.new("BrackenEnglishOak", None)
    bpy.context.collection.objects.link(root)
    cylinder("MainTrunk", (0, 0, 2.2), 0.58, 4.4, bark, root, vertices=14, edge=0.07)
    cylinder("TrunkHighlight", (-0.18, -0.47, 2.15), 0.13, 3.4, bark_light, root, vertices=10, edge=0.025)
    branches = [
        ((-0.85, 0.05, 3.85), 0.25, 2.5, (0, math.radians(-48), 0)),
        ((0.95, 0.10, 4.05), 0.27, 2.8, (0, math.radians(52), 0)),
        ((0.05, 0.85, 4.25), 0.22, 2.2, (math.radians(52), 0, 0)),
        ((-0.10, -0.75, 4.15), 0.20, 2.1, (math.radians(-54), 0, 0)),
    ]
    for i, (loc, radius, depth, rotation) in enumerate(branches):
        cylinder("OakBranch", loc, radius, depth, bark if i % 2 else bark_light, root, rotation, 12, 0.04)
    canopy = [
        (-1.8, 0.0, 5.5, 2.15, 1.75, 1.55), (0.2, -0.4, 6.05, 2.35, 1.85, 1.70),
        (2.0, 0.15, 5.55, 2.10, 1.72, 1.48), (-0.3, 1.45, 5.45, 2.25, 1.60, 1.45),
        (-0.2, -1.55, 5.25, 1.95, 1.50, 1.35), (-1.35, 1.1, 6.2, 1.65, 1.45, 1.35),
        (1.25, 1.0, 6.25, 1.75, 1.52, 1.30), (0.0, 0.1, 7.05, 1.75, 1.45, 1.25),
    ]
    for i, (x, y, z, sx, sy, sz) in enumerate(canopy):
        cluster("OakCrown", (x, y, z), (sx, sy, sz), leaves[i % 3], root, 2)
    # Buttress roots and a few low ferns make the trunk meet the ground naturally.
    for i in range(7):
        angle = i * math.tau / 7
        cube("OakRoot", (math.cos(angle) * 0.55, math.sin(angle) * 0.55, 0.19), (0.26, 1.15, 0.25), bark, root, 0.04, (0, 0, angle))
    for i in range(12):
        angle = i * math.tau / 12
        cluster("Fern", (math.cos(angle) * 1.12, math.sin(angle) * 0.92, 0.18), (0.28, 0.18, 0.16), hedge_leaves[1 + i % 2], root)
    return root


def make_hedge():
    random.seed(918)
    root = bpy.data.objects.new("BrackenHawthornHedge", None)
    bpy.context.collection.objects.link(root)
    for i in range(12):
        x = -2.25 + i * 0.41
        cylinder("HedgeStem", (x, 0, 0.65), 0.055, 1.38, bark, root, (random.uniform(-0.18, 0.18), random.uniform(-0.18, 0.18), 0), 8, 0.012)
    for i in range(18):
        x = -2.25 + i * 0.27 + random.uniform(-0.12, 0.12)
        y = random.uniform(-0.38, 0.38)
        z = random.uniform(0.62, 1.43)
        cluster("HawthornLeafMass", (x, y, z), (random.uniform(0.42, 0.70), random.uniform(0.38, 0.58), random.uniform(0.42, 0.65)), hedge_leaves[i % 3], root)
    for i in range(14):
        x = random.uniform(-2.15, 2.15)
        y = random.choice([-0.47, 0.47])
        z = random.uniform(0.65, 1.48)
        cluster("HawthornBlossom", (x, y, z), (0.075, 0.05, 0.075), flower_white, root)
    return root


def make_wall():
    random.seed(1119)
    root = bpy.data.objects.new("BrackenDryStoneWall", None)
    bpy.context.collection.objects.link(root)
    z = 0.16
    row = 0
    while z < 1.05:
        height = random.uniform(0.22, 0.30)
        x = -2.25 + (0.16 if row % 2 else 0.0)
        while x < 2.25:
            width = random.uniform(0.42, 0.74)
            center = x + width / 2
            cube("WallStone", (center, random.uniform(-0.025, 0.025), z), (width - 0.025, random.uniform(0.52, 0.68), height - 0.025), stone[random.randrange(3)], root, 0.045, (0, 0, random.uniform(-0.025, 0.025)))
            x += width
        z += height
        row += 1
    x = -2.05
    while x < 2.2:
        width = random.uniform(0.52, 0.82)
        cube("WallCap", (x + width / 2, 0, 1.15), (width - 0.035, 0.78, 0.22), stone[1 + random.randrange(2)], root, 0.055, (random.uniform(-0.03, 0.03), 0, random.uniform(-0.02, 0.02)))
        x += width
    for i in range(7):
        cluster("WallMoss", (random.uniform(-2.0, 2.0), random.choice([-0.34, 0.34]), random.uniform(0.65, 1.18)), (0.14, 0.09, 0.07), moss, root)
    return root


clear_objects()
oak_root = make_oak()
export_root(oak_root, "english_oak.glb")
clear_objects()
hedge_root = make_hedge()
export_root(hedge_root, "hawthorn_hedge.glb")
clear_objects()
wall_root = make_wall()
export_root(wall_root, "dry_stone_wall.glb")

print("WROTE", os.path.join(ASSET_DIR, "english_oak.glb"))
print("WROTE", os.path.join(ASSET_DIR, "hawthorn_hedge.glb"))
print("WROTE", os.path.join(ASSET_DIR, "dry_stone_wall.glb"))
