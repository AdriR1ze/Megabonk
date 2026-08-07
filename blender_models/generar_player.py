"""
SCRIPT DE BLENDER - MODELO DEL PLAYER (MEDIEVAL FANTASIA)
Como usar:
1. Abri Blender
2. Ir a Scripting (tab arriba)
3. Pegar este script y presionar "Run Script"
4. El modelo se exporta automaticamente a tu proyecto Megabonk
"""
import bpy
import math
import os

OUTPUT_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk\Assets\Models\player.glb"

# Limpiar escena
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()

def set_material(obj, name, color, metallic=0.0, roughness=0.5, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 3.0
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)
    return mat

objects = []

# --- TORSO (cota de malla / tunica) ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.68))
torso = bpy.context.object
torso.name = "Torso"
torso.scale = (0.5, 0.3, 0.52)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
torso.modifiers["Bevel"].width = 0.04
torso.modifiers["Bevel"].segments = 3
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(torso, "TunicaMat", (0.15, 0.25, 0.35), metallic=0.05, roughness=0.7)
objects.append(torso)

# --- CINTURON ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.42))
belt = bpy.context.object
belt.name = "Cinturon"
belt.scale = (0.55, 0.32, 0.06)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
belt.modifiers["Bevel"].width = 0.02
belt.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(belt, "CinturonMat", (0.35, 0.22, 0.1), metallic=0.3, roughness=0.5)
objects.append(belt)

# --- HEBILLA DEL CINTURON ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.04, location=(0, 0.22, 0.42))
buckle = bpy.context.object
buckle.name = "Hebilla"
buckle.rotation_euler = (math.radians(90), 0, 0)
set_material(buckle, "HebillaMat", (0.85, 0.7, 0.2), metallic=0.95, roughness=0.15)
objects.append(buckle)

# --- CABEZA ---
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.2, location=(0, 0, 1.03), segments=16, ring_count=12)
head = bpy.context.object
head.name = "Cabeza"
head.scale = (1.0, 0.88, 1.0)
bpy.ops.object.transform_apply(scale=True)
set_material(head, "CabezaMat", (0.78, 0.62, 0.48), metallic=0.0, roughness=0.55)
objects.append(head)

# --- YELMO (casco envolvente) ---
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.24, location=(0, 0, 1.08), segments=20, ring_count=14)
helmet = bpy.context.object
helmet.name = "Yelmo"
helmet.scale = (1.05, 0.95, 0.65)
bpy.ops.object.transform_apply(scale=True)
set_material(helmet, "YelmoMat", (0.22, 0.22, 0.25), metallic=0.9, roughness=0.2)
objects.append(helmet)

# --- CRESTA DEL YELMO (pluma) ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 1.35))
crest = bpy.context.object
crest.name = "Cresta"
crest.scale = (0.05, 0.04, 0.2)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
crest.modifiers["Bevel"].width = 0.015
crest.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(crest, "CrestaMat", (0.7, 0.15, 0.15), metallic=0.1, roughness=0.5)
objects.append(crest)

# --- VISERA ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.21, 1.04))
visor = bpy.context.object
visor.name = "Visera"
visor.scale = (0.28, 0.035, 0.09)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
visor.modifiers["Bevel"].width = 0.01
visor.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(visor, "ViseraMat", (0.1, 0.1, 0.12), metallic=0.9, roughness=0.15)
objects.append(visor)

# --- RANURA DE LA VISERA (brillo) ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.24, 1.045))
visor_slit = bpy.context.object
visor_slit.name = "ViseraRanu"
visor_slit.scale = (0.22, 0.01, 0.015)
bpy.ops.object.transform_apply(scale=True)
set_material(visor_slit, "ViseraRanuMat", (0.2, 0.6, 1.0), metallic=0.0, roughness=0.05,
             emission=(0.1, 0.4, 0.9))
objects.append(visor_slit)

# --- PECHERA / CORAZA ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.2, 0.72))
chest = bpy.context.object
chest.name = "Coraza"
chest.scale = (0.42, 0.045, 0.38)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
chest.modifiers["Bevel"].width = 0.03
chest.modifiers["Bevel"].segments = 3
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(chest, "CorazaMat", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(chest)

# --- DETALLE CENTRAL DE LA CORAZA ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.32, location=(0, 0.23, 0.72))
chest_line = bpy.context.object
chest_line.name = "LineaCoraza"
chest_line.rotation_euler = (math.radians(90), 0, 0)
set_material(chest_line, "LineaCorMat", (0.85, 0.7, 0.2), metallic=0.9, roughness=0.15)
objects.append(chest_line)

# --- HOMBRERA DERECHA ---
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(0.4, 0, 0.85), segments=14, ring_count=10)
pauldron_r = bpy.context.object
pauldron_r.name = "HombreraD"
pauldron_r.scale = (0.8, 0.65, 0.7)
bpy.ops.object.transform_apply(scale=True)
set_material(pauldron_r, "HombreraMat", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(pauldron_r)

# --- HOMBRERA IZQUIERDA ---
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(-0.4, 0, 0.85), segments=14, ring_count=10)
pauldron_l = bpy.context.object
pauldron_l.name = "HombreraI"
pauldron_l.scale = (0.8, 0.65, 0.7)
bpy.ops.object.transform_apply(scale=True)
set_material(pauldron_l, "HombreraMat2", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(pauldron_l)

# --- BRAZO DERECHO ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.5, location=(0.36, 0, 0.55))
arm_r = bpy.context.object
arm_r.name = "BrazoD"
arm_r.rotation_euler = (0, math.radians(12), 0)
set_material(arm_r, "BrazoMat", (0.15, 0.25, 0.35), metallic=0.05, roughness=0.65)
objects.append(arm_r)

# --- BRAZO IZQUIERDO ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.08, depth=0.5, location=(-0.36, 0, 0.55))
arm_l = bpy.context.object
arm_l.name = "BrazoI"
arm_l.rotation_euler = (0, math.radians(-12), 0)
set_material(arm_l, "BrazoMat2", (0.15, 0.25, 0.35), metallic=0.05, roughness=0.65)
objects.append(arm_l)

# --- ANTEBRAZO DERECHO ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.35, location=(0.45, 0, 0.28))
forearm_r = bpy.context.object
forearm_r.name = "AntebrazoD"
forearm_r.rotation_euler = (0, math.radians(8), 0)
set_material(forearm_r, "AntebMat", (0.22, 0.22, 0.25), metallic=0.8, roughness=0.25)
objects.append(forearm_r)

# --- ANTEBRAZO IZQUIERDO ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.07, depth=0.35, location=(-0.45, 0, 0.28))
forearm_l = bpy.context.object
forearm_l.name = "AntebrazoI"
forearm_l.rotation_euler = (0, math.radians(-8), 0)
set_material(forearm_l, "AntebMat2", (0.22, 0.22, 0.25), metallic=0.8, roughness=0.25)
objects.append(forearm_l)

# --- GUANTE DERECHO ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.48, 0, 0.09))
gauntlet_r = bpy.context.object
gauntlet_r.name = "GuanteD"
gauntlet_r.scale = (0.09, 0.07, 0.06)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
gauntlet_r.modifiers["Bevel"].width = 0.02
gauntlet_r.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(gauntlet_r, "GuanteMat", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(gauntlet_r)

# --- GUANTE IZQUIERDO ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.48, 0, 0.09))
gauntlet_l = bpy.context.object
gauntlet_l.name = "GuanteI"
gauntlet_l.scale = (0.09, 0.07, 0.06)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
gauntlet_l.modifiers["Bevel"].width = 0.02
gauntlet_l.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(gauntlet_l, "GuanteMat2", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(gauntlet_l)

# --- PIERNA DERECHA ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.55, location=(0.16, 0, 0.13))
leg_r = bpy.context.object
leg_r.name = "PiernaD"
set_material(leg_r, "PiernaMat", (0.13, 0.2, 0.28), metallic=0.05, roughness=0.7)
objects.append(leg_r)

# --- PIERNA IZQUIERDA ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.55, location=(-0.16, 0, 0.13))
leg_l = bpy.context.object
leg_l.name = "PiernaI"
set_material(leg_l, "PiernaMat2", (0.13, 0.2, 0.28), metallic=0.05, roughness=0.7)
objects.append(leg_l)

# --- GREBA DERECHA (armadura de espinilla) ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.16, 0.08, -0.1))
greave_r = bpy.context.object
greave_r.name = "GrebaD"
greave_r.scale = (0.13, 0.08, 0.2)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
greave_r.modifiers["Bevel"].width = 0.025
greave_r.modifiers["Bevel"].segments = 3
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(greave_r, "GrebaMat", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(greave_r)

# --- GREBA IZQUIERDA ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.16, 0.08, -0.1))
greave_l = bpy.context.object
greave_l.name = "GrebaI"
greave_l.scale = (0.13, 0.08, 0.2)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
greave_l.modifiers["Bevel"].width = 0.025
greave_l.modifiers["Bevel"].segments = 3
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(greave_l, "GrebaMat2", (0.28, 0.28, 0.30), metallic=0.85, roughness=0.2)
objects.append(greave_l)

# --- BOTA DERECHA ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.16, 0.03, -0.3))
boot_r = bpy.context.object
boot_r.name = "BotaD"
boot_r.scale = (0.14, 0.19, 0.10)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
boot_r.modifiers["Bevel"].width = 0.02
boot_r.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(boot_r, "BotaMat", (0.15, 0.1, 0.08), metallic=0.3, roughness=0.6)
objects.append(boot_r)

# --- BOTA IZQUIERDA ---
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.16, 0.03, -0.3))
boot_l = bpy.context.object
boot_l.name = "BotaI"
boot_l.scale = (0.14, 0.19, 0.10)
bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
boot_l.modifiers["Bevel"].width = 0.02
boot_l.modifiers["Bevel"].segments = 2
bpy.ops.object.modifier_apply(modifier="Bevel")
set_material(boot_l, "BotaMat2", (0.15, 0.1, 0.08), metallic=0.3, roughness=0.6)
objects.append(boot_l)

# --- CAPA (detras del torso) ---
bpy.ops.mesh.primitive_cone_add(radius1=0.35, radius2=0.55, depth=0.55, location=(0, -0.18, 0.7))
cape = bpy.context.object
cape.name = "Capa"
cape.rotation_euler = (math.radians(8), 0, 0)
cape.scale = (1.0, 0.6, 1.0)
bpy.ops.object.transform_apply(scale=True)
set_material(cape, "CapaMat", (0.45, 0.1, 0.1), metallic=0.0, roughness=0.75)
objects.append(cape)

# --- SEGUNDA CAPA (mas caudalosa) ---
bpy.ops.mesh.primitive_cone_add(radius1=0.3, radius2=0.5, depth=0.55, location=(0, -0.22, 0.68))
cape2 = bpy.context.object
cape2.name = "Capa2"
cape2.rotation_euler = (math.radians(12), 0, 0)
cape2.scale = (0.85, 0.55, 1.0)
bpy.ops.object.transform_apply(scale=True)
set_material(cape2, "Capa2Mat", (0.35, 0.08, 0.08), metallic=0.0, roughness=0.8)
objects.append(cape2)

# --- ESPADA EN LA CINTURA (vaina) ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.5, location=(0.28, -0.15, 0.35))
sheath = bpy.context.object
sheath.name = "Vaina"
sheath.rotation_euler = (math.radians(20), 0, math.radians(10))
set_material(sheath, "VainaMat", (0.25, 0.15, 0.08), metallic=0.3, roughness=0.6)
objects.append(sheath)

# --- EMPUNIADURA DE LA ESPADA ---
bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.08, location=(0.28, -0.15, 0.62))
sword_hilt = bpy.context.object
sword_hilt.name = "Empuniadura"
sword_hilt.rotation_euler = (math.radians(20), 0, math.radians(10))
set_material(sword_hilt, "HiltMat", (0.85, 0.7, 0.2), metallic=0.9, roughness=0.2)
objects.append(sword_hilt)

# --- POMO DE LA ESPADA ---
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(0.28, -0.14, 0.67), segments=8, ring_count=6)
sword_pommel = bpy.context.object
sword_pommel.name = "Pomo"
set_material(sword_pommel, "PomoMat", (0.85, 0.7, 0.2), metallic=0.9, roughness=0.15)
objects.append(sword_pommel)

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
print(f"Player exportado a: {OUTPUT_PATH}")
