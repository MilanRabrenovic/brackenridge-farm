"""Create the first two original Brackenridge Farm player characters.

The GLBs keep named limb pivots so Godot can animate them cheaply at runtime.
They are deliberately chunky and readable from a television gameplay camera.
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "game" / "assets" / "characters"
PREVIEW = ROOT / "docs" / "previews" / "bracken-player-characters.png"
ASSETS.mkdir(parents=True, exist_ok=True)
PREVIEW.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.read_factory_settings(use_empty=True)


def material(name, color, roughness=0.92, metallic=0.0, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1.0)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1.0)
        shader.inputs["Emission Strength"].default_value = 1.2
    return mat


SKIN = material("Farmhand warm painted skin", (0.72, 0.43, 0.27))
SKIN_LIGHT = material("Farmhand highlight skin", (0.90, 0.63, 0.40))
CHEEK = material("Farmhand rosy cheek", (0.82, 0.31, 0.24))
CREAM = material("Farmhand warm cream", (0.92, 0.79, 0.53))
DARK = material("Farmhand deep forest", (0.045, 0.12, 0.075))
BROWN = material("Farmhand painted leather", (0.25, 0.105, 0.055))
RUST = material("Grower rust jacket", (0.67, 0.16, 0.095))
RUST_LIGHT = material("Grower jacket highlight", (0.88, 0.30, 0.14))
GREEN = material("Grower field green", (0.18, 0.34, 0.14))
DENIM = material("Mechanic blue denim", (0.075, 0.29, 0.49))
DENIM_LIGHT = material("Mechanic denim highlight", (0.13, 0.48, 0.68))
OCHRE = material("Mechanic sunny ochre", (0.94, 0.52, 0.075))
STEEL = material("Mechanic tool steel", (0.23, 0.32, 0.34), 0.72, 0.16)
EYE = material("Farmhand eye", (0.035, 0.055, 0.045), 0.86)
MARKER_RED = material("Grower identity glow", (0.95, 0.30, 0.12), 0.35, emission=(0.95, 0.18, 0.06))
MARKER_BLUE = material("Mechanic identity glow", (0.12, 0.53, 0.82), 0.35, emission=(0.06, 0.35, 0.75))


def parent(obj, owner):
    obj.parent = owner
    return obj


def empty(owner, name, location):
    obj = bpy.data.objects.new(name, None)
    obj.empty_display_type = "PLAIN_AXES"
    obj.location = location
    bpy.context.collection.objects.link(obj)
    return parent(obj, owner)


def bevel(obj, width=0.035, segments=2):
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


def cube(owner, name, loc, size, mat, edge=0.035, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(mat)
    return parent(obj, owner)


def sphere(owner, name, loc, scale, mat, segments=24, rings=16):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=loc)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(mat)
    return parent(obj, owner)


def cylinder(owner, name, loc, radius, depth, mat, vertices=20, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, min(0.035, radius * 0.18), 2)
    obj.data.materials.append(mat)
    return parent(obj, owner)


def cone(owner, name, loc, radius1, radius2, depth, mat, vertices=20, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cone_add(vertices=vertices, radius1=radius1, radius2=radius2, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, 0.025, 2)
    obj.data.materials.append(mat)
    return parent(obj, owner)


def torus(owner, name, loc, major, minor, mat, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_torus_add(major_radius=major, minor_radius=minor, major_segments=24, minor_segments=8, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.data.materials.append(mat)
    return parent(obj, owner)


def add_face(head, hair_mat, style):
    # Faces look toward -Y in Blender; glTF/Godot preserves this as the model front.
    for x in (-0.115, 0.115):
        sphere(head, "Eye", (x, -0.278, 0.105), (0.045, 0.025, 0.06), EYE, 16, 10)
        sphere(head, "Cheek", (x * 1.45, -0.269, -0.02), (0.055, 0.018, 0.035), CHEEK, 16, 10)
    sphere(head, "Nose", (0, -0.315, 0.025), (0.06, 0.07, 0.065), SKIN_LIGHT, 16, 10)
    if style == "cap":
        sphere(head, "Hair", (0, 0.02, 0.15), (0.31, 0.25, 0.28), hair_mat, 20, 12)
        cylinder(head, "Flat cap crown", (0, -0.01, 0.31), 0.32, 0.13, GREEN, 24)
        cube(head, "Flat cap peak", (0, -0.30, 0.29), (0.43, 0.30, 0.075), GREEN, 0.04)
    else:
        sphere(head, "Hair", (0, 0.02, 0.12), (0.31, 0.26, 0.29), hair_mat, 20, 12)
        cylinder(head, "Ochre beanie", (0, -0.005, 0.30), 0.31, 0.23, OCHRE, 24)
        sphere(head, "Beanie pom", (0, 0, 0.46), (0.105, 0.105, 0.105), OCHRE, 16, 10)


def add_limb(root, side, kind, cloth, boot=False):
    x = side * (0.25 if kind == "leg" else 0.50)
    z = 0.83 if kind == "leg" else 1.47
    pivot_name = ("Left" if side < 0 else "Right") + ("LegPivot" if kind == "leg" else "ArmPivot")
    pivot = empty(root, pivot_name, (x, 0, z))
    if kind == "leg":
        cone(pivot, "Trouser leg", (0, 0, -0.36), 0.15, 0.18, 0.66, cloth, 18)
        cube(pivot, "Boot", (0, -0.075, -0.72), (0.34, 0.46, 0.25), BROWN, 0.07)
    else:
        cone(pivot, "Sleeve", (0, 0, -0.29), 0.13, 0.17, 0.55, cloth, 18)
        sphere(pivot, "Hand", (0, -0.015, -0.61), (0.14, 0.13, 0.16), SKIN, 18, 12)
    return pivot


def add_identity_marker(root, mat, symbol):
    marker = empty(root, "IdentityMarker", (0, 0, 2.42))
    torus(marker, "Identity ring", (0, 0, 0), 0.19, 0.045, mat, (math.pi / 2, 0, 0))
    if symbol == "wheat":
        cube(marker, "Wheat stem", (0, -0.015, 0), (0.035, 0.045, 0.30), CREAM, 0.01)
        for side in (-1, 1):
            for z in (-0.09, 0.0, 0.09):
                sphere(marker, "Wheat grain", (side * 0.075, -0.025, z), (0.055, 0.025, 0.08), CREAM, 12, 8)
    else:
        cylinder(marker, "Gear centre", (0, -0.02, 0), 0.09, 0.045, CREAM, 12, (math.pi / 2, 0, 0))
        for angle in range(0, 360, 60):
            a = math.radians(angle)
            cube(marker, "Gear tooth", (math.cos(a) * 0.13, -0.025, math.sin(a) * 0.13), (0.07, 0.045, 0.10), CREAM, 0.015, (0, a, 0))


def make_grower():
    root = empty(None, "BrackenGrower", (0, 0, 0))
    # Soft jacket silhouette with a cream shirt, scarf and strong red identity.
    sphere(root, "Grower jacket", (0, 0, 1.23), (0.48, 0.34, 0.50), RUST, 24, 16)
    cube(root, "Grower jacket front", (0, -0.325, 1.22), (0.48, 0.08, 0.69), RUST_LIGHT, 0.035)
    for z in (1.02, 1.23, 1.44):
        sphere(root, "Jacket button", (0, -0.377, z), (0.035, 0.018, 0.035), CREAM, 12, 8)
    cube(root, "Grower neckerchief", (0, -0.36, 1.62), (0.34, 0.08, 0.16), CREAM, 0.035, (0, 0, math.radians(4)))
    cube(root, "Grower belt", (0, -0.02, 0.88), (0.83, 0.50, 0.14), BROWN, 0.045)
    add_limb(root, -1, "leg", GREEN)
    add_limb(root, 1, "leg", GREEN)
    add_limb(root, -1, "arm", RUST)
    add_limb(root, 1, "arm", RUST)
    head = empty(root, "HeadPivot", (0, 0, 1.84))
    sphere(head, "Head", (0, 0, 0.04), (0.31, 0.285, 0.34), SKIN, 24, 16)
    add_face(head, BROWN, "cap")
    add_identity_marker(root, MARKER_RED, "wheat")
    return root


def make_mechanic():
    root = empty(None, "BrackenMechanic", (0, 0, 0))
    # Rolled sleeves, blue overalls and tool belt make the silhouette different.
    sphere(root, "Mechanic shirt", (0, 0, 1.25), (0.45, 0.32, 0.48), CREAM, 24, 16)
    cube(root, "Mechanic overall bib", (0, -0.325, 1.23), (0.58, 0.08, 0.67), DENIM, 0.045)
    for x in (-0.22, 0.22):
        cube(root, "Overall strap", (x, -0.345, 1.52), (0.10, 0.07, 0.45), DENIM_LIGHT, 0.025, (0, 0, -x * 0.18))
    cube(root, "Mechanic bib pocket", (0, -0.382, 1.20), (0.35, 0.055, 0.23), DENIM_LIGHT, 0.03)
    cube(root, "Mechanic tool belt", (0, -0.02, 0.90), (0.84, 0.52, 0.15), BROWN, 0.045)
    cube(root, "Tool pouch", (0.37, -0.27, 0.82), (0.25, 0.15, 0.38), OCHRE, 0.045)
    cylinder(root, "Spanner badge", (0, -0.42, 1.21), 0.075, 0.035, STEEL, 12, (math.pi / 2, 0, 0))
    add_limb(root, -1, "leg", DENIM)
    add_limb(root, 1, "leg", DENIM)
    add_limb(root, -1, "arm", CREAM)
    add_limb(root, 1, "arm", CREAM)
    head = empty(root, "HeadPivot", (0, 0, 1.84))
    sphere(head, "Head", (0, 0, 0.04), (0.31, 0.285, 0.34), SKIN, 24, 16)
    add_face(head, DARK, "beanie")
    add_identity_marker(root, MARKER_BLUE, "gear")
    return root


def export(root, path):
    bpy.ops.object.select_all(action="DESELECT")
    root.select_set(True)
    for obj in root.children_recursive:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = root
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        use_selection=True,
        export_apply=True,
        export_yup=True,
    )


def point_camera(camera, target):
    camera.rotation_euler = (Vector(target) - camera.location).to_track_quat("-Z", "Y").to_euler()


def render_preview(grower, mechanic):
    grower.location.x = -0.85
    mechanic.location.x = 0.85
    grower.rotation_euler[2] = math.radians(-7)
    mechanic.rotation_euler[2] = math.radians(7)
    cube(None, "Review grass", (0, 0, -0.09), (5.2, 4.1, 0.16), material("Review meadow", (0.39, 0.53, 0.25)), 0.06)
    bpy.ops.object.light_add(type="AREA", location=(-3.5, -4.2, 7.2))
    key = bpy.context.object
    key.data.energy = 930
    key.data.shape = "DISK"
    key.data.size = 5.0
    point_camera(key, (0, 0, 1.0))
    bpy.ops.object.light_add(type="AREA", location=(4.0, 1.5, 4.5))
    fill = bpy.context.object
    fill.data.energy = 440
    fill.data.size = 4.0
    point_camera(fill, (0, 0, 1.1))
    bpy.ops.object.camera_add(location=(4.5, -7.5, 4.0))
    camera = bpy.context.object
    point_camera(camera, (0, 0, 1.15))
    camera.data.type = "ORTHO"
    camera.data.ortho_scale = 3.45
    scene = bpy.context.scene
    scene.camera = camera
    scene.render.engine = "BLENDER_EEVEE_NEXT"
    scene.render.resolution_x = 1200
    scene.render.resolution_y = 900
    scene.render.resolution_percentage = 100
    scene.render.image_settings.file_format = "PNG"
    scene.render.filepath = str(PREVIEW)
    scene.render.film_transparent = False
    scene.world = bpy.data.worlds.new("Warm character review sky")
    scene.world.color = (0.18, 0.27, 0.29)
    scene.view_settings.look = "AgX - Medium High Contrast"
    bpy.ops.render.render(write_still=True)


grower = make_grower()
mechanic = make_mechanic()
export(grower, ASSETS / "bracken_grower.glb")
export(mechanic, ASSETS / "bracken_mechanic.glb")
render_preview(grower, mechanic)
print("WROTE", ASSETS / "bracken_grower.glb")
print("WROTE", ASSETS / "bracken_mechanic.glb")
print("WROTE", PREVIEW)
