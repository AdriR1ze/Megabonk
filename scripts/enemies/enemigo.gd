extends CharacterBody3D

@export var attack_cooldown: float = 0.8

var enemy_data : EnemyData = null
var attack_timer: float = 0.0
var player : Node3D = null

@onready var health_component : HealthComponent = $HealthComponent
@onready var mesh_instance : MeshInstance3D = $MeshInstance3D
@onready var collision_shape : CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not player.is_inside_tree():
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	var dir : Vector3 = (player.global_position - global_position).normalized()
	var spd = enemy_data.speed if enemy_data else 6.8
	velocity = dir * spd
	move_and_slide()

	var cd = enemy_data.attack_cooldown if enemy_data else attack_cooldown
	attack_timer += delta
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= cd:
				attack_timer = 0.0
				var dmg = enemy_data.damage if enemy_data else 10.0
				if collider.has_method("take_damage"):
					collider.take_damage(dmg)

func take_damage(damage_amount: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical, crit_tier)

func reset_enemy(health_multiplier: float = 1.0) -> void:
	if not is_inside_tree():
		await ready
	if health_component:
		var base_hp = enemy_data.base_hp if enemy_data else 50.0
		health_component.max_health = base_hp * health_multiplier
		health_component.health = base_hp * health_multiplier
	_apply_model()
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	attack_timer = 0.0
	if is_inside_tree():
		player = get_tree().get_first_node_in_group("player")

func _apply_model() -> void:
	if not mesh_instance or not enemy_data:
		return

	var mesh: Mesh = null
	var scl = enemy_data.model_scale

	match enemy_data.model_shape:
		"box":
			var box = BoxMesh.new()
			box.size = scl
			mesh = box
		"sphere":
			var sphere = SphereMesh.new()
			sphere.radius = scl.x
			sphere.height = scl.y
			mesh = sphere
		"capsule", _:
			var capsule = CapsuleMesh.new()
			capsule.radius = scl.x
			capsule.height = scl.y
			mesh = capsule

	mesh_instance.mesh = mesh

	var mat = StandardMaterial3D.new()
	mat.albedo_color = enemy_data.model_color
	mat.roughness = 0.55
	mat.emission_enabled = true
	mat.emission = enemy_data.model_color * 0.25
	mat.emission_energy_multiplier = 0.6
	mesh_instance.material_override = mat

	if collision_shape:
		var shape = collision_shape.shape
		if shape is CapsuleShape3D:
			shape.radius = scl.x
			shape.height = scl.y
		elif shape is BoxShape3D:
			shape.size = scl
