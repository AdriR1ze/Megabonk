"""
SCRIPT DE BLENDER - ARMAS (Pistola, Subfusil, LanzaCohete)
Genera las 3 armas y las exporta individualmente
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
# ======================== PISTOLA ===========================
# ============================================================
clear_scene()
pistola_objs = []

# Slide (parte superior de la pistola)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.02, 0, 0.055))
slide = bpy.context.object
slide.name = "Slide"
slide.scale = (0.38, 0.055, 0.07)
bpy.ops.object.transform_apply(scale=True)
add_mat(slide, "SlideMat", (0.08, 0.08, 0.09), metallic=0.85, roughness=0.2)
pistola_objs.append(slide)

# Cañón
bpy.ops.mesh.primitive_cylinder_add(radius=0.022, depth=0.28, location=(0.22, 0, 0.052))
barrel = bpy.context.object
barrel.name = "Canon"
barrel.rotation_euler = (0, math.radians(90), 0)
add_mat(barrel, "CanonMat", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.15)
pistola_objs.append(barrel)

# Mango (handle)
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.03, 0, -0.09))
handle = bpy.context.object
handle.name = "Mango"
handle.scale = (0.10, 0.048, 0.13)
bpy.ops.object.transform_apply(scale=True)
handle.rotation_euler = (0, math.radians(-8), 0)
add_mat(handle, "MangoMat", (0.12, 0.08, 0.06), metallic=0.1, roughness=0.8)
pistola_objs.append(handle)

# Guardamano
bpy.ops.mesh.primitive_torus_add(major_radius=0.045, minor_radius=0.012,
                                   major_segments=16, minor_segments=8,
                                   location=(0.05, 0, -0.015))
guard = bpy.context.object
guard.name = "Guardamano"
guard.rotation_euler = (math.radians(90), 0, 0)
guard.scale = (0.5, 1.0, 0.7)
bpy.ops.object.transform_apply(scale=True)
add_mat(guard, "GuardMat", (0.08, 0.08, 0.09), metallic=0.8, roughness=0.25)
pistola_objs.append(guard)

# Mira
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.1, 0, 0.095))
sight = bpy.context.object
sight.name = "Mira"
sight.scale = (0.08, 0.02, 0.025)
bpy.ops.object.transform_apply(scale=True)
add_mat(sight, "MiraMat", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.1)
pistola_objs.append(sight)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in pistola_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = slide
bpy.ops.object.join()
pistola_final = bpy.context.object
pistola_final.name = "Pistola"
export_model(pistola_final, "pistola.glb")

# ============================================================
# ======================== SUBFUSIL ==========================
# ============================================================
clear_scene()
smg_objs = []

# Cuerpo principal
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.04))
smg_body = bpy.context.object
smg_body.name = "CuerpoSMG"
smg_body.scale = (0.5, 0.06, 0.09)
bpy.ops.object.transform_apply(scale=True)
add_mat(smg_body, "SMGBodyMat", (0.06, 0.06, 0.07), metallic=0.8, roughness=0.3)
smg_objs.append(smg_body)

# Cañón largo
bpy.ops.mesh.primitive_cylinder_add(radius=0.024, depth=0.42, location=(0.28, 0, 0.04))
smg_barrel = bpy.context.object
smg_barrel.name = "CanonSMG"
smg_barrel.rotation_euler = (0, math.radians(90), 0)
add_mat(smg_barrel, "SMGBarrelMat", (0.05, 0.05, 0.05), metallic=0.9, roughness=0.15)
smg_objs.append(smg_barrel)

# Silenciador (opcional, estilo)
bpy.ops.mesh.primitive_cylinder_add(radius=0.035, depth=0.14, location=(0.46, 0, 0.04))
silencer = bpy.context.object
silencer.name = "Silenciador"
silencer.rotation_euler = (0, math.radians(90), 0)
add_mat(silencer, "SilMat", (0.1, 0.1, 0.12), metallic=0.75, roughness=0.35)
smg_objs.append(silencer)

# Mango
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.06, 0, -0.09))
smg_handle = bpy.context.object
smg_handle.name = "MangoSMG"
smg_handle.scale = (0.09, 0.05, 0.13)
bpy.ops.object.transform_apply(scale=True)
smg_handle.rotation_euler = (0, math.radians(-10), 0)
add_mat(smg_handle, "SMGHandleMat", (0.1, 0.07, 0.05), metallic=0.1, roughness=0.9)
smg_objs.append(smg_handle)

# Cargador
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.0, 0, -0.09))
mag = bpy.context.object
mag.name = "Cargador"
mag.scale = (0.08, 0.045, 0.14)
bpy.ops.object.transform_apply(scale=True)
add_mat(mag, "MagMat", (0.04, 0.04, 0.05), metallic=0.7, roughness=0.4)
smg_objs.append(mag)

# Culata (stock)
bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.38, 0, 0.035))
stock = bpy.context.object
stock.name = "Culata"
stock.scale = (0.14, 0.04, 0.07)
bpy.ops.object.transform_apply(scale=True)
add_mat(stock, "StockMat", (0.1, 0.07, 0.05), metallic=0.2, roughness=0.8)
smg_objs.append(stock)

# Rail superior
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.0, 0, 0.08))
rail = bpy.context.object
rail.name = "Rail"
rail.scale = (0.42, 0.025, 0.018)
bpy.ops.object.transform_apply(scale=True)
add_mat(rail, "RailMat", (0.07, 0.07, 0.08), metallic=0.9, roughness=0.2)
smg_objs.append(rail)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in smg_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = smg_body
bpy.ops.object.join()
smg_final = bpy.context.object
smg_final.name = "Subfusil"
export_model(smg_final, "subfusil.glb")

# ============================================================
# ==================== LANZACOHETE ==========================
# ============================================================
clear_scene()
rl_objs = []

# Tubo principal
bpy.ops.mesh.primitive_cylinder_add(radius=0.095, depth=0.85, location=(0, 0, 0.04))
rl_tube = bpy.context.object
rl_tube.name = "Tubo"
rl_tube.rotation_euler = (0, math.radians(90), 0)
add_mat(rl_tube, "TuboMat", (0.15, 0.22, 0.10), metallic=0.2, roughness=0.7)
rl_objs.append(rl_tube)

# Boca delantera (anillo más grande)
bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.07, location=(0.44, 0, 0.04))
muzzle = bpy.context.object
muzzle.name = "Boca"
muzzle.rotation_euler = (0, math.radians(90), 0)
add_mat(muzzle, "MuzzleMat", (0.1, 0.1, 0.1), metallic=0.8, roughness=0.25)
rl_objs.append(muzzle)

# Mango principal (medio)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.05, 0, -0.16))
rl_handle = bpy.context.object
rl_handle.name = "MangoRL"
rl_handle.scale = (0.1, 0.055, 0.17)
bpy.ops.object.transform_apply(scale=True)
rl_handle.rotation_euler = (0, math.radians(-5), 0)
add_mat(rl_handle, "RLHandleMat", (0.1, 0.08, 0.05), metallic=0.1, roughness=0.9)
rl_objs.append(rl_handle)

# Segundo mango (delantero)
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.25, 0, -0.14))
rl_handle2 = bpy.context.object
rl_handle2.name = "MangoRL2"
rl_handle2.scale = (0.07, 0.05, 0.14)
bpy.ops.object.transform_apply(scale=True)
add_mat(rl_handle2, "RLHandleMat2", (0.1, 0.08, 0.05), metallic=0.1, roughness=0.9)
rl_objs.append(rl_handle2)

# Mira telescópica
bpy.ops.mesh.primitive_cylinder_add(radius=0.025, depth=0.2, location=(0.08, 0, 0.14))
scope = bpy.context.object
scope.name = "Mira"
scope.rotation_euler = (0, math.radians(90), 0)
add_mat(scope, "ScopeMat", (0.05, 0.05, 0.06), metallic=0.8, roughness=0.2)
rl_objs.append(scope)

# Soporte de mira
bpy.ops.mesh.primitive_cube_add(size=1, location=(0.08, 0, 0.11))
scope_mount = bpy.context.object
scope_mount.name = "SoporteMira"
scope_mount.scale = (0.05, 0.05, 0.035)
bpy.ops.object.transform_apply(scale=True)
add_mat(scope_mount, "MountMat", (0.07, 0.07, 0.08), metallic=0.85, roughness=0.2)
rl_objs.append(scope_mount)

# Cola / escudo de gases (anillos traseros)
for i, x in enumerate([-0.3, -0.38]):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.11, minor_radius=0.018,
                                      major_segments=16, minor_segments=8,
                                      location=(x, 0, 0.04))
    ring = bpy.context.object
    ring.name = f"Anillo{i}"
    ring.rotation_euler = (math.radians(90), 0, 0)
    add_mat(ring, f"RingMat{i}", (0.08, 0.08, 0.09), metallic=0.8, roughness=0.3)
    rl_objs.append(ring)

# Unir
bpy.ops.object.select_all(action='DESELECT')
for o in rl_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = rl_tube
bpy.ops.object.join()
rl_final = bpy.context.object
rl_final.name = "LanzaCohete"
export_model(rl_final, "lanzacohete.glb")

print("✅ Todas las armas exportadas correctamente.")
