extends CharacterBody3D

@export var boss_name: String = "MEGABOSS DEMONIACO"
@export var speed: float = 4.5
@export var contact_damage: float = 20.0
@export var laser_damage: float = 25.0
@export var laser_cooldown: float = 4.0

var player: Node3D = null
var attack_timer: float = 0.0
var laser_timer: float = 0.0
var is_charging_laser: bool = false
var is_firing_laser: bool = false

@onready var health_component: HealthComponent = $HealthComponent
@onready var laser_mesh: MeshInstance3D = $LaserMesh
@onready var laser_area: Area3D = $LaserArea
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	player = get_tree().get_first_node_in_group("player")

	if laser_mesh:
		laser_mesh.visible = false
	if laser_area:
		laser_area.monitoring = false

	if health_component:
		health_component.max_health = 1000.0
		health_component.health = 1000.0
		health_component.health_changed.connect(_on_health_changed)
		health_component.died.connect(_on_boss_died)

	await get_tree().process_frame
	EventBus.boss_spawned.emit(self, boss_name)
	EventBus.boss_health_changed.emit(health_component.health, health_component.max_health)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	laser_timer += delta

	# Orientar todo el Boss (y sus hijos LaserMesh y LaserArea) hacia la posición del jugador
	var dir = (player.global_position - global_position).normalized()
	dir.y = 0

	if dir.length() > 0.01 and not is_firing_laser:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 6.0)

	# Si no está disparando el láser en ráfaga, perseguir al jugador
	if not is_charging_laser and not is_firing_laser:
		velocity = dir * speed
		move_and_slide()

		# Daño por contacto
		attack_timer += delta
		for i in get_slide_collision_count():
			var col = get_slide_collision(i)
			var collider = col.get_collider()
			if collider and collider.is_in_group("player"):
				if attack_timer >= 0.8:
					attack_timer = 0.0
					if collider.has_method("take_damage"):
						collider.take_damage(contact_damage)

	# Iniciar ataque láser cuando expire el cooldown
	if laser_timer >= laser_cooldown and not is_charging_laser and not is_firing_laser:
		_start_laser_attack()

func _start_laser_attack() -> void:
	laser_timer = 0.0
	is_charging_laser = true

	# Telégrafo visual: activar haz rojo semitransparente apuntando al jugador
	if laser_mesh:
		laser_mesh.visible = true
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(1.0, 0.1, 0.1, 0.35)
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.emission_enabled = true
		mat.emission = Color(1.0, 0.0, 0.0)
		mat.emission_energy_multiplier = 1.0
		laser_mesh.material_override = mat

	# Esperar 0.8s cargando el ataque
	await get_tree().create_timer(0.8).timeout

	if not is_instance_valid(self) or process_mode == Node.PROCESS_MODE_DISABLED:
		return

	is_charging_laser = false
	is_firing_laser = true

	# Material de disparo intenso
	if laser_mesh:
		var fire_mat = StandardMaterial3D.new()
		fire_mat.albedo_color = Color(1.0, 0.3, 0.1, 0.95)
		fire_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fire_mat.emission_enabled = true
		fire_mat.emission = Color(1.0, 0.3, 0.0)
		fire_mat.emission_energy_multiplier = 6.0
		laser_mesh.material_override = fire_mat

	if laser_area:
		laser_area.monitoring = true

	# Durante el disparo, lanzar además ráfagas de proyectiles láser directamente hacia la posición del jugador
	var target_player_pos = player.global_position if is_instance_valid(player) else global_position
	for i in range(4):
		if not is_instance_valid(self) or process_mode == Node.PROCESS_MODE_DISABLED:
			break
		if is_instance_valid(player):
			target_player_pos = player.global_position
		_shoot_laser_bolt(target_player_pos)
		
		# Daño del área del láser
		if laser_area:
			for body in laser_area.get_overlapping_bodies():
				if body and body.is_in_group("player") and body.has_method("take_damage"):
					body.take_damage(laser_damage)
					
		await get_tree().create_timer(0.3).timeout

	# Finalizar ataque láser
	if is_instance_valid(self):
		is_firing_laser = false
		if laser_mesh:
			laser_mesh.visible = false
		if laser_area:
			laser_area.monitoring = false

# Disparar ráfaga de proyectiles láser dirigidos al jugador
func _shoot_laser_bolt(target_pos: Vector3) -> void:
	var bolt = Area3D.new()
	bolt.collision_layer = 0
	bolt.collision_mask = 1 # Golpea al jugador

	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1.2
	mesh.mesh = sphere

	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.1, 0.1, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.2, 0.0)
	mat.emission_energy_multiplier = 5.0
	mesh.material_override = mat
	bolt.add_child(mesh)

	var col = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.6
	col.shape = shape
	bolt.add_child(col)

	get_tree().current_scene.add_child(bolt)

	var spawn_pos = global_position + Vector3(0, 2.0, 0)
	var shoot_dir = (target_pos - spawn_pos).normalized()
	bolt.global_position = spawn_pos

	bolt.body_entered.connect(func(body):
		if body and body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(laser_damage)
			bolt.queue_free()
	)

	var tween = bolt.create_tween()
	tween.tween_property(bolt, "global_position", spawn_pos + shoot_dir * 45.0, 1.2)
	tween.chain().tween_callback(bolt.queue_free)

func take_damage(damage_amount: float, is_critical: bool = false) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical)

func _on_health_changed(current: float, max_hp: float) -> void:
	EventBus.boss_health_changed.emit(current, max_hp)

func _on_boss_died() -> void:
	EventBus.boss_defeated.emit()
