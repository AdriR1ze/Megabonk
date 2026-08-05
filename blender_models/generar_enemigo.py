"""
SCRIPT DE BLENDER - MODELO DEL ENEMIGO
Criatura robótica oscura con ojos brillantes y cuerpo agresivo
"""
import bpy
import math
import os

OUTPUT_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk\Assets\Models\enemigo.glb"

bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

def make_mat(name, color, metallic=0.0, roughness=0.5, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 5.0
    if obj_ref[0].data.materials:
        obj_ref[0].data.materials[0] = mat
    else:
        obj_ref[0].data.materials.append(mat)

objects = []

def add_mat(obj, name, color, metallic=0.0, roughness=0.5, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 8.0
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)

# === CUERPO PRINCIPAL (esfera achatada) ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0, 0, 0.55), segments=20, ring_count=14)
body = bpy.context.object
body.name = "Cuerpo"
body.scale = (1.0, 0.8, 0.85)
bpy.ops.object.transform_apply(scale=True)
add_mat(body, "CuerpoMat", (0.08, 0.05, 0.05), metallic=0.3, roughness=0.4)
objects.append(body)

# === CABEZA (esfera más pequeña) ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.32, location=(0, 0, 1.08), segments=16, ring_count=10)
head = bpy.context.object
head.name = "Cabeza"
head.scale = (1.0, 0.85, 0.95)
bpy.ops.object.transform_apply(scale=True)
add_mat(head, "CabezaEnemMat", (0.06, 0.04, 0.04), metallic=0.4, roughness=0.35)
objects.append(head)

# === OJO DERECHO (brillante, rojo) ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.07, location=(0.13, 0.27, 1.12), segments=10, ring_count=8)
eye_r = bpy.context.object
eye_r.name = "OjoD"
add_mat(eye_r, "OjoMat", (1.0, 0.1, 0.0), emission=(1.0, 0.1, 0.0))
objects.append(eye_r)

# === OJO IZQUIERDO ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.07, location=(-0.13, 0.27, 1.12), segments=10, ring_count=8)
eye_l = bpy.context.object
eye_l.name = "OjoI"
add_mat(eye_l, "OjoMat2", (1.0, 0.1, 0.0), emission=(1.0, 0.1, 0.0))
objects.append(eye_l)

# === HOMBRO DERECHO ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(0.52, 0, 0.7), segments=12, ring_count=8)
shldr_r = bpy.context.object
shldr_r.name = "HombroD"
shldr_r.scale = (1.0, 0.8, 0.9)
bpy.ops.object.transform_apply(scale=True)
add_mat(shldr_r, "HombroMat", (0.1, 0.06, 0.06), metallic=0.5, roughness=0.3)
objects.append(shldr_r)

# === HOMBRO IZQUIERDO ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(-0.52, 0, 0.7), segments=12, ring_count=8)
shldr_l = bpy.context.object
shldr_l.name = "HombroI"
shldr_l.scale = (1.0, 0.8, 0.9)
bpy.ops.object.transform_apply(scale=True)
add_mat(shldr_l, "HombroMat", (0.1, 0.06, 0.06), metallic=0.5, roughness=0.3)
objects.append(shldr_l)

# === BRAZO DERECHO (cilindro diagonal) ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.45, location=(0.72, 0, 0.45))
arm_r = bpy.context.object
arm_r.name = "BrazoD"
arm_r.rotation_euler = (0, math.radians(25), 0)
add_mat(arm_r, "BrazoEnemMat", (0.08, 0.05, 0.05), metallic=0.3, roughness=0.5)
objects.append(arm_r)

# === BRAZO IZQUIERDO ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.45, location=(-0.72, 0, 0.45))
arm_l = bpy.context.object
arm_l.name = "BrazoI"
arm_l.rotation_euler = (0, math.radians(-25), 0)
add_mat(arm_l, "BrazoEnemMat", (0.08, 0.05, 0.05), metallic=0.3, roughness=0.5)
objects.append(arm_l)

# === GARRA DERECHA (cono) ===
bpy.ops.mesh.primitive_cone_add(radius1=0.12, radius2=0.01, depth=0.3, location=(0.9, 0, 0.22))
claw_r = bpy.context.object
claw_r.name = "GarraD"
claw_r.rotation_euler = (0, math.radians(80), 0)
add_mat(claw_r, "GarraMat", (0.15, 0.0, 0.0), metallic=0.8, roughness=0.2)
objects.append(claw_r)

# === GARRA IZQUIERDA ===
bpy.ops.mesh.primitive_cone_add(radius1=0.12, radius2=0.01, depth=0.3, location=(-0.9, 0, 0.22))
claw_l = bpy.context.object
claw_l.name = "GarraI"
claw_l.rotation_euler = (0, math.radians(-80), 0)
add_mat(claw_l, "GarraMat2", (0.15, 0.0, 0.0), metallic=0.8, roughness=0.2)
objects.append(claw_l)

# === PATA DERECHA ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.4, location=(0.22, 0, 0.16))
leg_r = bpy.context.object
leg_r.name = "PataD"
add_mat(leg_r, "PataMat", (0.07, 0.04, 0.04), metallic=0.2, roughness=0.6)
objects.append(leg_r)

# === PATA IZQUIERDA ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.4, location=(-0.22, 0, 0.16))
leg_l = bpy.context.object
leg_l.name = "PataI"
add_mat(leg_l, "PataMat2", (0.07, 0.04, 0.04), metallic=0.2, roughness=0.6)
objects.append(leg_l)

# === PUAS EN LA ESPALDA ===
for i, (x, z_off) in enumerate([(-0.15, 0.0), (0.0, 0.1), (0.15, 0.0)]):
    bpy.ops.mesh.primitive_cone_add(radius1=0.06, radius2=0.01, depth=0.28,
                                     location=(x, -0.38, 0.75 + z_off))
    spike = bpy.context.object
    spike.name = f"Pua{i}"
    spike.rotation_euler = (math.radians(-40), 0, 0)
    add_mat(spike, f"PuaMat{i}", (0.18, 0.0, 0.0), metallic=0.7, roughness=0.2)
    objects.append(spike)

# Unir todo
bpy.ops.object.select_all(action='DESELECT')
for obj in objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = body
bpy.ops.object.join()

enemigo_final = bpy.context.object
enemigo_final.name = "Enemigo"

os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
bpy.ops.object.select_all(action='DESELECT')
enemigo_final.select_set(True)
bpy.ops.export_scene.gltf(filepath=OUTPUT_PATH, use_selection=True, export_format='GLB')
print(f"✅ Enemigo exportado a: {OUTPUT_PATH}")
