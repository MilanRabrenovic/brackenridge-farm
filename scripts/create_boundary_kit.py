import math
import random
from pathlib import Path

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "game" / "assets" / "environment" / "boundary_kit"
TEXTURES = ROOT / "game" / "assets" / "textures" / "storybook_shared"
SHED_TEXTURES = ROOT / "game" / "assets" / "textures" / "machinery_shed"
OUT.mkdir(parents=True, exist_ok=True)


def reset():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def painted(name, path, scale=(1.0, 1.0), roughness=0.96):
    mat = bpy.data.materials.new(name)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Roughness"].default_value = roughness
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


def flat(name, color, roughness=0.95):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1)
    mat.use_nodes = True
    shader = mat.node_tree.nodes.get("Principled BSDF")
    shader.inputs["Base Color"].default_value = (*color, 1)
    shader.inputs["Roughness"].default_value = roughness
    return mat


def root(name):
    value = bpy.data.objects.new(name, None)
    bpy.context.collection.objects.link(value)
    return value


def parent(obj, owner):
    obj.parent = owner
    return obj


def bevel(obj, width=0.05, segments=2):
    modifier = obj.modifiers.new("Soft storybook edge", "BEVEL")
    modifier.width = width
    modifier.segments = segments
    modifier.limit_method = "ANGLE"
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    obj.select_set(False)


def cube(name, location, size, material, owner, rotation_z=0.0, edge=0.05):
    bpy.ops.mesh.primitive_cube_add(location=location, rotation=(0, 0, rotation_z))
    obj = bpy.context.object
    obj.name = name
    obj.scale = (size[0] / 2, size[1] / 2, size[2] / 2)
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    bevel(obj, edge)
    obj.data.materials.append(material)
    return parent(obj, owner)


def branch(name, start, end, radius, material, owner):
    a, b = Vector(start), Vector(end)
    delta = b - a
    bpy.ops.mesh.primitive_cone_add(vertices=10, radius1=radius, radius2=radius * 0.35, depth=delta.length, location=(a + b) * 0.5)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_euler = delta.to_track_quat("Z", "Y").to_euler()
    obj.data.materials.append(material)
    return parent(obj, owner)


def blob(name, location, scale, material, owner, seed):
    random.seed(seed)
    bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1, location=location)
    obj = bpy.context.object
    obj.name = name
    for vertex in obj.data.vertices:
        direction = vertex.co.normalized()
        vertex.co *= 1.0 + 0.11 * math.sin(direction.x * 8.2 + seed) + 0.06 * math.sin(direction.y * 12.4 - seed)
    obj.scale = scale
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    obj.data.materials.append(material)
    return parent(obj, owner)


def export_glb(owner, filename):
    bpy.ops.object.select_all(action="DESELECT")
    owner.select_set(True)
    for child in owner.children_recursive:
        child.select_set(True)
    bpy.context.view_layer.objects.active = owner
    bpy.ops.export_scene.gltf(filepath=str(OUT / filename), export_format="GLB", use_selection=True, export_apply=True, export_yup=True)
    print(f"WROTE {OUT / filename}")


def join_material_groups(owner):
    groups = {}
    for obj in list(owner.children_recursive):
        if obj.type != "MESH" or not obj.material_slots or obj.material_slots[0].material is None:
            continue
        key = (obj.parent, obj.material_slots[0].material.name)
        groups.setdefault(key, []).append(obj)
    for (object_parent, material_name), objects in groups.items():
        if len(objects) < 2:
            objects[0].name = material_name
            continue
        bpy.ops.object.select_all(action="DESELECT")
        for obj in objects:
            obj.select_set(True)
        bpy.context.view_layer.objects.active = objects[0]
        bpy.ops.object.join()
        objects[0].name = material_name
        objects[0].parent = object_parent


def sample_path(path, spacing=0.82):
    result = []
    for index in range(len(path) - 1):
        a, b = Vector(path[index]), Vector(path[index + 1])
        distance = (b - a).length
        count = max(1, int(math.ceil(distance / spacing)))
        for step in range(count):
            t = step / count
            point = a.lerp(b, t)
            tangent = (b - a).normalized()
            result.append((point, tangent))
    a, b = Vector(path[-2]), Vector(path[-1])
    result.append((b, (b - a).normalized()))
    return result


def hedge_body(owner, path, foliage, bark, seed, taper_start=False, taper_end=False):
    samples = sample_path(path, 0.9)
    vertices, faces = [], []
    ring = 6
    for index, (point, tangent) in enumerate(samples):
        normal = Vector((-tangent.y, tangent.x))
        progress = index / max(1, len(samples) - 1)
        taper = 1.0
        if taper_start:
            taper *= 0.45 + min(1.0, progress * 4.0) * 0.55
        if taper_end:
            taper *= 0.45 + min(1.0, (1.0 - progress) * 4.0) * 0.55
        width = (0.88 + 0.10 * math.sin(index * 2.17 + seed)) * taper
        height = (1.78 + 0.18 * math.sin(index * 1.63 + seed * 0.1)) * (0.78 + taper * 0.22)
        offsets = [(-width, 0.12), (-width, height * 0.62), (-width * 0.42, height), (width * 0.42, height * 0.98), (width, height * 0.62), (width, 0.12)]
        for lateral, z in offsets:
            p = point + normal * lateral
            vertices.append((p.x, p.y, z))
    for section in range(len(samples) - 1):
        for side in range(ring):
            nxt = (side + 1) % ring
            faces.append((section * ring + side, section * ring + nxt, (section + 1) * ring + nxt, (section + 1) * ring + side))
    faces.append(tuple(range(ring - 1, -1, -1)))
    last = (len(samples) - 1) * ring
    faces.append(tuple(last + i for i in range(ring)))
    mesh = bpy.data.meshes.new("Flowing hawthorn silhouette")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(foliage)
    body = bpy.data.objects.new("Continuous flowering hawthorn", mesh)
    bpy.context.collection.objects.link(body)
    parent(body, owner)
    bpy.context.view_layer.objects.active = body
    body.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="SELECT")
    bpy.ops.uv.smart_project(angle_limit=math.radians(66), island_margin=0.03)
    bpy.ops.object.mode_set(mode="OBJECT")
    body.select_set(False)
    bevel(body, 0.12, 3)

    every = max(2, len(samples) // 6)
    for index in range(1, len(samples) - 1, every):
        point, tangent = samples[index]
        normal = Vector((-tangent.y, tangent.x))
        offset = normal * (0.18 if index % 2 else -0.22)
        blob(f"Natural crown break {index}", (point.x + offset.x, point.y + offset.y, 1.64), (1.05, 0.78, 0.62), foliage, owner, seed + index)
        lean = normal * (0.16 if index % 2 else -0.14)
        branch(f"Visible hawthorn stem {index}", (point.x, point.y, 0.04), (point.x + lean.x, point.y + lean.y, 1.28), 0.075, bark, owner)


def hedge_asset(filename, name, path, seed, gate=False, taper_start=False, taper_end=False):
    reset()
    owner = root(name)
    foliage = painted("Painted flowering hawthorn", TEXTURES / "painted_hawthorn.png", (1.65, 1.25))
    bark = painted("Painted hawthorn branches", TEXTURES / "painted_oak_bark.png", (1.1, 1.45))
    timber = painted("Painted field gate timber", SHED_TEXTURES / "painted_timber.png", (1.4, 1.2))
    if gate:
        hedge_body(owner, [(-7.0, 0.0), (-2.45, 0.0)], foliage, bark, seed, taper_end=True)
        hedge_body(owner, [(2.45, 0.0), (7.0, 0.0)], foliage, bark, seed + 20, taper_start=True)
        for x in (-2.2, 2.2):
            cube("Gate stone and timber post", (x, 0, 0.92), (0.38, 0.42, 1.84), timber, owner, edge=0.075)
        pivot = root("GatePivot")
        pivot.location = (-2.0, 0, 0)
        pivot.parent = owner
        for z in (0.46, 1.05):
            rail = cube("Gate rail", (2.0, 0, z), (4.0, 0.16, 0.18), timber, pivot, edge=0.035)
            rail.location.x -= 2.0
        for x in (0.1, 1.95, 3.8):
            upright = cube("Gate upright", (x, 0, 0.76), (0.16, 0.18, 1.38), timber, pivot, edge=0.035)
            upright.location.x -= 2.0
    else:
        hedge_body(owner, path, foliage, bark, seed, taper_start, taper_end)
    join_material_groups(owner)
    export_glb(owner, filename)


def wall_body(owner, path, stone, moss, seed, taper_end=False):
    random.seed(seed)
    samples = sample_path(path, 0.72)
    for course, z in enumerate((0.20, 0.52, 0.81)):
        for index, (point, tangent) in enumerate(samples[:-1]):
            if (index + course) % 2 and index < len(samples) - 2:
                point = point.lerp(samples[index + 1][0], 0.42)
            progress = index / max(1, len(samples) - 2)
            taper = 1.0 - (0.42 * max(0.0, (progress - 0.72) / 0.28) if taper_end else 0.0)
            heading = math.atan2(tangent.y, tangent.x)
            length = 0.66 + random.uniform(-0.08, 0.10)
            depth = (0.76 - course * 0.08) * taper
            height = (0.34 - course * 0.025) * taper
            cube("Hand-set irregular wall stone", (point.x, point.y, z * taper), (length, depth, height), stone, owner, heading + random.uniform(-0.035, 0.035), random.uniform(0.035, 0.065))
    for index, (point, tangent) in enumerate(samples[::2]):
        progress = (index * 2) / max(1, len(samples) - 1)
        taper = 1.0 - (0.42 * max(0.0, (progress - 0.72) / 0.28) if taper_end else 0.0)
        heading = math.atan2(tangent.y, tangent.x)
        cube("Broad uneven capstone", (point.x, point.y, 1.08 * taper), (1.34, 0.82 * taper, 0.25 * taper), stone, owner, heading + random.uniform(-0.04, 0.04), 0.065)
        if index % 4 == 1:
            normal = Vector((-tangent.y, tangent.x))
            cube("Soft moss pocket", (point.x + normal.x * 0.42, point.y + normal.y * 0.42, 0.72), (0.32, 0.05, 0.12), moss, owner, heading, 0.025)


def wall_asset(filename, name, path, seed, gate=False, taper_end=False):
    reset()
    owner = root(name)
    stone = painted("Painted Cotswold drystone", TEXTURES / "painted_drystone.png", (0.82, 0.82))
    moss = flat("Warm wall moss", (0.34, 0.43, 0.13))
    timber = painted("Painted field gate timber", SHED_TEXTURES / "painted_timber.png", (1.4, 1.2))
    if gate:
        wall_body(owner, [(-7.0, 0.0), (-2.55, 0.0)], stone, moss, seed, taper_end=True)
        wall_body(owner, [(2.55, 0.0), (7.0, 0.0)], stone, moss, seed + 30, taper_end=True)
        for x in (-2.25, 2.25):
            cube("Tall stone gate pier", (x, 0, 0.76), (0.72, 0.82, 1.52), stone, owner, edge=0.08)
        pivot = root("GatePivot")
        pivot.location = (-2.0, 0, 0)
        pivot.parent = owner
        for z in (0.44, 1.0):
            rail = cube("Gate rail", (2.0, 0, z), (4.0, 0.16, 0.18), timber, pivot, edge=0.035)
            rail.location.x -= 2.0
        for x in (0.1, 1.95, 3.8):
            upright = cube("Gate upright", (x, 0, 0.73), (0.16, 0.18, 1.34), timber, pivot, edge=0.035)
            upright.location.x -= 2.0
    else:
        wall_body(owner, path, stone, moss, seed, taper_end)
    join_material_groups(owner)
    export_glb(owner, filename)


def create_oak_base():
    reset()
    owner = root("BrackenOakCourtyardBase")
    soil = flat("Warm mulched earth", (0.30, 0.19, 0.10))
    stone = painted("Painted irregular edging stone", TEXTURES / "painted_drystone.png", (0.9, 0.9))
    grass = flat("Soft verge grass", (0.28, 0.50, 0.17))
    flower = flat("Small buttercup gold", (0.94, 0.67, 0.12))
    random.seed(6204)
    bpy.ops.mesh.primitive_cylinder_add(vertices=18, radius=2.65, depth=0.12, location=(0, 0, 0.04))
    patch = bpy.context.object
    patch.name = "Irregular mulched oak bed"
    for vertex in patch.data.vertices:
        if abs(vertex.co.z) < 0.2:
            vertex.co.x *= 1.0 + 0.08 * math.sin(vertex.co.y * 3.7)
            vertex.co.y *= 1.0 + 0.06 * math.cos(vertex.co.x * 4.1)
    patch.data.materials.append(soil)
    parent(patch, owner)
    for index in range(13):
        angle = math.tau * index / 13 + random.uniform(-0.08, 0.08)
        radius = 2.55 + random.uniform(-0.10, 0.12)
        cube("Irregular oak edging stone", (math.cos(angle) * radius, math.sin(angle) * radius, 0.22 + random.uniform(-0.025, 0.025)), (0.72 + random.uniform(-0.08, 0.10), 0.50 + random.uniform(-0.06, 0.08), 0.38 + random.uniform(-0.04, 0.04)), stone, owner, angle + random.uniform(-0.16, 0.16), 0.09)
    for index in range(18):
        angle = math.tau * index / 18 + 0.13
        radius = 2.9 + (index % 3) * 0.16
        for side in (-1, 1):
            base = (math.cos(angle) * radius, math.sin(angle) * radius, 0.08)
            tip = (base[0] + math.cos(angle + side * 0.48) * 0.20, base[1] + math.sin(angle + side * 0.48) * 0.20, 0.46 + 0.05 * (index % 2))
            branch("Soft grass blade", base, tip, 0.035, grass, owner)
        if index % 4 == 0:
            branch("Flower stem", (base[0], base[1], 0.08), (base[0], base[1], 0.42), 0.025, grass, owner)
            blob("Buttercup", (base[0], base[1], 0.44), (0.10, 0.10, 0.07), flower, owner, 700 + index)
    join_material_groups(owner)
    export_glb(owner, "oak_courtyard_base.glb")


hedge_asset("hawthorn_straight.glb", "HawthornStraight", [(-4.0, 0.0), (4.0, 0.0)], 110)
hedge_asset("hawthorn_curve.glb", "HawthornCurve", [(-4.0, -1.8), (-2.8, -1.65), (-1.4, -1.15), (0.0, -0.25), (1.3, 0.85), (2.6, 1.55), (4.0, 1.8)], 210)
hedge_asset("hawthorn_corner.glb", "HawthornCorner", [(-4.0, 0.0), (-1.6, 0.0), (0.0, 0.2), (0.15, 1.7), (0.15, 4.0)], 310)
hedge_asset("hawthorn_end.glb", "HawthornEnd", [(-4.0, 0.0), (3.2, 0.0)], 410, taper_end=True)
hedge_asset("hawthorn_gate.glb", "HawthornGate", [], 510, gate=True)

wall_asset("drystone_straight.glb", "DrystoneStraight", [(-4.0, 0.0), (4.0, 0.0)], 610)
wall_asset("drystone_curve.glb", "DrystoneCurve", [(-4.0, -1.8), (-2.8, -1.65), (-1.4, -1.15), (0.0, -0.25), (1.3, 0.85), (2.6, 1.55), (4.0, 1.8)], 710)
wall_asset("drystone_corner.glb", "DrystoneCorner", [(-4.0, 0.0), (-1.6, 0.0), (0.0, 0.2), (0.15, 1.7), (0.15, 4.0)], 810)
wall_asset("drystone_end.glb", "DrystoneEnd", [(-4.0, 0.0), (3.2, 0.0)], 910, taper_end=True)
wall_asset("drystone_gate.glb", "DrystoneGate", [], 1010, gate=True)
create_oak_base()
print("BOUNDARY_KIT_COMPLETE")
