extends Node3D

@export_group("Dimensions")
@export var map_size: float = 400.0
@export var resolution: int = 200
@export var max_height: float = 60.0

@export_group("Noise")
@export var noise_seed: int = 42
@export var noise_scale: float = 0.0035

@export_group("Shape")
@export var flatness: float = 0.6
@export var ring_start: float = 0.2
@export var ring_peak: float = 0.68
@export var edge_wall: float = 40.0

@export var regenerate: bool:
	set(v):
		if v:
			_clear_and_generate()
			regenerate = false

func _clear_and_generate() -> void:
	for c in get_children():
		if c is MeshInstance3D or c is StaticBody3D:
			c.queue_free()
	await get_tree().process_frame
	_generate()

func _ready() -> void:
	_generate()

func _generate() -> void:
	var noise = FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.fractal_type = FastNoiseLite.FRACTAL_FBM
	noise.fractal_octaves = 6
	noise.fractal_lacunarity = 2.3
	noise.fractal_gain = 0.5
	noise.frequency = noise_scale

	var half = map_size / 2.0
	var step = map_size / float(resolution - 1)
	var total = resolution * resolution

	var verts = PackedVector3Array()
	verts.resize(total)
	var uvs = PackedVector2Array()
	uvs.resize(total)

	for z in range(resolution):
		for x in range(resolution):
			var wx = -half + x * step
			var wz = -half + z * step
			var h = _height(wx, wz, half, noise)
			verts[z * resolution + x] = Vector3(wx, h, wz)
			uvs[z * resolution + x] = Vector2(float(x) / resolution, float(z) / resolution)

	var indices = PackedInt32Array()
	for z in range(resolution - 1):
		for x in range(resolution - 1):
			var a = z * resolution + x
			var b = z * resolution + x + 1
			var c = (z + 1) * resolution + x
			var d = (z + 1) * resolution + x + 1
			indices.append_array([a, b, c, b, d, c])

	var norms = PackedVector3Array()
	norms.resize(total)
	for z in range(resolution):
		for x in range(resolution):
			var cx = clampi(x, 1, resolution - 2)
			var cz = clampi(z, 1, resolution - 2)
			var dx = verts[cz * resolution + cx + 1].y - verts[cz * resolution + cx - 1].y
			var dz = verts[(cz + 1) * resolution + cx].y - verts[(cz - 1) * resolution + cx].y
			norms[z * resolution + x] = Vector3(-dx, step * 2.0, -dz).normalized()

	var arr = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_NORMAL] = norms
	arr[Mesh.ARRAY_TEX_UV] = uvs
	arr[Mesh.ARRAY_INDEX] = indices

	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr)

	var mi = MeshInstance3D.new()
	mi.name = "TerrainMesh"
	mi.mesh = mesh

	var sm = ShaderMaterial.new()
	var shader = load("res://shaders/terrain.gdshader")
	if shader:
		sm.shader = shader
		sm.set_shader_parameter("grass_tex", load("res://hierba-textura-fluida-patron-cesped-natural_172107-1308.png"))
	mi.material_override = sm

	add_child(mi)

	if mi.mesh:
		mi.create_trimesh_collision()
		for sib in get_children():
			if sib is StaticBody3D and sib != mi:
				sib.name = "TerrainCollision"
				break

func _height(wx: float, wz: float, half: float, noise: FastNoiseLite) -> float:
	var dist = Vector2(wx, wz).length() / half
	dist = clamp(dist, 0.0, 1.0)

	var wx0 = wx * noise_scale
	var wz0 = wz * noise_scale
	var wx_warp = noise.get_noise_2d(wx0 + 5.2, wz0 + 3.1) * 35.0
	var wz_warp = noise.get_noise_2d(wx0 - 2.8, wz0 + 7.3) * 35.0
	var n = noise.get_noise_2d(wx0 + wx_warp * 0.01, wz0 + wz_warp * 0.01)

	var ridge = 1.0 - abs(n)
	ridge = pow(ridge, 1.8)

	var ring = smoothstep(ring_start, ring_peak, dist)
	ring = pow(ring, flatness + 0.3)

	var h = ridge * ring * max_height * 1.5
	h += n * ring * 14.0
	h += noise.get_noise_2d(wx * 0.04, wz * 0.04) * 3.0 * ring
	h += n * (1.0 - ring) * 5.0
	h -= (1.0 - smoothstep(0.0, 0.1, dist)) * 2.0

	var edge = smoothstep(0.85, 1.0, dist)
	h += edge * abs(noise.get_noise_2d(wx * 0.0025, wz * 0.0025)) * edge_wall

	return h
