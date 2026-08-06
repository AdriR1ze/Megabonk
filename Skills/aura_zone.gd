class_name AuraZone
extends Area3D

var damage := 1.0
var tick_interval := 0.5
var radius := 4.0
var color := Color(1.0, 0.4, 0.1, 0.35)

var _tick_timer: Timer

func _ready() -> void:
	collision_layer = 0
	collision_mask = 32769
	monitoring = true

	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	shape.shape = sphere
	add_child(shape)

	var mesh := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2.0
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.disable_receive_shadows = true
	sphere_mesh.material = mat
	mesh.mesh = sphere_mesh
	add_child(mesh)

	_tick_timer = Timer.new()
	_tick_timer.wait_time = tick_interval
	_tick_timer.autostart = true
	_tick_timer.timeout.connect(_on_tick)
	add_child(_tick_timer)
	_tick_timer.start()

func _on_tick() -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			var crits := _roll_crits()
			var dmg = damage * PlayerStats.atack * pow(PlayerStats.crit_multiplier, crits)
			body.take_damage(dmg, crits > 0, crits)

func _roll_crits() -> int:
	var chance := PlayerStats.crit_chance
	var crits := 0
	while chance >= 1.0:
		crits += 1
		chance -= 1.0
	if randf() < chance:
		crits += 1
	return crits
