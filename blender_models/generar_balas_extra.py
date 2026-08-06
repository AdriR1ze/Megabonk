"""
SCRIPT DE BLENDER - BALAS EXTRA (Pellet, Franco, Fuego, Plasma)
Genera las 4 balas nuevas y las exporta individualmente a Assets/Models/
"""
import bpy
import math
import os

BASE_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk\Assets\Models"
os.makedirs(BASE_PATH, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def add_mat(obj, name, color, metallic=0.6, roughness=0.3, emission=None):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Metallic"].default_value = metallic
    bsdf.inputs["Roughness"].default_value = roughness
    if emission:
        bsdf.inputs["Emission Color"].default_value = (*emission, 1.0)
        bsdf.inputs["Emission Strength"].default_value = 6.0
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)

def export_model(obj, filename):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    path = os.path.join(BASE_PATH, filename)
    bpy.ops.export_scene.gltf(filepath=path, use_selection=True, export_format='GLB')
    print(f"✅ Exportado: {path}")

# ============================================================
# ==================== BALA PELLET ===========================
# ============================================================
clear_scene()
pel_objs = []

# Cuerpo (perdigón)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.055, location=(0, 0, 0), segments=10, ring_count=8)
pel_body = bpy.context.object
pel_body.name = "PelletCuerpo"
pel_body.scale = (1.0, 1.0, 1.3)
bpy.ops.object.transform_apply(scale=True)
add_mat(pel_body, "PelletMat", (0.95, 0.55, 0.1), metallic=0.9, roughness=0.15,
        emission=(1.0, 0.7, 0.2))
pel_objs.append(pel_body)

# Estela de disparo (corto)
bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.14, location=(0, 0, -0.11))
pel_trail = bpy.context.object
pel_trail.name = "PelletEstela"
add_mat(pel_trail, "PelletEstelaMat", (1.0, 0.6, 0.1), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.6, 0.1))
pel_objs.append(pel_trail)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in pel_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = pel_body
bpy.ops.object.join()
pel_final = bpy.context.object
pel_final.name = "BalaPellet"
export_model(pel_final, "bala_pellet_mesh.glb")

# ============================================================
# ==================== BALA FRANCO ===========================
# ============================================================
clear_scene()
frc_objs = []

# Cuerpo alargado (perforante)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.045, location=(0, 0, 0), segments=12, ring_count=8)
frc_body = bpy.context.object
frc_body.name = "FrancoCuerpo"
frc_body.scale = (1.0, 1.0, 3.5)
bpy.ops.object.transform_apply(scale=True)
add_mat(frc_body, "FrancoBalaMat", (0.1, 0.9, 0.4), metallic=0.5, roughness=0.1,
        emission=(0.1, 1.0, 0.4))
frc_objs.append(frc_body)

# Punta perforante
bpy.ops.mesh.primitive_cone_add(radius1=0.035, radius2=0.005, depth=0.12,
                                location=(0, 0, 0.14))
frc_tip = bpy.context.object
frc_tip.name = "FrancoPunta"
add_mat(frc_tip, "FrancoPuntaMat", (0.9, 1.0, 0.9), metallic=0.9, roughness=0.1)
frc_objs.append(frc_tip)

# Estela larga
bpy.ops.mesh.primitive_cylinder_add(radius=0.014, depth=0.4, location=(0, 0, -0.3))
frc_trail = bpy.context.object
frc_trail.name = "FrancoEstela"
add_mat(frc_trail, "FrancoEstelaMat", (0.1, 0.9, 0.4), metallic=0.0, roughness=0.0,
        emission=(0.1, 0.9, 0.4))
frc_objs.append(frc_trail)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in frc_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = frc_body
bpy.ops.object.join()
frc_final = bpy.context.object
frc_final.name = "BalaFranco"
export_model(frc_final, "bala_franco_mesh.glb")

# ============================================================
# ==================== BALA FUEGO ============================
# ============================================================
clear_scene()
fue_objs = []

# Bola de fuego
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(0, 0, 0), segments=12, ring_count=9)
fue_body = bpy.context.object
fue_body.name = "FuegoCuerpo"
add_mat(fue_body, "FuegoMat", (1.0, 0.5, 0.0), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.5, 0.0))
fue_objs.append(fue_body)

# Núcleo brillante
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.04, location=(0, 0, 0.01), segments=10, ring_count=8)
fue_core = bpy.context.object
fue_core.name = "FuegoNucleo"
add_mat(fue_core, "FuegoNucleoMat", (1.0, 1.0, 0.6), metallic=0.0, roughness=0.0,
        emission=(1.0, 1.0, 0.6))
fue_objs.append(fue_core)

# Estela de fuego (cono)
bpy.ops.mesh.primitive_cone_add(radius1=0.06, radius2=0.01, depth=0.22,
                                location=(0, 0, -0.12))
fue_trail = bpy.context.object
fue_trail.name = "FuegoEstela"
fue_trail.rotation_euler = (math.radians(180), 0, 0)
add_mat(fue_trail, "FuegoEstelaMat", (1.0, 0.3, 0.0), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.3, 0.0))
fue_objs.append(fue_trail)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in fue_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = fue_body
bpy.ops.object.join()
fue_final = bpy.context.object
fue_final.name = "BalaFuego"
export_model(fue_final, "bala_fuego_mesh.glb")

# ============================================================
# ==================== BALA PLASMA ===========================
# ============================================================
clear_scene()
cpl_objs = []

# Esfera de plasma grande
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.13, location=(0, 0, 0), segments=16, ring_count=12)
cpl_body = bpy.context.object
cpl_body.name = "PlasmaCuerpo"
add_mat(cpl_body, "PlasmaBalaMat", (0.5, 0.2, 1.0), metallic=0.0, roughness=0.0,
        emission=(0.6, 0.2, 1.0))
cpl_objs.append(cpl_body)

# Núcleo
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(0, 0, 0.01), segments=10, ring_count=8)
cpl_core = bpy.context.object
cpl_core.name = "PlasmaNucleo"
add_mat(cpl_core, "PlasmaNucleoMat", (1.0, 0.8, 1.0), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.8, 1.0))
cpl_objs.append(cpl_core)

# Anillos orbitales
for i, ang in enumerate([0, math.pi / 3]):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.18, minor_radius=0.012,
                                      major_segments=16, minor_segments=8,
                                      location=(0, 0, 0))
    ring = bpy.context.object
    ring.name = f"PlasmaAnillo{i}"
    ring.rotation_euler = (math.radians(60), 0, ang)
    add_mat(ring, f"PlasmaAnilloMat{i}", (0.3, 0.9, 1.0), metallic=0.0, roughness=0.0,
            emission=(0.3, 0.9, 1.0))
    cpl_objs.append(ring)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in cpl_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = cpl_body
bpy.ops.object.join()
cpl_final = bpy.context.object
cpl_final.name = "BalaPlasma"
export_model(cpl_final, "bala_plasma_mesh.glb")

print("✅ Todas las balas extra exportadas correctamente.")
