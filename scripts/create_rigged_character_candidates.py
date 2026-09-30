from pathlib import Path
import bpy
import math


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "source_assets/third_party/quaternius/universal_base_characters"
UAL1 = ROOT / "source_assets/third_party/quaternius/universal_animation_library/UAL1_Standard.glb"
UAL2 = ROOT / "source_assets/third_party/quaternius/universal_animation_library_2/UAL2_Standard.glb"
OUT = ROOT / "game/assets/characters/rigged"
OUT.mkdir(parents=True, exist_ok=True)

ANIMATIONS_1 = {
    "Dance_Loop",
    "Idle_Loop",
    "Walk_Loop",
    "Jog_Fwd_Loop",
    "Interact",
    "Driving_Loop",
    "Fixing_Kneeling",
    "PickUp_Table",
    "Sitting_Idle_Loop",
}
ANIMATIONS_2 = {
    "Farm_Harvest",
    "Farm_PlantSeed",
    "Farm_Watering",
    "TreeChopping_Loop",
    "Walk_Carry_Loop",
    "OverhandThrow",
}


def material(name, color, roughness=0.78, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)


def remove_objects(objects):
    for obj in list(objects):
        if obj and obj.name in bpy.data.objects:
            bpy.data.objects.remove(obj, do_unlink=True)


def import_animation_library(path, wanted):
    before_objects = set(bpy.data.objects)
    before_actions = set(bpy.data.actions)
    bpy.ops.import_scene.gltf(filepath=str(path))
    imported_objects = set(bpy.data.objects) - before_objects
    imported_actions = set(bpy.data.actions) - before_actions
    selected = []
    for action in imported_actions:
        if action.name in wanted:
            action.use_fake_user = True
            selected.append(action)
        else:
            bpy.data.actions.remove(action)
    remove_objects(imported_objects)
    return selected


def optimize_imported_materials():
    for mat in bpy.data.materials:
        if not mat.use_nodes:
            continue
        bsdf = mat.node_tree.nodes.get("Principled BSDF")
        if not bsdf:
            continue
        for socket_name in ("Normal", "Roughness", "Metallic"):
            socket = bsdf.inputs.get(socket_name)
            if socket:
                for link in list(socket.links):
                    mat.node_tree.links.remove(link)
        bsdf.inputs["Roughness"].default_value = 0.76
        bsdf.inputs["Metallic"].default_value = 0.0
    for image in bpy.data.images:
        if image.size[0] > 1024 or image.size[1] > 1024:
            image.scale(1024, 1024)


def dominant_bone_names(obj, vertex):
    result = set()
    for item in vertex.groups:
        if item.weight >= 0.12:
            result.add(obj.vertex_groups[item.group].name)
    return result


def clothing_shell(body, name, keep_bones, reject_bones, mat, z_min=-100.0, z_max=100.0, x_max=100.0, thickness=0.008, offset=0.009):
    shell = body.copy()
    shell.data = body.data.copy()
    shell.name = name
    body.users_collection[0].objects.link(shell)
    keep_vertices = set()
    for polygon in shell.data.polygons:
        bones = set()
        for vertex_index in polygon.vertices:
            bones.update(dominant_bone_names(shell, shell.data.vertices[vertex_index]))
        if not bones.intersection(keep_bones):
            continue
        if bones and bones.issubset(reject_bones):
            continue
        world_co = shell.matrix_world @ polygon.center
        if not (z_min <= world_co.z <= z_max and abs(world_co.x) <= x_max):
            continue
        keep_vertices.update(polygon.vertices)
    bpy.context.view_layer.objects.active = shell
    shell.select_set(True)
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.select_all(action="DESELECT")
    bpy.ops.object.mode_set(mode="OBJECT")
    for vertex in shell.data.vertices:
        vertex.select = vertex.index not in keep_vertices
    bpy.ops.object.mode_set(mode="EDIT")
    bpy.ops.mesh.delete(type="VERT")
    bpy.ops.object.mode_set(mode="OBJECT")
    shell.select_set(False)
    shell.data.materials.clear()
    shell.data.materials.append(mat)
    for polygon in shell.data.polygons:
        polygon.material_index = 0
    # The Quaternius GLTF objects retain a 0.01 import scale. Modifier distances
    # are local, so convert the requested metre clearance into mesh-local units.
    local_scale = max(abs(shell.scale.x), abs(shell.scale.y), abs(shell.scale.z), 0.0001)
    displace = shell.modifiers.new("Clothing clearance", "DISPLACE")
    displace.strength = offset / local_scale
    solidify = shell.modifiers.new("Cloth thickness", "SOLIDIFY")
    solidify.thickness = thickness / local_scale
    return shell


def rig_prop_to_bone(armature, bone_name, obj):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    group = obj.vertex_groups.new(name=bone_name)
    group.add(range(len(obj.data.vertices)), 1.0, "REPLACE")
    obj.parent = armature
    obj.matrix_parent_inverse = armature.matrix_world.inverted()
    modifier = obj.modifiers.new("Bone rig", "ARMATURE")
    modifier.object = armature
    obj.select_set(False)
    return obj


def add_flat_cap(armature, color):
    mat = material("Waxed green cap", color)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=10, location=(0, 0.0, 1.735))
    crown = bpy.context.object
    crown.name = "Grower flat cap"
    crown.scale = (0.155, 0.14, 0.075)
    crown.data.materials.append(mat)
    rig_prop_to_bone(armature, "Head", crown)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=8, location=(0, -0.105, 1.705))
    peak = bpy.context.object
    peak.name = "Grower cap peak"
    peak.scale = (0.12, 0.09, 0.018)
    peak.data.materials.append(mat)
    rig_prop_to_bone(armature, "Head", peak)


def add_beanie(armature, color):
    mat = material("Ochre wool beanie", color)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, location=(0, 0.0, 1.74))
    beanie = bpy.context.object
    beanie.name = "Mechanic beanie"
    beanie.scale = (0.125, 0.12, 0.09)
    beanie.data.materials.append(mat)
    rig_prop_to_bone(armature, "Head", beanie)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=(0, 0.0, 1.84))
    pom = bpy.context.object
    pom.name = "Mechanic beanie pom"
    pom.scale = (0.038, 0.038, 0.038)
    pom.data.materials.append(mat)
    rig_prop_to_bone(armature, "Head", pom)


def add_milo_hat(armature):
    yellow = material("Milo sunny hat", (0.88, 0.48, 0.045), 0.82)
    cream = material("Milo daisy petals", (0.96, 0.83, 0.55), 0.88)
    center_mat = material("Milo daisy centre", (0.96, 0.64, 0.08), 0.82)
    bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=0.19, depth=0.026, location=(0, 0, 1.755))
    brim = bpy.context.object
    brim.name = "Milo floppy hat brim"
    brim.scale = (1.0, 0.86, 1.0)
    brim.rotation_euler.y = 0.08
    brim.data.materials.append(yellow)
    rig_prop_to_bone(armature, "Head", brim)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, location=(0, 0.015, 1.79))
    crown = bpy.context.object
    crown.name = "Milo floppy hat crown"
    crown.scale = (0.14, 0.125, 0.09)
    crown.data.materials.append(yellow)
    rig_prop_to_bone(armature, "Head", crown)
    flower_x, flower_y, flower_z = 0.105, -0.125, 1.815
    for index in range(6):
        angle = index * math.tau / 6.0
        bpy.ops.mesh.primitive_uv_sphere_add(
            segments=12,
            ring_count=6,
            location=(flower_x + math.cos(angle) * 0.033, flower_y, flower_z + math.sin(angle) * 0.033),
        )
        petal = bpy.context.object
        petal.name = f"Milo daisy petal {index + 1}"
        petal.scale = (0.028, 0.011, 0.016)
        petal.data.materials.append(cream)
        rig_prop_to_bone(armature, "Head", petal)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=6, location=(flower_x, flower_y - 0.006, flower_z))
    centre = bpy.context.object
    centre.name = "Milo daisy centre"
    centre.scale = (0.023, 0.012, 0.023)
    centre.data.materials.append(center_mat)
    rig_prop_to_bone(armature, "Head", centre)


def add_milo_face(armature):
    frames = material("Milo teal glasses", (0.025, 0.18, 0.20), 0.58, 0.08)
    nose_mat = material("Milo rosy nose", (0.80, 0.25, 0.14), 0.82)
    moustache_mat = material("Milo ginger moustache", (0.34, 0.075, 0.018), 0.92)
    for side in (-1, 1):
        bpy.ops.mesh.primitive_torus_add(
            major_radius=0.052,
            minor_radius=0.008,
            major_segments=20,
            minor_segments=8,
            location=(side * 0.056, -0.100, 1.674),
            rotation=(math.pi * 0.5, 0, 0),
        )
        lens = bpy.context.object
        lens.name = "Milo glasses left" if side < 0 else "Milo glasses right"
        lens.data.materials.append(frames)
        rig_prop_to_bone(armature, "Head", lens)
        bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=(side * 0.038, -0.116, 1.615))
        curl = bpy.context.object
        curl.name = "Milo moustache curl"
        curl.scale = (0.058, 0.017, 0.023)
        curl.rotation_euler.z = side * 0.28
        curl.data.materials.append(moustache_mat)
        rig_prop_to_bone(armature, "Head", curl)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, -0.098, 1.674))
    bridge = bpy.context.object
    bridge.name = "Milo glasses bridge"
    bridge.scale = (0.025, 0.008, 0.007)
    bridge.data.materials.append(frames)
    rig_prop_to_bone(armature, "Head", bridge)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=8, location=(0, -0.125, 1.655))
    nose = bpy.context.object
    nose.name = "Milo round nose"
    nose.scale = (0.040, 0.035, 0.040)
    nose.data.materials.append(nose_mat)
    rig_prop_to_bone(armature, "Head", nose)


def add_tool_pouch(armature, side, color):
    mat = material("Leather tool pouch", color)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(side * 0.19, -0.085, 0.91))
    pouch = bpy.context.object
    pouch.name = "Tool pouch"
    pouch.scale = (0.075, 0.04, 0.105)
    pouch.data.materials.append(mat)
    pouch.rotation_euler = (0.05, 0, side * 0.08)
    rig_prop_to_bone(armature, "pelvis", pouch)


def closest_point_on_bone(point, head, tail):
    axis = tail - head
    length_squared = axis.length_squared
    if length_squared <= 0.000001:
        return head
    amount = max(0.0, min(1.0, (point - head).dot(axis) / length_squared))
    return head + axis * amount


def naturalize_body_geometry(body, armature, role):
    """Remove the source superhero musculature while preserving the shared skeleton."""
    region_factors = {
        "Grower": {
            "spine_01": 0.76, "spine_02": 0.74, "spine_03": 0.76,
            "clavicle_l": 0.82, "clavicle_r": 0.82,
            "upperarm_l": 0.66, "upperarm_r": 0.66,
            "lowerarm_l": 0.76, "lowerarm_r": 0.76,
            "thigh_l": 0.82, "thigh_r": 0.82,
            "calf_l": 0.84, "calf_r": 0.84,
        },
        "Mechanic": {
            "spine_01": 0.88, "spine_02": 0.86, "spine_03": 0.88,
            "clavicle_l": 0.90, "clavicle_r": 0.90,
            "upperarm_l": 0.80, "upperarm_r": 0.80,
            "lowerarm_l": 0.86, "lowerarm_r": 0.86,
            "thigh_l": 0.92, "thigh_r": 0.92,
            "calf_l": 0.92, "calf_r": 0.92,
        },
        "Milo": {
            "spine_01": 0.82, "spine_02": 0.78, "spine_03": 0.80,
            "clavicle_l": 0.84, "clavicle_r": 0.84,
            "upperarm_l": 0.70, "upperarm_r": 0.70,
            "lowerarm_l": 0.80, "lowerarm_r": 0.80,
            "thigh_l": 0.86, "thigh_r": 0.86,
            "calf_l": 0.88, "calf_r": 0.88,
        },
    }[role]
    body_inverse = body.matrix_world.inverted()
    armature_world = armature.matrix_world
    for vertex in body.data.vertices:
        weighted_regions = []
        for membership in vertex.groups:
            group_name = body.vertex_groups[membership.group].name
            if group_name in region_factors and membership.weight >= 0.12:
                weighted_regions.append((membership.weight, group_name))
        if not weighted_regions:
            continue
        weight, group_name = max(weighted_regions)
        bone = armature.data.bones.get(group_name)
        if not bone:
            continue
        point = body.matrix_world @ vertex.co
        head = armature_world @ bone.head_local
        tail = armature_world @ bone.tail_local
        centre = closest_point_on_bone(point, head, tail)
        factor = 1.0 - (1.0 - region_factors[group_name]) * min(1.0, weight * 1.35)
        reshaped = centre + (point - centre) * factor

        # Milo has an ordinary soft middle. Keep it subtle and forward-facing;
        # this replaces bodybuilder definition rather than making him spherical.
        if role == "Milo" and 0.78 <= point.z <= 1.18 and point.y < 0.02:
            height_falloff = 1.0 - abs(point.z - 0.98) / 0.20
            side_falloff = max(0.0, 1.0 - abs(point.x) / 0.30)
            reshaped.y -= 0.035 * max(0.0, height_falloff) * side_falloff
        vertex.co = body_inverse @ reshaped


def add_natural_body_root(role):
    """Give each candidate a believable working build without changing the shared rig."""
    proportions = {
        # Tall and wiry: years of outdoor work, without the superhero shoulder width.
        "Grower": (0.78, 0.84, 1.04),
        # Medium, practical build with enough weight for the overalls to read clearly.
        "Mechanic": (0.90, 0.94, 1.00),
        # Shorter comic character; humour comes from styling rather than a swollen torso.
        "Milo": (0.82, 0.88, 0.94),
    }
    bpy.ops.object.empty_add(type="PLAIN_AXES", location=(0, 0, 0))
    root = bpy.context.object
    root.name = f"{role} natural working build"
    for obj in list(bpy.context.scene.objects):
        if obj == root or obj.parent is not None:
            continue
        world = obj.matrix_world.copy()
        obj.parent = root
        obj.matrix_world = world
    root.scale = proportions[role]
    return root


def prepare_character(role, source_file):
    clear_scene()
    selected_actions = []
    selected_actions.extend(import_animation_library(UAL1, ANIMATIONS_1))
    selected_actions.extend(import_animation_library(UAL2, ANIMATIONS_2))
    bpy.ops.import_scene.gltf(filepath=str(source_file))
    optimize_imported_materials()
    armature = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
    body = max(
        (
            obj
            for obj in bpy.context.scene.objects
            if obj.type == "MESH" and any(mod.type == "ARMATURE" for mod in obj.modifiers)
        ),
        key=lambda obj: len(obj.data.vertices),
    )
    for obj in list(bpy.context.scene.objects):
        if obj.type == "MESH" and obj.name.startswith("Icosphere"):
            bpy.data.objects.remove(obj, do_unlink=True)
    armature.name = f"{role}Rig"
    body.name = f"{role}Body"
    armature.animation_data_create()
    # Keep the rig in its bind pose while exporting. Blender's glTF exporter omits
    # an action from ACTIONS mode when that same action is also active on the rig.
    # The runtime selects Idle explicitly after Godot imports the animation set.
    armature.animation_data.action = None

    upper = {"spine_01", "spine_02", "spine_03", "clavicle_l", "clavicle_r", "upperarm_l", "upperarm_r", "lowerarm_l", "lowerarm_r"}
    hands_head = {"hand_l", "hand_r", "neck_01", "Head", "index_01_l", "index_01_r", "thumb_01_l", "thumb_01_r"}
    lower = {"pelvis", "thigh_l", "thigh_r", "calf_l", "calf_r"}
    feet = {"foot_l", "foot_r", "ball_l", "ball_r"}

    naturalize_body_geometry(body, armature, role)

    if role == "Grower":
        jacket = material("Grower wax jacket", (0.24, 0.045, 0.012), 0.82)
        trousers = material("Grower work trousers", (0.20, 0.30, 0.17), 0.86)
        boots = material("Grower leather boots", (0.16, 0.075, 0.035), 0.9)
        clothing_shell(body, "Wax jacket", upper, hands_head, jacket, z_min=0.82, z_max=1.53, x_max=0.82, thickness=0.012, offset=0.012)
        clothing_shell(body, "Work trousers", lower, upper.union(feet), trousers, z_min=0.24, z_max=0.97, thickness=0.011, offset=0.011)
        clothing_shell(body, "Leather boots", feet.union({"calf_l", "calf_r"}), upper, boots, z_min=-0.03, z_max=0.33, thickness=0.014, offset=0.014)
        add_flat_cap(armature, (0.22, 0.34, 0.19))
        add_tool_pouch(armature, 1, (0.30, 0.13, 0.055))
    elif role == "Mechanic":
        shirt = material("Mechanic cream shirt", (0.78, 0.68, 0.48), 0.88)
        overalls = material("Mechanic blue overalls", (0.08, 0.25, 0.40), 0.78)
        boots = material("Mechanic work boots", (0.13, 0.08, 0.05), 0.9)
        clothing_shell(body, "Cream work shirt", upper, hands_head, shirt, z_min=0.82, z_max=1.52, x_max=0.82, thickness=0.010, offset=0.010)
        clothing_shell(body, "Blue overalls", lower.union({"spine_01", "spine_02"}), upper.difference({"spine_01", "spine_02"}).union(feet), overalls, z_min=0.25, z_max=1.31, x_max=0.38, thickness=0.013, offset=0.016)
        clothing_shell(body, "Mechanic boots", feet.union({"calf_l", "calf_r"}), upper, boots, z_min=-0.03, z_max=0.34, thickness=0.014, offset=0.014)
        add_beanie(armature, (0.82, 0.50, 0.08))
        add_tool_pouch(armature, -1, (0.34, 0.15, 0.05))
    else:
        shirt = material("Milo mustard shirt", (0.76, 0.35, 0.035), 0.86)
        overalls = material("Milo teal overalls", (0.035, 0.34, 0.38), 0.78)
        boots = material("Milo cherry boots", (0.48, 0.055, 0.025), 0.88)
        clothing_shell(body, "Milo mustard shirt", upper, hands_head, shirt, z_min=0.82, z_max=1.52, x_max=0.82, thickness=0.012, offset=0.012)
        clothing_shell(body, "Milo teal overalls", lower.union({"spine_01", "spine_02"}), upper.difference({"spine_01", "spine_02"}).union(feet), overalls, z_min=0.25, z_max=1.31, x_max=0.40, thickness=0.014, offset=0.017)
        clothing_shell(body, "Milo cherry boots", feet.union({"calf_l", "calf_r"}), upper, boots, z_min=-0.03, z_max=0.36, thickness=0.016, offset=0.016)
        add_milo_hat(armature)
        add_milo_face(armature)
        add_tool_pouch(armature, 1, (0.37, 0.14, 0.035))

    add_natural_body_root(role)

    # Retain only the review/gameplay actions in this exported candidate.
    selected_names = {action.name for action in selected_actions}
    for action in list(bpy.data.actions):
        if action.name not in selected_names:
            bpy.data.actions.remove(action)
        else:
            action.use_fake_user = True

    bpy.ops.object.select_all(action="SELECT")
    output = OUT / f"bracken_{role.lower()}_rigged.glb"
    bpy.ops.export_scene.gltf(
        filepath=str(output),
        export_format="GLB",
        use_selection=True,
        export_yup=True,
        export_apply=True,
        export_animations=True,
        export_animation_mode="ACTIONS",
        export_extra_animations=True,
        export_action_filter=True,
        export_optimize_animation_size=True,
    )
    print(f"EXPORTED {output}")


for role, filename in [
    ("Grower", "Superhero_Male_FullBody.gltf"),
    ("Mechanic", "Superhero_Female_FullBody.gltf"),
    ("Milo", "Superhero_Male_FullBody.gltf"),
]:
    prepare_character(role, BASE / filename)
