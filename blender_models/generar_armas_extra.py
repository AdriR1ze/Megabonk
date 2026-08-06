"""
SCRIPT DE BLENDER - ARMAS EXTRA (Escopeta, Francotirador, Lanzallamas, CanonPlasma)
Genera las 4 armas nuevas y las exporta individualmente a Assets/Models/
"""
import bpy
import math
import os

BASE_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk\Assets\Models"
os.makedirs(BASE_PATH, exist_ok=True)

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()

def add_mat(obj, name, color, metallic=0.7, roughness=0.3, emission=None):
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

def export_model(obj, filename):
    bpy.ops.object.select_all(action='DESELECT')
    obj.select_set(True)
    bpy.context.view_layer.objects.active = obj
    path = os.path.join(BASE_PATH, filename)
    bpy.ops.export_scene.gltf(filepath=path, use_selection=True, export_format='GLB')
    print(f"✅ Exportado: {path}")

# ============================================================
# ======================== ESCOPETA ==========================
# ============================================================
clear_scene()
esc_objs = []

# Receptor / cuerpo
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.05))
esc_body = bpy.context.object
esc_body.name = "Receptor"
esc_body.scale = (0.3, 0.06, 0.08)
bpy.ops.object.transform_apply(scale=True)
add_mat(esc_body, "ReceptorMat", (0.1, 0.1, 0.11), metallic=0.8, roughness=0.25)
esc_objs.append(esc_body)

# Doble cañón
for side, y in [(1, 0.03), (-1, -0.03)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.021, depth=0.55,
                                        location=(0.28, y, 0.045))
    canon = bpy.context.object
    canon.name = f"CanonEscopeta{side}"
    canon.rotation_euler = (0, math.radians(90), 0)
    add_mat(canon, f"CanonEscMat{side}", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.15)
    esc_objs.append(canon)

# Culata (madera)
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.32, 0, 0.02))
esc_stock = bpy.context.object
esc_stock.name = "CulataEscopeta"
esc_stock.scale = (0.18, 0.05, 0.08)
bpy.ops.object.transform_apply(scale=True)
add_mat(esc_stock, "CulataEscMat", (0.2, 0.12, 0.06), metallic=0.1, roughness=0.8)
esc_objs.append(esc_stock)

# Guardamanos (pump)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.12, 0, -0.03))
esc_pump = bpy.context.object
esc_pump.name = "Guardamanos"
esc_pump.scale = (0.13, 0.045, 0.09)
bpy.ops.object.transform_apply(scale=True)
add_mat(esc_pump, "PumpMat", (0.06, 0.06, 0.07), metallic=0.75, roughness=0.3)
esc_objs.append(esc_pump)

# Mango (madera)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.06, 0, -0.1))
esc_handle = bpy.context.object
esc_handle.name = "MangoEscopeta"
esc_handle.scale = (0.09, 0.05, 0.11)
bpy.ops.object.transform_apply(scale=True)
esc_handle.rotation_euler = (0, math.radians(-8), 0)
add_mat(esc_handle, "MangoEscMat", (0.2, 0.12, 0.06), metallic=0.1, roughness=0.8)
esc_objs.append(esc_handle)

# Mira
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.1, 0, 0.1))
esc_sight = bpy.context.object
esc_sight.name = "MiraEscopeta"
esc_sight.scale = (0.07, 0.015, 0.02)
bpy.ops.object.transform_apply(scale=True)
add_mat(esc_sight, "MiraEscMat", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.1)
esc_objs.append(esc_sight)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in esc_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = esc_body
bpy.ops.object.join()
esc_final = bpy.context.object
esc_final.name = "Escopeta"
export_model(esc_final, "escopeta.glb")

# ============================================================
# ==================== FRANCOTIRADOR =========================
# ============================================================
clear_scene()
fra_objs = []

# Receptor largo
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.05))
fra_body = bpy.context.object
fra_body.name = "ReceptorFranco"
fra_body.scale = (0.34, 0.07, 0.09)
bpy.ops.object.transform_apply(scale=True)
add_mat(fra_body, "FrancoBodyMat", (0.06, 0.07, 0.08), metallic=0.8, roughness=0.25)
fra_objs.append(fra_body)

# Cañón largo
bpy.ops.mesh.primitive_cylinder_add(radius=0.02, depth=0.6, location=(0.32, 0, 0.05))
fra_barrel = bpy.context.object
fra_barrel.name = "CanonFranco"
fra_barrel.rotation_euler = (0, math.radians(90), 0)
add_mat(fra_barrel, "FrancoBarrelMat", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.12)
fra_objs.append(fra_barrel)

# Culata
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.32, 0, 0.03))
fra_stock = bpy.context.object
fra_stock.name = "CulataFranco"
fra_stock.scale = (0.2, 0.05, 0.07)
bpy.ops.object.transform_apply(scale=True)
add_mat(fra_stock, "FrancoStockMat", (0.08, 0.08, 0.08), metallic=0.2, roughness=0.7)
fra_objs.append(fra_stock)

# Mira telescópica
bpy.ops.mesh.primitive_cylinder_add(radius=0.028, depth=0.22, location=(0.08, 0, 0.16))
fra_scope = bpy.context.object
fra_scope.name = "MiraFranco"
fra_scope.rotation_euler = (0, math.radians(90), 0)
add_mat(fra_scope, "FrancoScopeMat", (0.04, 0.04, 0.05), metallic=0.85, roughness=0.2)
fra_objs.append(fra_scope)

# Soporte de mira
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.08, 0, 0.11))
fra_mount = bpy.context.object
fra_mount.name = "SoporteFranco"
fra_mount.scale = (0.06, 0.05, 0.035)
bpy.ops.object.transform_apply(scale=True)
add_mat(fra_mount, "FrancoMountMat", (0.06, 0.06, 0.07), metallic=0.85, roughness=0.2)
fra_objs.append(fra_mount)

# Mango + guardamano
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.02, 0, -0.1))
fra_handle = bpy.context.object
fra_handle.name = "MangoFranco"
fra_handle.scale = (0.08, 0.05, 0.11)
bpy.ops.object.transform_apply(scale=True)
fra_handle.rotation_euler = (0, math.radians(-6), 0)
add_mat(fra_handle, "FrancoHandleMat", (0.1, 0.07, 0.05), metallic=0.1, roughness=0.85)
fra_objs.append(fra_handle)

# Bípode
bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.22, location=(0.16, -0.08, -0.05))
fra_bipod = bpy.context.object
fra_bipod.name = "Bipode1"
fra_bipod.rotation_euler = (0.5, 0, 0)
add_mat(fra_bipod, "BipodMat", (0.06, 0.06, 0.07), metallic=0.85, roughness=0.25)
fra_objs.append(fra_bipod)
bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.22, location=(0.16, 0.08, -0.05))
fra_bipod2 = bpy.context.object
fra_bipod2.name = "Bipode2"
fra_bipod2.rotation_euler = (-0.5, 0, 0)
add_mat(fra_bipod2, "BipodMat2", (0.06, 0.06, 0.07), metallic=0.85, roughness=0.25)
fra_objs.append(fra_bipod2)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in fra_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = fra_body
bpy.ops.object.join()
fra_final = bpy.context.object
fra_final.name = "Francotirador"
export_model(fra_final, "francotirador.glb")

# ============================================================
# ===================== LANZALLAMAS ==========================
# ============================================================
clear_scene()
lla_objs = []

# Tanque de combustible
bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.34, location=(-0.2, 0, -0.02))
lla_tank = bpy.context.object
lla_tank.name = "Tanque"
lla_tank.rotation_euler = (0, math.radians(90), 0)
add_mat(lla_tank, "TankMat", (0.55, 0.1, 0.05), metallic=0.6, roughness=0.35)
lla_objs.append(lla_tank)

# Válvula del tanque
bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.08, location=(-0.04, 0, -0.02))
lla_valve = bpy.context.object
lla_valve.name = "Valvula"
lla_valve.rotation_euler = (0, math.radians(90), 0)
add_mat(lla_valve, "ValvMat", (0.08, 0.08, 0.09), metallic=0.8, roughness=0.25)
lla_objs.append(lla_valve)

# Cañón / boquilla
bpy.ops.mesh.primitive_cylinder_add(radius=0.04, depth=0.3, location=(0.2, 0, 0.04))
lla_nozzle = bpy.context.object
lla_nozzle.name = "Boquilla"
lla_nozzle.rotation_euler = (0, math.radians(90), 0)
add_mat(lla_nozzle, "NozzleMat", (0.05, 0.05, 0.05), metallic=0.85, roughness=0.2)
lla_objs.append(lla_nozzle)

# Punta de la boquilla (cono)
bpy.ops.mesh.primitive_cone_add(radius1=0.05, radius2=0.02, depth=0.1,
                                location=(0.33, 0, 0.04))
lla_tip = bpy.context.object
lla_tip.name = "PuntaBoquilla"
lla_tip.rotation_euler = (0, math.radians(90), 0)
add_mat(lla_tip, "PuntaMat", (0.08, 0.08, 0.09), metallic=0.8, roughness=0.25)
lla_objs.append(lla_tip)

# Manija
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.05, 0, -0.14))
lla_handle = bpy.context.object
lla_handle.name = "Manija"
lla_handle.scale = (0.08, 0.05, 0.12)
bpy.ops.object.transform_apply(scale=True)
lla_handle.rotation_euler = (0, math.radians(-6), 0)
add_mat(lla_handle, "ManijaMat", (0.1, 0.07, 0.05), metallic=0.1, roughness=0.85)
lla_objs.append(lla_handle)

# Pedal / soporte inferior
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.1, 0, -0.12))
lla_plate = bpy.context.object
lla_plate.name = "Soporte"
lla_plate.scale = (0.16, 0.04, 0.06)
bpy.ops.object.transform_apply(scale=True)
add_mat(lla_plate, "SoporteMat", (0.06, 0.06, 0.07), metallic=0.7, roughness=0.3)
lla_objs.append(lla_plate)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in lla_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = lla_tank
bpy.ops.object.join()
lla_final = bpy.context.object
lla_final.name = "Lanzallamas"
export_model(lla_final, "lanzallamas.glb")

# ============================================================
# ===================== CAÑÓN DE PLASMA ======================
# ============================================================
clear_scene()
cpl_objs = []

# Tubo principal
bpy.ops.mesh.primitive_cylinder_add(radius=0.09, depth=0.5, location=(0, 0, 0.05))
cpl_tube = bpy.context.object
cpl_tube.name = "TuboPlasma"
cpl_tube.rotation_euler = (0, math.radians(90), 0)
add_mat(cpl_tube, "PlasmaTubeMat", (0.1, 0.1, 0.13), metallic=0.75, roughness=0.3)
cpl_objs.append(cpl_tube)

# Anillos de energía
for i, x in enumerate([-0.1, 0.12]):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.11, minor_radius=0.016,
                                      major_segments=14, minor_segments=8,
                                      location=(x, 0, 0.05))
    ring = bpy.context.object
    ring.name = f"AnilloPlasma{i}"
    ring.rotation_euler = (math.radians(90), 0, 0)
    add_mat(ring, f"AnilloPlasmaMat{i}", (0.0, 0.8, 1.0), metallic=0.0, roughness=0.0,
            emission=(0.0, 0.8, 1.0))
    cpl_objs.append(ring)

# Núcleo de energía
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(0.02, 0, 0.05), segments=14, ring_count=10)
cpl_core = bpy.context.object
cpl_core.name = "NucleoPlasma"
add_mat(cpl_core, "NucleoPlasmaMat", (0.6, 0.2, 1.0), metallic=0.0, roughness=0.0,
        emission=(0.7, 0.3, 1.0))
cpl_objs.append(cpl_core)

# Boca delantera
bpy.ops.mesh.primitive_cylinder_add(radius=0.105, depth=0.07, location=(0.26, 0, 0.05))
cpl_muzzle = bpy.context.object
cpl_muzzle.name = "BocaPlasma"
cpl_muzzle.rotation_euler = (0, math.radians(90), 0)
add_mat(cpl_muzzle, "PlasmaMuzzleMat", (0.08, 0.08, 0.09), metallic=0.8, roughness=0.2)
cpl_objs.append(cpl_muzzle)

# Mango
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.05, 0, -0.12))
cpl_handle = bpy.context.object
cpl_handle.name = "MangoPlasma"
cpl_handle.scale = (0.09, 0.055, 0.14)
bpy.ops.object.transform_apply(scale=True)
cpl_handle.rotation_euler = (0, math.radians(-6), 0)
add_mat(cpl_handle, "PlasmaHandleMat", (0.1, 0.08, 0.06), metallic=0.15, roughness=0.85)
cpl_objs.append(cpl_handle)

# Culata
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.32, 0, 0.03))
cpl_stock = bpy.context.object
cpl_stock.name = "CulataPlasma"
cpl_stock.scale = (0.16, 0.05, 0.08)
bpy.ops.object.transform_apply(scale=True)
add_mat(cpl_stock, "PlasmaStockMat", (0.08, 0.08, 0.09), metallic=0.3, roughness=0.7)
cpl_objs.append(cpl_stock)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in cpl_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = cpl_tube
bpy.ops.object.join()
cpl_final = bpy.context.object
cpl_final.name = "CanonPlasma"
export_model(cpl_final, "canon_plasma.glb")

print("✅ Todas las armas extra exportadas correctamente.")
