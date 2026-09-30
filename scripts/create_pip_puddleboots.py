from pathlib import Path
import math

import bpy
from mathutils import Vector


ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "source_assets/third_party/quaternius/universal_base_characters/Superhero_Male_FullBody.gltf"
UAL1 = ROOT / "source_assets/third_party/quaternius/universal_animation_library/UAL1_Standard.glb"
UAL2 = ROOT / "source_assets/third_party/quaternius/universal_animation_library_2/UAL2_Standard.glb"
OUT = ROOT / "game/assets/characters/rigged/bracken_pip_puddleboots.glb"

ANIMATIONS_1 = {
    "Dance_Loop", "Idle_Loop", "Walk_Loop", "Jog_Fwd_Loop", "Interact",
    "Driving_Loop", "Fixing_Kneeling", "PickUp_Table", "Sitting_Idle_Loop",
}
ANIMATIONS_2 = {"Farm_Harvest", "Farm_PlantSeed", "Farm_Watering", "Walk_Carry_Loop", "OverhandThrow"}


def material(name, color, roughness=0.82, metallic=0.0):
    mat = bpy.data.materials.new(name)
    mat.diffuse_color = (*color, 1.0)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = roughness
    bsdf.inputs["Metallic"].default_value = metallic
    return mat


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
    for obj in imported_objects:
        if obj and obj.name in bpy.data.objects:
            bpy.data.objects.remove(obj, do_unlink=True)
    return selected


def rig_to_bone(armature, bone_name, obj):
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
    group = obj.vertex_groups.new(name=bone_name)
    group.add(range(len(obj.data.vertices)), 1.0, "REPLACE")
    obj.parent = armature
    obj.matrix_parent_inverse = armature.matrix_world.inverted()
    modifier = obj.modifiers.new("Pip bone rig", "ARMATURE")
    modifier.object = armature
    obj.select_set(False)
    return obj


def smooth_object(obj):
    for polygon in obj.data.polygons:
        polygon.use_smooth = True
    return obj


def ellipsoid(armature, bone, name, location, scale, mat, segments=20, rings=12):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=segments, ring_count=rings, location=location)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    smooth_object(obj)
    return rig_to_bone(armature, bone, obj)


def rounded_box(armature, bone, name, location, scale, mat, bevel=0.08, rotation=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=location, rotation=rotation)
    obj = bpy.context.object
    obj.name = name
    obj.scale = scale
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.transform_apply(location=False, rotation=False, scale=True)
    modifier = obj.modifiers.new("Soft storybook edges", "BEVEL")
    modifier.width = bevel
    modifier.segments = 3
    bpy.ops.object.modifier_apply(modifier=modifier.name)
    smooth_object(obj)
    return rig_to_bone(armature, bone, obj)


def bone_capsule(armature, bone_name, name, radius, mat, shorten=0.90, depth_scale=1.0):
    bone = armature.data.bones[bone_name]
    head = armature.matrix_world @ bone.head_local
    tail = armature.matrix_world @ bone.tail_local
    axis = tail - head
    midpoint = (head + tail) * 0.5
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, location=midpoint)
    obj = bpy.context.object
    obj.name = name
    obj.rotation_mode = "QUATERNION"
    obj.rotation_quaternion = Vector((0, 0, 1)).rotation_difference(axis.normalized())
    obj.scale = (radius, radius * depth_scale, max(radius, axis.length * 0.5 * shorten))
    obj.data.materials.append(mat)
    smooth_object(obj)
    return rig_to_bone(armature, bone_name, obj)


def tapered_raincoat(armature, mat):
    rings = [
        (0.76, 0.31, 0.22),
        (0.91, 0.30, 0.21),
        (1.18, 0.25, 0.19),
        (1.43, 0.22, 0.17),
    ]
    vertices = []
    segments = 20
    for z, rx, ry in rings:
        for index in range(segments):
            angle = math.tau * index / segments
            # The front hangs slightly farther forward like a real loose coat.
            y = math.sin(angle) * ry
            if y < 0:
                y *= 1.10
            vertices.append((math.cos(angle) * rx, y, z))
    faces = []
    for ring in range(len(rings) - 1):
        for index in range(segments):
            nxt = (index + 1) % segments
            a = ring * segments + index
            b = ring * segments + nxt
            c = (ring + 1) * segments + nxt
            d = (ring + 1) * segments + index
            faces.append((a, b, c, d))
    faces.append(tuple(reversed(range(segments))))
    top = (len(rings) - 1) * segments
    faces.append(tuple(top + i for i in range(segments)))
    mesh = bpy.data.meshes.new("Pip loose raincoat mesh")
    mesh.from_pydata(vertices, [], faces)
    mesh.materials.append(mat)
    coat = bpy.data.objects.new("Pip loose yellow raincoat", mesh)
    bpy.context.collection.objects.link(coat)
    bevel = coat.modifiers.new("Raincoat softened seams", "BEVEL")
    bevel.width = 0.025
    bevel.segments = 2
    smooth_object(coat)
    return rig_to_bone(armature, "spine_02", coat)


def smile_curve(armature, mat):
    curve = bpy.data.curves.new("Pip smile curve", "CURVE")
    curve.dimensions = "3D"
    curve.bevel_depth = 0.009
    curve.bevel_resolution = 3
    spline = curve.splines.new("BEZIER")
    spline.bezier_points.add(2)
    points = [(-0.045, -0.188, 1.625), (0.0, -0.198, 1.605), (0.045, -0.188, 1.625)]
    for point, co in zip(spline.bezier_points, points):
        point.co = co
        point.handle_left_type = "AUTO"
        point.handle_right_type = "AUTO"
    obj = bpy.data.objects.new("Pip broad smile", curve)
    bpy.context.collection.objects.link(obj)
    obj.data.materials.append(mat)
    bpy.context.view_layer.objects.active = obj
    obj.select_set(True)
    bpy.ops.object.convert(target="MESH")
    return rig_to_bone(armature, "Head", bpy.context.object)


def build_pip(armature):
    skin = material("Pip warm skin", (0.78, 0.39, 0.20), 0.88)
    skin_light = material("Pip rosy cheeks", (0.96, 0.43, 0.28), 0.84)
    coat = material("Pip buttercup raincoat", (0.96, 0.58, 0.055), 0.78)
    coat_shadow = material("Pip raincoat lining", (0.28, 0.48, 0.36), 0.84)
    trousers = material("Pip patched trousers", (0.10, 0.37, 0.41), 0.88)
    boots = material("Pip cherry wellingtons", (0.67, 0.055, 0.025), 0.75)
    scarf = material("Pip berry scarf", (0.56, 0.04, 0.08), 0.82)
    hair = material("Pip chestnut hair", (0.24, 0.065, 0.018), 0.92)
    eye_white = material("Pip eye white", (0.98, 0.91, 0.75), 0.74)
    iris = material("Pip green eyes", (0.055, 0.23, 0.14), 0.68)
    dark = material("Pip face line", (0.10, 0.025, 0.012), 0.90)
    patch = material("Pip blue patch", (0.10, 0.32, 0.58), 0.86)

    tapered_raincoat(armature, coat)
    for side in ("l", "r"):
        bone_capsule(armature, f"upperarm_{side}", f"Pip raincoat upper sleeve {side}", 0.085, coat, 0.96, 0.92)
        bone_capsule(armature, f"lowerarm_{side}", f"Pip raincoat lower sleeve {side}", 0.072, coat, 0.94, 0.92)
        bone_capsule(armature, f"thigh_{side}", f"Pip trouser thigh {side}", 0.095, trousers, 0.96, 0.92)
        bone_capsule(armature, f"calf_{side}", f"Pip trouser calf {side}", 0.078, trousers, 0.91, 0.90)
        hand_bone = f"hand_{side}"
        hand = armature.matrix_world @ armature.data.bones[hand_bone].head_local
        ellipsoid(armature, hand_bone, f"Pip mitten hand {side}", hand, (0.058, 0.050, 0.065), skin)

    # Large head and readable face: these replace the source mesh completely.
    ellipsoid(armature, "Head", "Pip large rounded head", (0, -0.010, 1.67), (0.165, 0.150, 0.195), skin, 24, 16)
    for side in (-1, 1):
        ellipsoid(armature, "Head", "Pip ear", (side * 0.158, -0.005, 1.67), (0.034, 0.022, 0.047), skin)
        ellipsoid(armature, "Head", "Pip eye white", (side * 0.057, -0.139, 1.695), (0.049, 0.027, 0.061), eye_white, 16, 10)
        ellipsoid(armature, "Head", "Pip iris", (side * 0.057, -0.165, 1.690), (0.022, 0.010, 0.032), iris, 14, 8)
        ellipsoid(armature, "Head", "Pip pupil", (side * 0.057, -0.174, 1.688), (0.009, 0.006, 0.015), dark, 12, 6)
        ellipsoid(armature, "Head", "Pip rosy cheek", (side * 0.091, -0.139, 1.625), (0.032, 0.010, 0.022), skin_light, 12, 6)
        for freckle in (-0.016, 0.0, 0.016):
            ellipsoid(armature, "Head", "Pip freckle", (side * 0.083 + freckle, -0.151, 1.637), (0.004, 0.004, 0.004), dark, 8, 4)
        rounded_box(armature, "Head", "Pip eyebrow", (side * 0.058, -0.165, 1.761), (0.047, 0.008, 0.009), hair, 0.006, (0, 0, side * -0.12))
    ellipsoid(armature, "Head", "Pip button nose", (0, -0.174, 1.651), (0.035, 0.031, 0.040), skin_light, 16, 8)
    smile_curve(armature, dark)

    # Three soft hair tufts and a cap that sits crooked enough to read in silhouette.
    for side in (-0.055, 0.0, 0.055):
        ellipsoid(armature, "Head", "Pip hair tuft", (side, -0.020, 1.847), (0.042, 0.050, 0.066), hair, 14, 8)
    cap = material("Pip moss cap", (0.20, 0.43, 0.22), 0.88)
    ellipsoid(armature, "Head", "Pip floppy cap crown", (0.018, 0.008, 1.842), (0.145, 0.125, 0.058), cap, 20, 10)
    ellipsoid(armature, "Head", "Pip cap peak", (0.018, -0.142, 1.812), (0.105, 0.070, 0.016), cap, 18, 6)

    # Collar, scarf knot, pocket and oversized boots provide the gameplay-scale silhouette.
    bpy.ops.mesh.primitive_torus_add(major_radius=0.165, minor_radius=0.027, major_segments=20, minor_segments=8, location=(0, 0, 1.43))
    collar = bpy.context.object
    collar.name = "Pip red scarf"
    collar.data.materials.append(scarf)
    rig_to_bone(armature, "spine_03", collar)
    ellipsoid(armature, "spine_03", "Pip scarf knot", (0.10, -0.185, 1.39), (0.045, 0.032, 0.052), scarf)
    rounded_box(armature, "spine_02", "Pip raincoat pocket", (0.115, -0.224, 1.02), (0.105, 0.030, 0.090), coat_shadow, 0.025)
    rounded_box(armature, "spine_02", "Pip pocket patch", (0.115, -0.258, 1.02), (0.048, 0.008, 0.042), patch, 0.012, (0, 0, -0.08))
    for side, x in (("l", -0.10), ("r", 0.10)):
        foot_bone = f"foot_{side}"
        rounded_box(armature, foot_bone, f"Pip oversized boot {side}", (x, -0.055, 0.11), (0.090, 0.155, 0.120), boots, 0.050)
        rounded_box(armature, f"calf_{side}", f"Pip boot shaft {side}", (x, 0.0, 0.29), (0.085, 0.090, 0.190), boots, 0.045)


def main():
    bpy.ops.wm.read_factory_settings(use_empty=True)
    selected_actions = []
    selected_actions.extend(import_animation_library(UAL1, ANIMATIONS_1))
    selected_actions.extend(import_animation_library(UAL2, ANIMATIONS_2))
    bpy.ops.import_scene.gltf(filepath=str(BASE))
    armature = next(obj for obj in bpy.context.scene.objects if obj.type == "ARMATURE")
    armature.name = "PipPuddlebootsRig"
    # The downloaded body supplied a compatible skeleton only. No superhero mesh
    # survives into Pip's visible model.
    for obj in list(bpy.context.scene.objects):
        if obj.type == "MESH":
            bpy.data.objects.remove(obj, do_unlink=True)
    armature.animation_data_create()
    armature.animation_data.action = None
    build_pip(armature)
    selected_names = {action.name for action in selected_actions}
    for action in list(bpy.data.actions):
        if action.name not in selected_names:
            bpy.data.actions.remove(action)
        else:
            action.use_fake_user = True
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.export_scene.gltf(
        filepath=str(OUT), export_format="GLB", use_selection=True, export_yup=True,
        export_apply=True, export_animations=True, export_animation_mode="ACTIONS",
        export_extra_animations=True, export_action_filter=True,
        export_optimize_animation_size=True,
    )
    print(f"EXPORTED {OUT}")


main()
