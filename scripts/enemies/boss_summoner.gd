extends CharacterBody3D

@export var boss_name: String = "INVOCADOR OSCURO"
@export var speed: float = 3.5
@export var contact_damage: float = 10.0
@export var summon_cooldown: float = 4.0
@export var summon_count: int = 3
@export var keep_distance: float = 10.0

var player: Node3D = null
var attack_timer: float = 0.0
var summon_timer: float = 0.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	add_to_group("enemy")
	add_to_group("boss")
	player = get_tree().get_first_node_in_group("player")

	if health_component:
		health_component.max_health = 1200.0
		health_component.health = 1200.0
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
	if not is_on_floor():
		velocity += get_gravity() * delta
	summon_timer += delta

	var to_player = player.global_position - global_position
	var dist = to_player.length()
	var dir = to_player.normalized()
	dir.y = 0

	if dir.length() > 0.01:
		var target_angle = atan2(dir.x, dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)

	if dist < keep_distance:
		velocity = -dir * speed
	elif dist > keep_distance + 5.0:
		velocity = dir * speed
	else:
		velocity = Vector3(
			move_toward(velocity.x, 0, delta * speed),
			0,
			move_toward(velocity.z, 0, delta * speed)
		)

	move_and_slide()

	attack_timer += delta
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= 0.8:
				attack_timer = 0.0
				if collider.has_method("take_damage"):
					collider.take_damage(contact_damage)

	if summon_timer >= summon_cooldown:
		summon_timer = 0.0
		_spawn_minions()

func _spawn_minions() -> void:
	var minion_scene = load("res://scenes/enemigo.tscn")
	if minion_scene == null:
		return

	var slime_data = load("res://Resources/Enemigos/slime.tres")

	for i in range(summon_count):
		var minion = minion_scene.instantiate()
		get_tree().current_scene.add_child(minion)

		var angle = randf() * TAU
		var offset = Vector3(cos(angle), 0, sin(angle)) * randf_range(2.0, 5.0)
		minion.global_position = global_position + offset
		minion.global_position.y = 2.0
		minion.global_position.x = clamp(minion.global_position.x, -160.0, 160.0)
		minion.global_position.z = clamp(minion.global_position.z, -160.0, 160.0)

		if slime_data and "enemy_data" in minion:
			minion.enemy_data = slime_data

		var minutes = WaveManager.get_minutes()
		var health_mult = 1.0 + 0.2 * sqrt(minutes)
		if minion.has_method("reset_enemy"):
			minion.reset_enemy(health_mult)
		else:
			minion.visible = true
			minion.process_mode = Node.PROCESS_MODE_INHERIT

		EventBus.enemy_spawned.emit(minion)

func take_damage(damage_amount: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical, crit_tier)

func _on_health_changed(current: float, max_hp: float) -> void:
	EventBus.boss_health_changed.emit(current, max_hp)

func _on_boss_died() -> void:
	EventBus.boss_defeated.emit()
