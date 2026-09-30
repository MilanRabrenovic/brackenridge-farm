import bpy
import math
import os
import random
from mathutils import Vector

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
GLB = os.path.join(ROOT, "game/assets/buildings/bracken_machinery_shed.glb")
PREVIEW = os.path.join(ROOT, "docs/previews/bracken-machinery-shed.png")
TRACTOR_GLB = os.path.join(ROOT, "game/assets/vehicles/bracken_tractor.glb")
TEXTURE_DIR = os.path.join(ROOT, "game/assets/textures/machinery_shed")
STONE_TEXTURE = os.path.join(TEXTURE_DIR, "painted_limestone.png")
TIMBER_TEXTURE = os.path.join(TEXTURE_DIR, "painted_timber.png")
METAL_TEXTURE = os.path.join(TEXTURE_DIR, "painted_sage_metal.png")
CONCRETE_TEXTURE = os.path.join(TEXTURE_DIR, "painted_cream_concrete.png")
random.seed(7319)

bpy.ops.wm.read_factory_settings(use_empty=True)
os.makedirs(os.path.dirname(GLB), exist_ok=True)
os.makedirs(os.path.dirname(PREVIEW), exist_ok=True)


def material(name, color, roughness=0.75, metallic=0.0, emission=None, texture=None, texture_scale=(1.0, 1.0)):
    value = bpy.data.materials.new(name)
    value.diffuse_color = (*color, 1)
    value.use_nodes = True
    shader = value.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    shader.inputs["Metallic"].default_value = metallic
    if texture and os.path.exists(texture):
        coordinates = value.node_tree.nodes.new("ShaderNodeTexCoord")
        mapping = value.node_tree.nodes.new("ShaderNodeMapping")
        mapping.vector_type = "POINT"
        mapping.inputs["Scale"].default_value = (texture_scale[0], texture_scale[1], 1.0)
        image_node = value.node_tree.nodes.new("ShaderNodeTexImage")
        image_node.image = bpy.data.images.load(texture, check_existing=True)
        image_node.extension = "REPEAT"
        image_node.interpolation = "Linear"
        value.node_tree.links.new(coordinates.outputs["UV"], mapping.inputs["Vector"])
        value.node_tree.links.new(mapping.outputs["Vector"], image_node.inputs["Vector"])
        value.node_tree.links.new(image_node.outputs["Color"], shader.inputs["Base Color"])
    if emission:
        shader.inputs["Emission Color"].default_value = (*emission, 1)
        shader.inputs["Emission Strength"].default_value = 1.5
    return value


steel = material("Painted Forest Green Frame", (0.075, 0.24, 0.14), 0.68, 0.26)
steel_edge = material("Soft Sage Frame Edge", (0.38, 0.51, 0.34), 0.72, 0.16)
roof = material("Hand Painted Sage Roof", (0.17, 0.38, 0.27), 0.82, 0.10, texture=METAL_TEXTURE, texture_scale=(2.5, 1.8))
roof_light = material("Mint Roof Ridges", (0.38, 0.60, 0.40), 0.76, 0.08)
translucent = material("Cream Daylight Panels", (0.66, 0.80, 0.63), 0.46, 0.02)
timber = material("Hand Painted Chestnut Cladding", (0.31, 0.135, 0.045), 0.94, texture=TIMBER_TEXTURE, texture_scale=(1.8, 1.25))
timber_light = material("Honey Timber Edge", (0.57, 0.30, 0.09), 0.90)
interior = material("Soft Green Interior Shadow", (0.055, 0.105, 0.065), 0.98)
concrete = material("Hand Painted Cream Concrete", (0.54, 0.49, 0.35), 0.96, texture=CONCRETE_TEXTURE, texture_scale=(2.2, 2.2))
concrete_edge = material("Sunlit Apron Edge", (0.68, 0.60, 0.40), 0.94)
stone = [
    material("Painted Limestone Honey", (0.54, 0.32, 0.10), 0.94, texture=STONE_TEXTURE, texture_scale=(1.4, 1.4)),
    material("Painted Limestone Pale", (0.72, 0.53, 0.23), 0.92, texture=STONE_TEXTURE, texture_scale=(1.1, 1.1)),
    material("Painted Limestone Shade", (0.38, 0.20, 0.065), 0.96, texture=STONE_TEXTURE, texture_scale=(1.7, 1.7)),
]
door_green = material("Hand Painted Sliding Door", (0.055, 0.34, 0.24), 0.80, 0.10, texture=METAL_TEXTURE, texture_scale=(1.8, 1.5))
warning = material("Sunny Ochre", (0.95, 0.58, 0.07), 0.80)
red = material("Warm Workshop Red", (0.72, 0.075, 0.035), 0.76, 0.06)
rubber = material("Spare Tyre Rubber", (0.018, 0.022, 0.020), 0.95)
lamp = material("Golden Work Lamp", (1.0, 0.60, 0.14), 0.30, emission=(1.0, 0.53, 0.14))
glass = material("Sky Blue Workshop Window", (0.10, 0.40, 0.48), 0.25, 0.02)
barrel_blue = material("Cornflower Blue Barrel", (0.09, 0.31, 0.62), 0.78, 0.08)
cream = material("Painted Cream Trim", (0.83, 0.70, 0.43), 0.88)

root = bpy.data.objects.new("BrackenMachineryShed", None)
bpy.context.collection.objects.link(root)


def parent(obj, target=root):
    obj.parent = target
    return obj


def bevel(obj, width=0.04, segments=2):
    if width <= 0:
        return obj
    modifier = obj.modifiers.new("Soft authored edge", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
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


def cylinder(name, loc, radius, depth, mat, rot=(0, 0, 0), vertices=16, edge=0.02):
    bpy.ops.mesh.primitive_cylinder_add(vertices=vertices, radius=radius, depth=depth, location=loc, rotation=rot)
    obj = bpy.context.object
    obj.name = name
    bevel(obj, edge, 2)
    obj.data.materials.append(mat)
    return parent(obj)


def beam_between(name, start, end, thickness, mat):
    start_v = Vector(start)
    end_v = Vector(end)
    delta = end_v - start_v
    obj = cube(name, (start_v + end_v) * 0.5, (thickness, thickness, delta.length), mat, min(thickness * 0.16, 0.04))
    obj.rotation_euler = delta.to_track_quat("Z", "Y").to_euler()
    return obj


WIDTH, DEPTH, EAVE, RIDGE = 24.0, 11.5, 4.75, 6.72
FRONT, BACK = -DEPTH / 2, DEPTH / 2
BAY_X = [-12.0, -6.0, 0.3, 6.1, 12.0]

# Working slab and broad apron establish believable machinery access.
cube("ConcreteSlab", (0, 0, 0.06), (24.8, 12.0, 0.20), concrete, 0.06)
cube("FrontApron", (0, -7.35, 0.03), (27.0, 3.2, 0.14), concrete_edge, 0.08)
for x in (-11.4, -5.7, 0.35, 6.15, 11.45):
    cube("ApronJoint", (x, -7.35, 0.112), (0.045, 3.05, 0.012), steel_edge, 0.004)

# Timber-clad rear and side walls. The open volume stays physically empty so
# vehicles and props remain visible rather than sitting behind a black facade.
cube("RearWallCore", (0, BACK - 0.10, 2.40), (24.0, 0.26, 4.70), timber, 0.035)
for x in range(-11, 12):
    width = 0.82 + random.uniform(-0.12, 0.12)
    cube("RearCladdingBoard", (x, BACK + 0.075, 3.18), (width, 0.105, 3.05), timber_light if x % 5 == 0 else timber, 0.016)
    cube("RearBoardShadow", (x + width / 2, BACK + 0.142, 3.18), (0.030, 0.026, 2.92), steel, 0.004)
for side in (-1, 1):
    x = side * (WIDTH / 2 - 0.10)
    cube("SideWallCore", (x, 0.18, 2.40), (0.26, 11.0, 4.70), timber, 0.035)
    for row in range(13):
        yy = FRONT + 0.55 + row * 0.86
        cube("SideCladdingBoard", (x + side * 0.075, yy, 3.18), (0.105, 0.75, 3.05), timber_light if row % 5 == 0 else timber, 0.014)

# A large round gable window gives the otherwise practical shed a friendly,
# memorable face from the gameplay camera.
cylinder("RoundGableGlass", (12.08, 1.55, 3.46), 0.72, 0.08, glass, (0, math.pi / 2, 0), 24, 0.025)
bpy.ops.mesh.primitive_torus_add(major_radius=0.73, minor_radius=0.105, major_segments=24, minor_segments=8, location=(12.14, 1.55, 3.46), rotation=(0, math.pi / 2, 0))
gable_rim = bpy.context.object
gable_rim.name = "CreamRoundWindowRim"
gable_rim.data.materials.append(cream)
parent(gable_rim)
cube("RoundWindowMullion", (12.19, 1.55, 3.46), (0.08, 1.20, 0.12), cream, 0.02)
cube("RoundWindowMullion", (12.19, 1.55, 3.46), (0.08, 0.12, 1.20), cream, 0.02)

# Cotswold-stone plinth ties the modern shed to the old barn.
for side in (-1, 1):
    x = side * 11.92
    for row in range(2):
        z = 0.38 + row * 0.62
        y = FRONT + 0.15
        while y < BACK - 0.15:
            length = random.uniform(0.68, 1.18)
            cube("SidePlinthStone", (x + side * 0.10, y, z), (0.24, length - 0.04, 0.52), stone[(row + int((y + 20) * 3)) % 3], 0.025)
            y += length
z, course = 0.36, 0
while z < 1.28:
    x = -11.75 + (0.22 if course % 2 else 0)
    while x < 11.75:
        width = random.uniform(0.58, 1.05)
        cube("RearPlinthStone", (x + width / 2, BACK + 0.16, z), (width - 0.04, 0.24, 0.385), stone[random.randrange(3)], 0.024)
        x += width
    z += 0.43
    course += 1

# Five portal frames create three open machine bays and one parts bay.
for x in BAY_X:
    for y in (FRONT + 0.13, BACK - 0.24):
        cube("PortalColumn", (x, y, EAVE / 2), (0.36, 0.42, EAVE), steel, 0.065)
        cube("ColumnFoot", (x, y, 0.16), (0.70, 0.80, 0.22), steel_edge, 0.065)
        for bx in (-0.20, 0.20):
            for by in (-0.25, 0.25):
                cylinder("AnchorBolt", (x + bx, y + by, 0.31), 0.035, 0.12, steel_edge, vertices=10, edge=0.005)
    beam_between("FrontRoofRafter", (x, FRONT + 0.13, EAVE), (x, 0, RIDGE), 0.34, steel)
    beam_between("RearRoofRafter", (x, BACK - 0.24, EAVE), (x, 0, RIDGE), 0.34, steel)
    beam_between("FrontKneeBrace", (x, FRONT + 0.18, 3.55), (x, FRONT + 1.40, EAVE), 0.19, steel_edge)
    beam_between("RearKneeBrace", (x, BACK - 0.28, 3.55), (x, BACK - 1.40, EAVE), 0.19, steel_edge)
for y in (FRONT + 0.30, -2.8, 0, 2.8, BACK - 0.35):
    purlin_z = RIDGE - abs(y) * (RIDGE - EAVE) / (DEPTH / 2) - 0.12
    cube("RoofPurlin", (0, y, purlin_z), (24.35, 0.16, 0.18), steel_edge, 0.025)
for side in (-1, 1):
    cube("EaveBeam", (0, side * (DEPTH / 2 - 0.16), EAVE), (24.35, 0.22, 0.25), steel, 0.03)

# Corrugated roof, raised ridges, and broad translucent daylight strips.
pitch = math.atan2(RIDGE - EAVE, DEPTH / 2)
slope = math.sqrt((DEPTH / 2) ** 2 + (RIDGE - EAVE) ** 2)
for side in (-1, 1):
    y = side * (DEPTH / 4 + 0.08)
    z = (RIDGE + EAVE) / 2 + 0.04
    cube("RoofSheet", (0, y, z), (24.65, slope + 0.35, 0.16), roof, 0.035, (-side * pitch, 0, 0))
    for index, x in enumerate([v * 0.42 for v in range(-29, 30)]):
        if index in (12, 13, 14, 43, 44, 45):
            continue
        cube("RoofCorrugation", (x, y - side * 0.035, z + 0.075), (0.055, slope + 0.22, 0.075), roof_light, 0.012, (-side * pitch, 0, 0))
    for x in (-6.85, 6.35):
        cube("RoofDaylightStrip", (x, y - side * 0.045, z + 0.095), (1.05, slope - 0.25, 0.06), translucent, 0.018, (-side * pitch, 0, 0))
cube("RoofRidgeCap", (0, 0, RIDGE + 0.08), (24.75, 0.44, 0.24), steel_edge, 0.06)
cube("FriendlyFrontFascia", (0, FRONT - 0.08, EAVE + 0.02), (24.75, 0.20, 0.30), cream, 0.075)
# A small ridge vent breaks the long roof silhouette without adding an
# expensive separate structure.
cylinder("RidgeVent", (-2.7, 0.15, RIDGE + 0.62), 0.34, 0.92, steel, vertices=18, edge=0.055)
cylinder("RidgeVentCap", (-2.7, 0.15, RIDGE + 1.10), 0.48, 0.12, cream, vertices=18, edge=0.055)
for side in (-1, 1):
    cylinder("RainGutter", (0, side * (DEPTH / 2 + 0.08), EAVE - 0.02), 0.105, 24.45, steel_edge, (0, math.pi / 2, 0), 14, 0.014)
for x in (-11.75, 11.75):
    cylinder("Downpipe", (x, BACK + 0.10, EAVE / 2), 0.085, EAVE - 0.20, steel_edge, vertices=12, edge=0.012)

# Bracing makes the structure believable from oblique gameplay views.
for left, right in ((-6.0, 0.3), (6.1, 12.0)):
    beam_between("RearCrossBrace", (left + 0.35, BACK - 0.34, 1.35), (right - 0.35, BACK - 0.34, 4.28), 0.11, steel_edge)
    beam_between("RearCrossBrace", (right - 0.35, BACK - 0.36, 1.35), (left + 0.35, BACK - 0.36, 4.28), 0.11, steel_edge)

# Enclosed right-hand parts room leaves three full machine bays open.
room_left, room_right = 6.35, 11.70
cube("PartsRoom", ((room_left + room_right) / 2, 2.40, 2.05), (room_right - room_left, 6.20, 4.05), timber, 0.045)
cube("PartsRoomStoneBase", ((room_left + room_right) / 2, -0.66, 0.55), (room_right - room_left, 0.28, 1.10), stone[0], 0.035)
cube("SlidingPartsDoor", ((room_left + room_right) / 2, -0.78, 2.30), (4.45, 0.18, 3.70), door_green, 0.04)
for x in [room_left + 0.22 + i * 0.34 for i in range(15)]:
    cube("DoorCorrugation", (x, -0.90, 2.30), (0.045, 0.055, 3.52), roof_light, 0.008)
cube("DoorTopRail", ((room_left + room_right) / 2, -0.94, 4.33), (5.35, 0.16, 0.18), steel_edge, 0.025)
for x in (7.02, 11.02):
    cylinder("DoorRoller", (x, -1.04, 4.25), 0.12, 0.10, steel, (math.pi / 2, 0, 0), 14, 0.014)
cube("PartsWindowRecess", (10.72, -0.91, 2.34), (1.32, 0.14, 1.20), interior, 0.02)
cube("PartsWindowGlass", (10.72, -1.00, 2.34), (1.10, 0.035, 1.00), glass, 0.012)
for x in (10.16, 11.28):
    cube("WindowFrame", (x, -1.04, 2.34), (0.09, 0.06, 1.18), steel_edge, 0.01)
for z in (1.77, 2.91):
    cube("WindowFrame", (10.72, -1.04, z), (1.22, 0.06, 0.09), steel_edge, 0.01)

# Large readable workshop props, all inside the authored asset.
cube("Workbench", (8.80, 4.42, 1.00), (4.00, 0.82, 0.22), timber_light, 0.045)
for x in (7.10, 10.50):
    cube("WorkbenchLeg", (x, 4.42, 0.52), (0.22, 0.60, 1.02), steel, 0.025)
cube("RedToolChest", (5.20, 4.60, 0.82), (1.35, 0.74, 1.58), red, 0.07)
for z in (0.45, 0.79, 1.13):
    cube("ToolDrawerLine", (5.20, 4.20, z), (1.12, 0.025, 0.035), steel_edge, 0.005)
for x in (-10.15, -9.45):
    for z in (0.42, 1.22):
        cylinder("SpareTyre", (x, 4.82, z), 0.48, 0.30, rubber, (math.pi / 2, 0, 0), 18, 0.025)
        cylinder("SpareTyreHub", (x, 4.65, z), 0.19, 0.06, steel_edge, (math.pi / 2, 0, 0), 14, 0.012)

# A few bold, warm props give the bays a friendly working-farm personality.
for x, mat in ((0.85, barrel_blue), (1.58, warning), (2.31, barrel_blue)):
    cylinder("ColourfulOilBarrel", (x, 4.72, 0.62), 0.34, 1.10, mat, vertices=18, edge=0.055)
    for z in (0.22, 1.02):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.34, minor_radius=0.028, major_segments=18, minor_segments=6, location=(x, 4.72, z))
        hoop = bpy.context.object
        hoop.name = "BarrelHoop"
        hoop.data.materials.append(cream)
        parent(hoop)
for level in range(2):
    for column in range(2):
        cube("PartsCrate", (-4.75 + column * 0.85, 4.70, 0.40 + level * 0.72), (0.72, 0.82, 0.64), timber_light if (level + column) % 2 else warning, 0.085)

# Bay markers and lamps preserve a strong front rhythm at TV distance.
for index, (x, plate_mat) in enumerate(((-9.0, warning), (-2.85, steel_edge), (3.20, warning))):
    cube("BayPlate", (x, FRONT - 0.10, 4.38), (1.35, 0.12, 0.42), plate_mat, 0.04)
    for dot in range(index + 1):
        cylinder("BayMarker", (x - 0.26 * index + dot * 0.52, FRONT - 0.18, 4.38), 0.075, 0.035, interior, (math.pi / 2, 0, 0), 12, 0.01)
    cube("LampBracket", (x, FRONT - 0.02, 4.12), (0.10, 0.32, 0.14), steel, 0.015)
    cube("WorkLamp", (x, FRONT - 0.20, 3.97), (0.42, 0.22, 0.16), lamp, 0.04)


def join_static_meshes_by_material():
    groups = {}
    for obj in list(root.children_recursive):
        if obj.type == "MESH" and obj.data.materials:
            groups.setdefault(obj.data.materials[0].name, []).append(obj)
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
        matrix = active.matrix_world.copy()
        active.parent = root
        active.matrix_world = matrix


join_static_meshes_by_material()
bpy.ops.object.select_all(action="DESELECT")
root.select_set(True)
for obj in root.children_recursive:
    obj.select_set(True)
bpy.context.view_layer.objects.active = root
bpy.ops.export_scene.gltf(filepath=GLB, export_format="GLB", use_selection=True, export_apply=True, export_yup=True)

# Preview stage is created after export and never enters the GLB.
bpy.ops.mesh.primitive_plane_add(size=50, location=(0, 0, -0.05))
bpy.context.object.data.materials.append(material("Preview Meadow", (0.34, 0.51, 0.20), 0.98))
if os.path.exists(TRACTOR_GLB):
    existing = set(bpy.data.objects)
    bpy.ops.import_scene.gltf(filepath=TRACTOR_GLB)
    imported = [obj for obj in bpy.data.objects if obj not in existing]
    for imported_root in [obj for obj in imported if obj.parent is None]:
        imported_root.location = (-8.8, -1.4, 0.10)
        imported_root.rotation_euler[2] = math.radians(-4)

bpy.ops.object.light_add(type="AREA", location=(-10, -13, 17))
bpy.context.object.data.energy = 2850
bpy.context.object.data.shape = "DISK"
bpy.context.object.data.size = 10
bpy.ops.object.light_add(type="AREA", location=(12, -1, 9))
bpy.context.object.data.energy = 1250
bpy.context.object.data.size = 9
bpy.ops.object.light_add(type="AREA", location=(0, -5.5, 5.3))
bpy.context.object.data.energy = 1150
bpy.context.object.data.size = 11
bpy.ops.object.camera_add(location=(25.5, -31.5, 20.0))
camera = bpy.context.object
camera.rotation_euler = (Vector((0, 0.25, 2.65)) - camera.location).to_track_quat("-Z", "Y").to_euler()
camera.data.type = "ORTHO"
camera.data.ortho_scale = 31.0
scene = bpy.context.scene
scene.camera = camera
scene.render.engine = "BLENDER_EEVEE_NEXT"
scene.render.resolution_x = 1400
scene.render.resolution_y = 900
scene.render.resolution_percentage = 100
scene.render.image_settings.file_format = "PNG"
scene.render.filepath = PREVIEW
scene.world = bpy.data.worlds.new("Machinery Shed Preview World")
scene.world.color = (0.18, 0.30, 0.34)
scene.view_settings.look = "AgX - Medium High Contrast"
bpy.ops.render.render(write_still=True)
print("WROTE", GLB)
print("WROTE", PREVIEW)
