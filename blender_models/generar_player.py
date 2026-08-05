"""
SCRIPT DE BLENDER - MODELO DEL PLAYER
Cómo usar:
1. Abrí Blender
2. Ir a Scripting (tab arriba)
3. Pegar este script y presionar "Run Script"
4. El modelo se exporta automáticamente a tu proyecto Megabonk
"""
import bpy
import math
import os

OUTPUT_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk\Assets\Models\player.glb"

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

def set_material(obj, name, color, metallic=0.0, roughness=0.5):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)
    return mat

objects = []

# === TORSO ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.75))
torso = bpy.context.object
torso.name = "Torso"
torso.scale = (0.55, 0.35, 0.55)
bpy.ops.object.transform_apply(scale=True)
# Bevel para redondear
bpy.ops.object.modifier_add(type='BEVEL')
torso.modifiers["Bevel"].width = 0.05
torso.modifiers["Bevel"].segments = 3
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(torso, "TorsoMat", (0.18, 0.45, 0.18), metallic=0.1, roughness=0.6)
objects.append(torso)

# === CABEZA ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0, 0, 1.35), segments=16, ring_count=12)
head = bpy.context.object
head.name = "Cabeza"
head.scale = (1.0, 0.9, 1.05)
bpy.ops.object.transform_apply(scale=True)
set_material(head, "CabezaMat", (0.18, 0.45, 0.18), metallic=0.1, roughness=0.5)
objects.append(head)

# === CASCO (esfera achatada encima) ===
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.25, location=(0, 0, 1.47), segments=16, ring_count=8)
helmet = bpy.context.object
helmet.name = "Casco"
helmet.scale = (1.0, 0.9, 0.55)
bpy.ops.object.transform_apply(scale=True)
set_material(helmet, "CascoMat", (0.08, 0.22, 0.08), metallic=0.3, roughness=0.4)
objects.append(helmet)

# === VISERA (caja chata frente a la cabeza) ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.19, 1.34))
visor = bpy.context.object
visor.name = "Visera"
visor.scale = (0.3, 0.04, 0.1)
bpy.ops.object.transform_apply(scale=True)
set_material(visor, "ViseraMat", (0.05, 0.9, 0.85), metallic=0.0, roughness=0.05)
objects.append(visor)

# === BRAZO DERECHO ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.55, location=(0.37, 0, 0.76))
arm_r = bpy.context.object
arm_r.name = "BrazoD"
arm_r.rotation_euler = (0, math.radians(15), 0)
set_material(arm_r, "BrazoMat", (0.18, 0.45, 0.18), metallic=0.1, roughness=0.55)
objects.append(arm_r)

# === BRAZO IZQUIERDO ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.55, location=(-0.37, 0, 0.76))
arm_l = bpy.context.object
arm_l.name = "BrazoI"
arm_l.rotation_euler = (0, math.radians(-15), 0)
set_material(arm_l, "BrazoMat", (0.18, 0.45, 0.18), metallic=0.1, roughness=0.55)
objects.append(arm_l)

# === PIERNA DERECHA ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.6, location=(0.18, 0, 0.18))
leg_r = bpy.context.object
leg_r.name = "PiernaD"
set_material(leg_r, "PiernaMat", (0.12, 0.30, 0.12), metallic=0.05, roughness=0.7)
objects.append(leg_r)

# === PIERNA IZQUIERDA ===
bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.6, location=(-0.18, 0, 0.18))
leg_l = bpy.context.object
leg_l.name = "PiernaI"
set_material(leg_l, "PiernaMat", (0.12, 0.30, 0.12), metallic=0.05, roughness=0.7)
objects.append(leg_l)

# === BOTA DERECHA ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.18, 0.03, -0.13))
boot_r = bpy.context.object
boot_r.name = "BotaD"
boot_r.scale = (0.14, 0.18, 0.09)
bpy.ops.object.transform_apply(scale=True)
set_material(boot_r, "BotaMat", (0.06, 0.06, 0.06), metallic=0.4, roughness=0.5)
objects.append(boot_r)

# === BOTA IZQUIERDA ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.18, 0.03, -0.13))
boot_l = bpy.context.object
boot_l.name = "BotaI"
boot_l.scale = (0.14, 0.18, 0.09)
bpy.ops.object.transform_apply(scale=True)
set_material(boot_l, "BotaMat", (0.06, 0.06, 0.06), metallic=0.4, roughness=0.5)
objects.append(boot_l)

# === PECHERA (placa delantera) ===
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.22, 0.78))
chest = bpy.context.object
chest.name = "Pechera"
chest.scale = (0.4, 0.04, 0.35)
bpy.ops.object.transform_apply(scale=True)
set_material(chest, "PecheraMat", (0.08, 0.35, 0.08), metallic=0.5, roughness=0.3)
objects.append(chest)

# Seleccionar todos y unir
bpy.ops.object.select_all(action='DESELECT')
for obj in objects:
    obj.select_set(True)
bpy.context.view_layer.objects.active = torso
bpy.ops.object.join()

player_final = bpy.context.object
player_final.name = "Player"

# Exportar
os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
bpy.ops.object.select_all(action='DESELECT')
player_final.select_set(True)
bpy.ops.export_scene.gltf(
    filepath=OUTPUT_PATH,
    use_selection=True,
    export_format='GLB'
)
print(f"✅ Player exportado a: {OUTPUT_PATH}")
