"""
SCRIPT DE BLENDER - BALAS (Normal, Chica, Bomba)
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
# ==================== BALA NORMAL ===========================
# ============================================================
clear_scene()
bala_objs = []

# Cuerpo principal (cápsula alargada)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(0, 0, 0), segments=12, ring_count=8)
b_body = bpy.context.object
b_body.name = "BalaCuerpo"
b_body.scale = (1.0, 1.0, 1.8)
bpy.ops.object.transform_apply(scale=True)
add_mat(b_body, "BalaBodyMat", (0.95, 0.75, 0.1), metallic=0.9, roughness=0.15,
        emission=(1.0, 0.85, 0.2))
bala_objs.append(b_body)

# Cola (cono pequeño atrás)
bpy.ops.mesh.primitive_cone_add(radius1=0.055, radius2=0.02, depth=0.07, location=(0, 0, -0.12))
b_tail = bpy.context.object
b_tail.name = "BalaCola"
b_tail.rotation_euler = (math.radians(180), 0, 0)
add_mat(b_tail, "BalaColaMat", (0.6, 0.4, 0.1), metallic=0.8, roughness=0.2)
bala_objs.append(b_tail)

# Halo de energía (torus pequeño)
bpy.ops.mesh.primitive_torus_add(major_radius=0.08, minor_radius=0.015,
                                   major_segments=12, minor_segments=6,
                                   location=(0, 0, 0.02))
b_ring = bpy.context.object
b_ring.name = "BalaRing"
add_mat(b_ring, "BalaRingMat", (1.0, 0.5, 0.0), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.5, 0.0))
bala_objs.append(b_ring)

bpy.ops.object.select_all(action='DESELECT')
for o in bala_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = b_body
bpy.ops.object.join()
bala_final = bpy.context.object
bala_final.name = "BalaNormal"
export_model(bala_final, "balanormal_mesh.glb")

# ============================================================
# ==================== BALA CHICA ============================
# ============================================================
clear_scene()
balac_objs = []

# Cuerpo (muy pequeño, tipo tracer)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.035, location=(0, 0, 0), segments=10, ring_count=6)
bc_body = bpy.context.object
bc_body.name = "BalaChicaCuerpo"
bc_body.scale = (1.0, 1.0, 2.2)
bpy.ops.object.transform_apply(scale=True)
add_mat(bc_body, "BalaChicaMat", (0.3, 0.9, 1.0), metallic=0.5, roughness=0.1,
        emission=(0.3, 0.9, 1.0))
balac_objs.append(bc_body)

# Estela de energía (cilindro muy fino)
bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.2, location=(0, 0, -0.14))
bc_trail = bpy.context.object
bc_trail.name = "Estela"
add_mat(bc_trail, "EstelaMat", (0.2, 0.7, 1.0), metallic=0.0, roughness=0.0,
        emission=(0.2, 0.7, 1.0))
balac_objs.append(bc_trail)

bpy.ops.object.select_all(action='DESELECT')
for o in balac_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = bc_body
bpy.ops.object.join()
balac_final = bpy.context.object
balac_final.name = "BalaChica"
export_model(balac_final, "balachica_mesh.glb")

# ============================================================
# ==================== BALA BOMBA ============================
# ============================================================
clear_scene()
bomb_objs = []

# Cuerpo principal (esfera)
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, location=(0, 0, 0), segments=14, ring_count=10)
bb_body = bpy.context.object
bb_body.name = "BombaCuerpo"
add_mat(bb_body, "BombaMat", (0.12, 0.12, 0.14), metallic=0.6, roughness=0.4)
bomb_objs.append(bb_body)

# Punta delantera (cono)
bpy.ops.mesh.primitive_cone_add(radius1=0.06, radius2=0.01, depth=0.14, location=(0, 0, 0.15))
bb_tip = bpy.context.object
bb_tip.name = "BombaPunta"
add_mat(bb_tip, "BombaPuntaMat", (0.7, 0.3, 0.05), metallic=0.7, roughness=0.2)
bomb_objs.append(bb_tip)

# Aletas (4 aletas traseras)
for i in range(4):
    angle = i * math.pi / 2
    x = math.cos(angle) * 0.1
    y = math.sin(angle) * 0.1
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x, y, -0.1))
    fin = bpy.context.object
    fin.name = f"Aleta{i}"
    fin.scale = (0.04, 0.04, 0.12)
    bpy.ops.object.transform_apply(scale=True)
    fin.rotation_euler = (0, 0, angle)
    add_mat(fin, f"AletaMat{i}", (0.1, 0.1, 0.12), metallic=0.7, roughness=0.3)
    bomb_objs.append(fin)

# Brillo de energía en el cuerpo
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.09, location=(0, 0, 0.02), segments=10, ring_count=8)
bb_glow = bpy.context.object
bb_glow.name = "BombaGlow"
add_mat(bb_glow, "BombaGlowMat", (1.0, 0.4, 0.0), metallic=0.0, roughness=0.0,
        emission=(1.0, 0.4, 0.0))
bomb_objs.append(bb_glow)

bpy.ops.object.select_all(action='DESELECT')
for o in bomb_objs:
    o.select_set(True)
bpy.context.view_layer.objects.active = bb_body
bpy.ops.object.join()
bomb_final = bpy.context.object
bomb_final.name = "BalaBomba"
export_model(bomb_final, "balabomba_mesh.glb")

print("✅ Todas las balas exportadas correctamente.")
