"""Create the authored grain silos, combine and trailer for Brackenridge Farm.

The assets share the existing painted storybook materials and expose named
animation pivots so gameplay can animate them without rebuilding the meshes.
"""

import math
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "game" / "assets"
TEXTURES = ASSETS / "textures" / "machinery_shed"
SHARED = ASSETS / "textures" / "storybook_shared"
PREVIEWS = ROOT / "docs" / "previews"
PREVIEWS.mkdir(parents=True, exist_ok=True)

bpy.ops.wm.read_factory_settings(use_empty=True)


def painted(name, path, scale=(1.0, 1.0), roughness=0.9, metallic=0.0):
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
    mapping.inputs["Scale"].default_value = (*scale, 1.0)
    mat.node_tree.links.new(coords.outputs["UV"], mapping.inputs["Vector"])
    mat.node_tree.links.new(mapping.outputs["Vector"], image.inputs["Vector"])
    mat.node_tree.links.new(image.outputs["Color"], shader.inputs["Base Color"])
    return mat


def flat(name, color, roughness=0.88, metallic=0.0, emission=None):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1)
        shader.inputs["Emission Strength"].default_value = 1.4
    return mat


sage = painted("Painted sage machinery", TEXTURES / "painted_sage_metal.png", (2.2, 1.5), 0.74, 0.12)
timber = painted("Painted chestnut", TEXTURES / "painted_timber.png", (1.8, 1.3))
stone = painted("Painted honey stone", TEXTURES / "painted_limestone.png", (1.6, 1.3))
cream = painted("Painted warm cream", TEXTURES / "painted_cream_concrete.png", (2.0, 2.0))
steel = painted("Painted farm steel", SHARED / "painted_farm_steel.png", (1.8, 1.5), 0.68, 0.18)
rubber = painted("Painted tyre rubber", SHARED / "painted_tractor_rubber.png", (1.4, 1.4), 0.96)
red = painted("Painted warm red", SHARED / "painted_red_enamel.png", (1.8, 1.5), 0.7, 0.08)
gold = flat("Harvest gold", (0.94, 0.58, 0.07), 0.82)
glass = flat("Cab glass", (0.16, 0.48, 0.55), 0.32, 0.12)
dark = flat("Deep green steel", (0.045, 0.18, 0.12), 0.72, 0.16)
blue = flat("Status blue", (0.08, 0.45, 0.72), 0.62, emission=(0.06, 0.34, 0.72))
amber = flat("Status amber", (0.98, 0.52, 0.06), 0.62, emission=(0.98, 0.38, 0.03))


def root(name):
    obj = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(obj)
    return obj


def bevel(obj, width=0.05, segments=2):
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


def cube(name, loc, size, mat, parent, edge=0.06, rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(mat)
    obj.parent = parent
    return obj


def cylinder(name, loc, radius, depth, mat, parent, rot=(0, 0, 0), vertices=24, edge=0.04):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge)
    obj.data.materials.append(mat)
    obj.parent = parent
    return obj


def beam(name, start, end, width, mat, parent):
    a, b = Vector(start), Vector(end)
    obj = cube(name, (a + b) * 0.5, (width, width, (b - a).length), mat, parent, min(0.05, width * 0.16))
    obj.rotation_euler = (b - a).to_track_quat("Z", "Y").to_euler()
    return obj


def wheel(name, loc, radius, width, parent):
    return cylinder(name, loc, radius, width, rubber, parent, (0, math.pi / 2, 0), 20, 0.06)


def join_material_groups(owner, preserve=()):
    groups = {}
    for obj in list(owner.children_recursive):
        if obj.type != "MESH" or obj.name in preserve or not obj.material_slots:
            continue
        material = obj.material_slots[0].material
        if material:
            groups.setdefault((obj.parent, material.name), []).append(obj)
    for (parent, material_name), objects in groups.items():
        if len(objects) == 1:
            objects[0].name = material_name
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = objects[0]
        bpy.ops.object.join()
        objects[0].name = material_name
        objects[0].parent = parent


def export(owner, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.object.select_all(action="DESELECT")
    owner.select_set(True)
    for obj in owner.children_recursive:
        obj.select_set(True)
    bpy.context.view_layer.objects.active = owner
    bpy.ops.export_scene.gltf(filepath=str(path), export_format="GLB", use_selection=True, export_apply=True, export_yup=True)


def silo_set():
    owner = root("BrackenConnectedSilos")
    cube("Shared plinth", (0, 0, 0.22), (15.5, 7.5, 0.44), cream, owner, 0.12)
    xs = (-4.8, 0.0, 4.8)
    heights = (10.2, 11.3, 9.6)
    for index, (x, height) in enumerate(zip(xs, heights)):
        cylinder("Silo shell", (x, 0.3, height / 2 + 0.45), 2.15, height, sage, owner, vertices=28, edge=0.08)
        cylinder("Silo roof", (x, 0.3, height + 1.08), 2.32, 1.35, steel, owner, vertices=28, edge=0.07)
        # Corrugation reads as broad painted bands instead of high-poly ridges.
        for band in range(1, 8):
            cylinder("Silo painted band", (x, 0.3, 0.65 + band * height / 8), 2.19, 0.10, cream, owner, vertices=28, edge=0.02)
        for z in range(1, int(height), 1):
            cube("Ladder rung", (x + 2.22, 0.30, z + 0.45), (0.10, 0.75, 0.09), cream, owner, 0.02)
        cube("Ladder rail", (x + 2.22, -0.02, height / 2 + 0.45), (0.11, 0.10, height - 0.7), dark, owner, 0.025)
        cube("Ladder rail", (x + 2.22, 0.62, height / 2 + 0.45), (0.11, 0.10, height - 0.7), dark, owner, 0.025)
        cylinder("Fill indicator", (x - 2.19, -0.35, 2.0 + index * 0.3), 0.24, 0.15, blue if index < 2 else amber, owner, (math.pi / 2, 0, 0), 16, 0.03)
    beam("Top transfer pipe", (-4.8, 0.3, 12.0), (4.8, 0.3, 12.0), 0.46, sage, owner)
    beam("Feed pipe", (0.0, 0.3, 12.0), (0.0, -4.2, 5.8), 0.42, sage, owner)
    for x in (-5.8, 5.8):
        beam("Pipe gantry leg", (x, -2.1, 0.45), (x, -2.1, 12.0), 0.32, dark, owner)
    beam("Pipe gantry", (-5.8, -2.1, 12.0), (5.8, -2.1, 12.0), 0.34, dark, owner)
    cube("Control kiosk", (-6.2, 2.5, 1.35), (2.1, 1.7, 2.5), timber, owner, 0.12)
    cube("Control kiosk roof", (-6.2, 2.5, 2.72), (2.4, 2.0, 0.18), steel, owner, 0.07)
    join_material_groups(owner)
    export(owner, ASSETS / "buildings" / "bracken_silo_set.glb")
    return owner


def combine():
    owner = root("BrackenCombine")
    cube("Combine body", (0, 0.15, 2.25), (3.9, 5.0, 2.7), sage, owner, 0.25)
    cube("Grain tank", (0, 0.55, 4.15), (3.45, 3.25, 1.45), gold, owner, 0.28)
    cube("Cab", (0, -1.35, 3.85), (3.15, 2.05, 2.45), glass, owner, 0.22, (math.radians(-5), 0, 0))
    cube("Cab roof", (0, -1.32, 5.15), (3.45, 2.2, 0.25), cream, owner, 0.12)
    cube("Rear service panel", (0, 2.58, 2.2), (3.25, 0.22, 2.0), red, owner, 0.12)
    for x in (-1.85, 1.85):
        wheel("FrontWheelPivot" if x < 0 else "FrontWheelPivotR", (x, -1.0, 1.18), 1.15, 0.55, owner)
        wheel("RearWheelPivot" if x < 0 else "RearWheelPivotR", (x, 1.65, 0.82), 0.77, 0.48, owner)
    header = root("HeaderPivot")
    header.parent = owner
    cube("Header beam", (0, -4.05, 0.82), (6.8, 1.35, 0.52), red, header, 0.14)
    reel = root("ReelPivot")
    reel.parent = header
    reel.location = (0, -4.45, 1.05)
    cylinder("Reel axle", (0, 0, 0), 0.16, 6.45, dark, reel, (0, math.pi / 2, 0), 18, 0.04)
    for x in (-2.8, -1.4, 0, 1.4, 2.8):
        for spoke in range(6):
            angle = spoke * math.tau / 6
            beam("Reel tine", (x, 0, 0), (x, math.sin(angle) * 0.72, math.cos(angle) * 0.72), 0.08, gold, reel)
    for index in range(13):
        cube("Header tooth", (-3.0 + index * 0.5, -4.78, 0.55), (0.16, 0.58, 0.12), cream, header, 0.025, (0, 0, math.radians((-1) ** index * 4)))
    auger = root("UnloadAugerPivot")
    auger.parent = owner
    auger.location = (1.85, 0.2, 4.3)
    beam("Unload auger", (0, 0, 0), (3.8, 0.3, 1.0), 0.38, sage, auger)
    cylinder("Beacon", (0, -0.25, 5.42), 0.18, 0.28, amber, owner, vertices=16, edge=0.04)
    join_material_groups(owner, ("HeaderPivot", "ReelPivot", "UnloadAugerPivot"))
    export(owner, ASSETS / "vehicles" / "bracken_combine.glb")
    return owner


def grain_trailer():
    owner = root("BrackenGrainTrailer")
    chassis = cube("Trailer chassis", (0, 0, 0.72), (2.8, 5.7, 0.32), dark, owner, 0.08)
    bed = root("TipBedPivot")
    bed.parent = owner
    bed.location = (0, 2.35, 1.05)
    cube("Trailer bed floor", (0, -2.35, 0.25), (3.1, 5.5, 0.30), sage, bed, 0.12)
    cube("Trailer left side", (-1.48, -2.35, 1.45), (0.22, 5.5, 2.35), sage, bed, 0.12)
    cube("Trailer right side", (1.48, -2.35, 1.45), (0.22, 5.5, 2.35), sage, bed, 0.12)
    cube("Trailer front", (0, -4.98, 1.45), (3.1, 0.22, 2.35), red, bed, 0.12)
    tail = root("TailgatePivot")
    tail.parent = bed
    tail.location = (0, 0.30, 0.35)
    cube("Trailer tailgate", (0, 0, 1.1), (3.1, 0.22, 2.2), gold, tail, 0.12)
    for y in (-1.0, 1.15):
        for x in (-1.48, 1.48):
            wheel("TrailerWheel", (x, y, 0.68), 0.68, 0.40, owner)
    beam("Drawbar left", (-0.55, -2.95, 0.68), (-0.12, -4.2, 0.50), 0.15, dark, owner)
    beam("Drawbar right", (0.55, -2.95, 0.68), (0.12, -4.2, 0.50), 0.15, dark, owner)
    cylinder("Hitch ring", (0, -4.35, 0.5), 0.20, 0.12, steel, owner, (math.pi / 2, 0, 0), 16, 0.035)
    for level in (0.58, 1.25, 1.92):
        cube("Fill marker", (1.61, -1.5, level + 0.9), (0.12, 0.65, 0.14), cream, bed, 0.025)
    join_material_groups(owner, ("TipBedPivot", "TailgatePivot"))
    export(owner, ASSETS / "vehicles" / "bracken_grain_trailer.glb")
    return owner


silos = silo_set()
silos.hide_render = True
harvester = combine()
harvester.location = (-4.5, 0, 0)
trailer = grain_trailer()
trailer.location = (4.5, 0, 0)

# One contact sheet documents the full chain at the gameplay angle.
for obj in silos.children_recursive:
    obj.hide_render = False
silos.hide_render = False
silos.location = (0, 7.5, 0)
bpy.ops.mesh.primitive_plane_add(size=48, location=(0, 3.0, -0.08))
bpy.context.object.data.materials.append(flat("Review grass", (0.32, 0.51, 0.21), 0.98))
bpy.ops.object.light_add(type="AREA", location=(-10, -12, 22))
bpy.context.object.data.energy = 2800
bpy.context.object.data.size = 10
bpy.ops.object.light_add(type="AREA", location=(14, 9, 15))
bpy.context.object.data.energy = 1300
bpy.context.object.data.size = 9
bpy.ops.object.camera_add(location=(27, -33, 25))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 3.0, 3.2)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 31
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1400
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = str(PREVIEWS / "bracken-grain-chain.png")
scene.world = bpy.data.worlds.new("Storybook review sky")
scene.world.color = (0.22, 0.34, 0.38)
scene.view_settings.look = "AgX - Medium High Contrast"
bpy.ops.render.render(write_still=True)
print("WROTE grain-chain assets and preview")
