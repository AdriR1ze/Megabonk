"""
╔══════════════════════════════════════════════════════╗
║     MEGABONK - GENERADOR DE MODELOS COMPLETO        ║
║     Ejecutá este script en Blender (Scripting tab)  ║
╚══════════════════════════════════════════════════════╝

Cómo usarlo:
1. Abrí Blender (versión 3.x o 4.x)
2. Ir a la pestaña "Scripting" en la barra superior
3. Click en "New" para crear un script nuevo
4. Pegar TODO este código
5. Presionar el botón ► "Run Script"
6. Los modelos se exportan a Assets/Models/ del proyecto

NOTA: Requiere que Blender esté instalado y que el proyecto
      Megabonk esté en la carpeta configurada abajo.
"""

import bpy
import math
import os

# ====== CONFIGURACIÓN ======
PROJECT_PATH = r"C:\Users\Adriano\Documents\GitHub\Megabonk"
OUTPUT_PATH = os.path.join(PROJECT_PATH, "Assets", "Models")
os.makedirs(OUTPUT_PATH, exist_ok=True)

# ====== UTILIDADES ======

def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete()
    for mat in list(bpy.data.materials):
        bpy.data.materials.remove(mat)

def mat(obj, name, color=(0.5,0.5,0.5), metallic=0.5, roughness=0.4, emission=None):
    m = bpy.data.materials.new(name=name)
    m.use_nodes = True
    b = m.node_tree.nodes["Principled BSDF"]
    b.inputs["Base Color"].default_value = (*color, 1.0)
    b.inputs["Metallic"].default_value = metallic
    b.inputs["Roughness"].default_value = roughness
    if emission:
        b.inputs["Emission Color"].default_value = (*emission, 1.0)
        b.inputs["Emission Strength"].default_value = 6.0
    obj.data.materials.clear()
    obj.data.materials.append(m)

def export(name, filename):
    obj = bpy.data.objects.get(name)
    if obj:
        bpy.ops.object.select_all(action='DESELECT')
        obj.select_set(True)
        bpy.context.view_layer.objects.active = obj
        path = os.path.join(OUTPUT_PATH, filename)
        bpy.ops.export_scene.gltf(filepath=path, use_selection=True, export_format='GLB')
        print(f"  ✅ {filename}")
    else:
        print(f"  ❌ No se encontró el objeto: {name}")

def join_objects(objs, name, pivot_obj=None):
    bpy.ops.object.select_all(action='DESELECT')
    for o in objs:
        if o:
            o.select_set(True)
    base = pivot_obj if pivot_obj else objs[0]
    bpy.context.view_layer.objects.active = base
    if len(objs) > 1:
        bpy.ops.object.join()
    result = bpy.context.object
    result.name = name
    return result

print("\n🎮 MEGABONK - Generando modelos...\n")

# ════════════════════════════════════════════════════
#                      PLAYER
# ════════════════════════════════════════════════════
print("👤 Player...")
clear_scene()
objs = []

# Torso
bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0.75))
o = bpy.context.object; o.name="Torso"
o.scale = (0.55, 0.35, 0.55); bpy.ops.object.transform_apply(scale=True)
bpy.ops.object.modifier_add(type='BEVEL')
o.modifiers["Bevel"].width=0.04; o.modifiers["Bevel"].segments=2
bpy.ops.object.modifier_apply(modifier="Bevel")
mat(o, "TorsoMat", (0.18, 0.45, 0.18), 0.15, 0.55); objs.append(o)

# Cabeza
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.22, location=(0,0,1.35), segments=14, ring_count=10)
o = bpy.context.object; o.name="Cabeza"; o.scale=(1,0.9,1.05)
bpy.ops.object.transform_apply(scale=True)
mat(o,"CabezaMat",(0.18,0.45,0.18),0.1,0.5); objs.append(o)

# Casco
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.26, location=(0,0,1.48), segments=14, ring_count=7)
o = bpy.context.object; o.name="Casco"; o.scale=(1,0.88,0.55)
bpy.ops.object.transform_apply(scale=True)
mat(o,"CascoMat",(0.08,0.22,0.08),0.35,0.35); objs.append(o)

# Visera
bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0.2,1.33))
o = bpy.context.object; o.name="Visera"; o.scale=(0.28,0.04,0.1)
bpy.ops.object.transform_apply(scale=True)
mat(o,"ViseraMat",(0.05,0.9,0.85),0,0.05,(0.2,1,0.95)); objs.append(o)

# Pechera
bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0.24,0.77))
o = bpy.context.object; o.name="Pechera"; o.scale=(0.4,0.04,0.33)
bpy.ops.object.transform_apply(scale=True)
mat(o,"PecheraMat",(0.08,0.35,0.08),0.55,0.3); objs.append(o)

# Brazos
for side, x in [("D", 0.37), ("I", -0.37)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.085, depth=0.5, location=(x,0,0.77))
    o = bpy.context.object; o.name=f"Brazo{side}"
    o.rotation_euler=(0,math.radians(14 if side=="D" else -14),0)
    mat(o,f"BrazoMat{side}",(0.18,0.45,0.18),0.1,0.55); objs.append(o)

# Piernas
for side, x in [("D", 0.17), ("I", -0.17)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.58, location=(x,0,0.17))
    o = bpy.context.object; o.name=f"Pierna{side}"
    mat(o,f"PiernaMat{side}",(0.12,0.3,0.12),0.05,0.7); objs.append(o)

# Botas
for side, x in [("D", 0.17), ("I", -0.17)]:
    bpy.ops.mesh.primitive_cube_add(size=1, location=(x,0.04,-0.14))
    o = bpy.context.object; o.name=f"Bota{side}"; o.scale=(0.14,0.18,0.09)
    bpy.ops.object.transform_apply(scale=True)
    mat(o,f"BotaMat{side}",(0.05,0.05,0.05),0.45,0.5); objs.append(o)

r = join_objects(objs, "Player")
export("Player", "player.glb")

# ════════════════════════════════════════════════════
#                     ENEMIGO
# ════════════════════════════════════════════════════
print("👹 Enemigo...")
clear_scene()
objs = []

# Cuerpo
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.45, location=(0,0,0.55), segments=18, ring_count=12)
body = bpy.context.object; body.name="Cuerpo"; body.scale=(1,0.8,0.85)
bpy.ops.object.transform_apply(scale=True)
mat(body,"CuerpoEnemMat",(0.08,0.05,0.05),0.35,0.4); objs.append(body)

# Cabeza
bpy.ops.mesh.primitive_uv_sphere_add(radius=0.3, location=(0,0,1.07), segments=14, ring_count=10)
o = bpy.context.object; o.name="CabezaEnem"; o.scale=(1,0.85,0.95)
bpy.ops.object.transform_apply(scale=True)
mat(o,"CabezaEnemMat2",(0.06,0.04,0.04),0.4,0.35); objs.append(o)

# Ojos brillantes
for side, x in [("D",0.12),("I",-0.12)]:
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.07, location=(x,0.26,1.1), segments=10, ring_count=8)
    o = bpy.context.object; o.name=f"Ojo{side}"
    mat(o,f"OjoMat{side}",(1,0.1,0),0,0.0,(1,0.05,0)); objs.append(o)

# Hombros
for side, x in [("D",0.52),("I",-0.52)]:
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.18, location=(x,0,0.68), segments=10, ring_count=8)
    o = bpy.context.object; o.name=f"Hombro{side}"; o.scale=(1,0.8,0.9)
    bpy.ops.object.transform_apply(scale=True)
    mat(o,f"HombroMat{side}",(0.1,0.06,0.06),0.55,0.3); objs.append(o)

# Brazos + Garras
for side, x, sign in [("D",0.7,1),("I",-0.7,-1)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.1, depth=0.44, location=(x,0,0.44))
    o = bpy.context.object; o.name=f"BrazoEnem{side}"
    o.rotation_euler=(0,math.radians(25*sign),0)
    mat(o,f"BrazoEnemMat{side}",(0.08,0.05,0.05),0.3,0.5); objs.append(o)
    bpy.ops.mesh.primitive_cone_add(radius1=0.12,radius2=0.01,depth=0.3, location=(x*1.3,0,0.22))
    o = bpy.context.object; o.name=f"Garra{side}"
    o.rotation_euler=(0,math.radians(80*sign),0)
    mat(o,f"GarraMat{side}",(0.15,0,0),0.85,0.15); objs.append(o)

# Patas
for side, x in [("D",0.22),("I",-0.22)]:
    bpy.ops.mesh.primitive_cylinder_add(radius=0.12, depth=0.38, location=(x,0,0.15))
    o = bpy.context.object; o.name=f"Pata{side}"
    mat(o,f"PataMat{side}",(0.07,0.04,0.04),0.2,0.6); objs.append(o)

# Púas dorsales
for i, (x, zoff) in enumerate([(-0.15,0),(0,0.1),(0.15,0)]):
    bpy.ops.mesh.primitive_cone_add(radius1=0.06,radius2=0.01,depth=0.26,
                                     location=(x,-0.38,0.74+zoff))
    o = bpy.context.object; o.name=f"Pua{i}"
    o.rotation_euler=(math.radians(-38),0,0)
    mat(o,f"PuaMat{i}",(0.18,0,0),0.75,0.2); objs.append(o)

r = join_objects(objs, "Enemigo", body)
export("Enemigo", "enemigo.glb")

# ════════════════════════════════════════════════════
#                    PISTOLA
# ════════════════════════════════════════════════════
print("🔫 Pistola...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_cube_add(size=1, location=(0.02,0,0.055))
o=bpy.context.object; o.name="Slide"; o.scale=(0.38,0.055,0.07)
bpy.ops.object.transform_apply(scale=True)
mat(o,"SlideMat",(0.08,0.08,0.09),0.85,0.2); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.022, depth=0.3, location=(0.23,0,0.052))
o=bpy.context.object; o.name="Canon"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"CanonMat",(0.05,0.05,0.05),0.9,0.15); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.03,0,-0.09))
o=bpy.context.object; o.name="Mango"; o.scale=(0.1,0.048,0.13)
bpy.ops.object.transform_apply(scale=True)
o.rotation_euler=(0,math.radians(-8),0)
mat(o,"MangoMat",(0.12,0.08,0.06),0.1,0.85); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0.1,0,0.095))
o=bpy.context.object; o.name="Mira"; o.scale=(0.07,0.02,0.025)
bpy.ops.object.transform_apply(scale=True)
mat(o,"MiraMat",(0.05,0.05,0.05),0.9,0.1); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.01,0,-0.003))
o=bpy.context.object; o.name="Guard"; o.scale=(0.08,0.02,0.04)
bpy.ops.object.transform_apply(scale=True)
mat(o,"GuardMat",(0.08,0.08,0.09),0.8,0.25); objs.append(o)

r = join_objects(objs, "Pistola")
export("Pistola", "pistola.glb")

# ════════════════════════════════════════════════════
#                    SUBFUSIL
# ════════════════════════════════════════════════════
print("🔫 Subfusil...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_cube_add(size=1, location=(0,0,0.04))
o=bpy.context.object; o.name="CuerpoSMG"; o.scale=(0.5,0.06,0.09)
bpy.ops.object.transform_apply(scale=True)
mat(o,"SMGBodyMat",(0.06,0.06,0.07),0.8,0.3); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.022, depth=0.44, location=(0.29,0,0.04))
o=bpy.context.object; o.name="CanonSMG"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"SMGBarrelMat",(0.05,0.05,0.05),0.9,0.15); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.033, depth=0.13, location=(0.47,0,0.04))
o=bpy.context.object; o.name="Silenciador"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"SilMat",(0.1,0.1,0.12),0.75,0.35); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.06,0,-0.09))
o=bpy.context.object; o.name="MangoSMG"; o.scale=(0.09,0.05,0.13)
bpy.ops.object.transform_apply(scale=True)
o.rotation_euler=(0,math.radians(-10),0)
mat(o,"SMGHandleMat",(0.1,0.07,0.05),0.1,0.9); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0.0,0,-0.09))
o=bpy.context.object; o.name="Cargador"; o.scale=(0.08,0.045,0.14)
bpy.ops.object.transform_apply(scale=True)
mat(o,"MagMat",(0.04,0.04,0.05),0.7,0.4); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(-0.38,0,0.035))
o=bpy.context.object; o.name="Culata"; o.scale=(0.14,0.04,0.07)
bpy.ops.object.transform_apply(scale=True)
mat(o,"StockMat",(0.1,0.07,0.05),0.2,0.8); objs.append(o)

r = join_objects(objs, "Subfusil")
export("Subfusil", "subfusil.glb")

# ════════════════════════════════════════════════════
#                  LANZACOHETE
# ════════════════════════════════════════════════════
print("🚀 LanzaCohete...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_cylinder_add(radius=0.095, depth=0.85, location=(0,0,0.04))
o=bpy.context.object; o.name="Tubo"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"TuboMat",(0.15,0.22,0.1),0.2,0.7); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.11, depth=0.07, location=(0.44,0,0.04))
o=bpy.context.object; o.name="Boca"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"MuzzleMat",(0.1,0.1,0.1),0.8,0.25); objs.append(o)

bpy.ops.mesh.primitive_cube_add(size=1, location=(0.05,0,-0.16))
o=bpy.context.object; o.name="MangoRL"; o.scale=(0.1,0.055,0.17)
bpy.ops.object.transform_apply(scale=True)
o.rotation_euler=(0,math.radians(-5),0)
mat(o,"RLHandleMat",(0.1,0.08,0.05),0.1,0.9); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.025, depth=0.2, location=(0.08,0,0.14))
o=bpy.context.object; o.name="Mira"; o.rotation_euler=(0,math.radians(90),0)
mat(o,"ScopeMat",(0.05,0.05,0.06),0.8,0.2); objs.append(o)

for i, x in enumerate([-0.3, -0.38]):
    bpy.ops.mesh.primitive_torus_add(major_radius=0.11, minor_radius=0.016,
                                      major_segments=14, minor_segments=8,
                                      location=(x,0,0.04))
    o=bpy.context.object; o.name=f"Anillo{i}"; o.rotation_euler=(math.radians(90),0,0)
    mat(o,f"RingMat{i}",(0.08,0.08,0.09),0.8,0.3); objs.append(o)

r = join_objects(objs, "LanzaCohete")
export("LanzaCohete", "lanzacohete.glb")

# ════════════════════════════════════════════════════
#                   BALAS
# ════════════════════════════════════════════════════
print("💛 Bala Normal...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_uv_sphere_add(radius=0.06, location=(0,0,0), segments=12, ring_count=8)
o=bpy.context.object; o.name="BalaCuerpo"; o.scale=(1,1,1.8)
bpy.ops.object.transform_apply(scale=True)
mat(o,"BalaBodyMat",(0.95,0.75,0.1),0.9,0.1,(1,0.85,0.2)); objs.append(o)

bpy.ops.mesh.primitive_cone_add(radius1=0.05, radius2=0.015, depth=0.06, location=(0,0,-0.12))
o=bpy.context.object; o.name="BalaCola"; o.rotation_euler=(math.radians(180),0,0)
mat(o,"BalaColaMat",(0.6,0.4,0.1),0.8,0.2); objs.append(o)

r = join_objects(objs, "BalaNormal")
export("BalaNormal", "balanormal_mesh.glb")

print("🔵 Bala Chica...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_uv_sphere_add(radius=0.035, location=(0,0,0), segments=10, ring_count=6)
o=bpy.context.object; o.name="BalaChicaCuerpo"; o.scale=(1,1,2.2)
bpy.ops.object.transform_apply(scale=True)
mat(o,"BalaChicaMat",(0.3,0.9,1.0),0.5,0.1,(0.3,0.9,1.0)); objs.append(o)

bpy.ops.mesh.primitive_cylinder_add(radius=0.012, depth=0.18, location=(0,0,-0.14))
o=bpy.context.object; o.name="Estela"
mat(o,"EstelaMat",(0.2,0.7,1.0),0,0,(0.2,0.7,1.0)); objs.append(o)

r = join_objects(objs, "BalaChica")
export("BalaChica", "balachica_mesh.glb")

print("🧨 Bala Bomba...")
clear_scene()
objs = []

bpy.ops.mesh.primitive_uv_sphere_add(radius=0.12, location=(0,0,0), segments=14, ring_count=10)
o=bpy.context.object; o.name="BombaCuerpo"
mat(o,"BombaMat",(0.12,0.12,0.14),0.6,0.4); objs.append(o)

bpy.ops.mesh.primitive_cone_add(radius1=0.06, radius2=0.01, depth=0.14, location=(0,0,0.15))
o=bpy.context.object; o.name="BombaPunta"
mat(o,"BombaPuntaMat",(0.7,0.3,0.05),0.7,0.2); objs.append(o)

bpy.ops.mesh.primitive_uv_sphere_add(radius=0.08, location=(0,0,0.01), segments=10, ring_count=8)
o=bpy.context.object; o.name="BombaGlow"
mat(o,"BombaGlowMat",(1,0.4,0),0,0,(1,0.4,0)); objs.append(o)

for i in range(4):
    ang = i * math.pi / 2
    bpy.ops.mesh.primitive_cube_add(size=1, location=(math.cos(ang)*0.1, math.sin(ang)*0.1, -0.1))
    o=bpy.context.object; o.name=f"Aleta{i}"; o.scale=(0.04,0.04,0.12)
    bpy.ops.object.transform_apply(scale=True)
    o.rotation_euler=(0,0,ang)
    mat(o,f"AletaMat{i}",(0.1,0.1,0.12),0.7,0.3); objs.append(o)

r = join_objects(objs, "BalaBomba")
export("BalaBomba", "balabomba_mesh.glb")

print("\n" + "═"*50)
print(f"🎉 ¡Todos los modelos generados exitosamente!")
print(f"📁 Carpeta: {OUTPUT_PATH}")
print("═"*50)
print("\nSiguientes pasos en Godot:")
print("1. Los .glb aparecen en Assets/Models/")
print("2. Arrastrá el .glb a la escena del jugador/enemigo/etc.")
print("3. Reemplazá el MeshInstance3D existente con el nuevo modelo")
