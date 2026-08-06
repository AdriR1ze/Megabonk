extends Node
# Autoload: maneja el pool de enemigos y los spawns según la oleada activa del WaveManager.

@export var default_enemy_scene : PackedScene
@export var boss_scene : PackedScene
@export var max_enemies : int = 200
@export var min_spawn_dist : float = 22.0
@export var max_spawn_dist : float = 45.0

var pool : Array = []
var spawn_timer : float = 0.0
var super_wave_fired_for : int = -1
var boss_spawned_for_wave : int = -1

func _ready() -> void:
	if default_enemy_scene == null:
		default_enemy_scene = load("res://enemigo.tscn")
	if boss_scene == null:
		boss_scene = load("res://boss.tscn")

	EventBus.run_started.connect(_on_run_started)
	WaveManager.wave_started.connect(_on_wave_started)

func _on_run_started() -> void:
	# El pool se construye cuando empieza la partida (la escena de mundo ya es current_scene),
	# no en el arranque del juego, que ahora ocurre en el menú principal.
	for e in pool:
		if is_instance_valid(e):
			e.queue_free()
	pool.clear()
	await get_tree().physics_frame
	if get_tree().current_scene == null:
		return
	_build_pool()

	for i in range(2):
		spawn_enemy()

func _build_pool() -> void:
	var scene = default_enemy_scene
	if scene == null:
		push_error("EnemyManager: default_enemy_scene no asignado.")
		return
	var root = get_tree().current_scene
	for i in range(max_enemies):
		var enemy = scene.instantiate()
		root.add_child(enemy)
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy.global_position = Vector3(9999, 9999, 9999)
		pool.append(enemy)

func _process(delta: float) -> void:
	if get_tree().paused or WaveManager.active_wave == null:
		return
	spawn_timer += delta
	var wave : WaveData = WaveManager.active_wave
	if spawn_timer >= wave.spawn_interval:
		spawn_timer = 0.0
		for i in range(wave.amount_per_spawn):
			spawn_enemy()

func _on_wave_started(wave_index: int, wave_data: WaveData) -> void:
	if wave_data.is_super_wave and super_wave_fired_for != wave_index:
		super_wave_fired_for = wave_index
		print("¡Super oleada! — ", wave_data.wave_name)
		EventBus.super_wave_triggered.emit()
		for i in range(wave_data.super_wave_amount):
			spawn_enemy()

	# Spawn del Boss en la oleada de Élite o Boss (o cada 3 oleadas)
	if (wave_data.wave_name.contains("BOSS") or wave_index >= 3) and boss_spawned_for_wave != wave_index:
		boss_spawned_for_wave = wave_index
		spawn_boss()

func spawn_boss() -> void:
	if boss_scene == null:
		boss_scene = load("res://boss.tscn")
	if boss_scene == null:
		return

	var root = get_tree().current_scene
	var boss = boss_scene.instantiate()
	root.add_child(boss)

	var player = get_tree().get_first_node_in_group("player")
	var center : Vector3 = player.global_position if is_instance_valid(player) else Vector3.ZERO

	var angle = randf() * TAU
	var pos = center + Vector3(cos(angle) * 30.0, 0.0, sin(angle) * 30.0)
	pos.x = clamp(pos.x, -90.0, 90.0)
	pos.z = clamp(pos.z, -90.0, 90.0)
	pos.y = 0.0

	boss.global_position = pos

func spawn_enemy() -> void:
	var enemy = _get_free_enemy()
	if enemy == null:
		return

	var player = get_tree().get_first_node_in_group("player")
	var center : Vector3 = player.global_position if is_instance_valid(player) else Vector3.ZERO

	var angle = randf() * TAU
	var distance = randf_range(min_spawn_dist, max_spawn_dist)
	var offset = Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
	var pos = center + offset
	pos.x = clamp(pos.x, -95.0, 95.0)
	pos.z = clamp(pos.z, -95.0, 95.0)
	pos.y = 1.0

	enemy.global_position = pos

	var minutes = WaveManager.get_minutes()
	var health_mult = 1.0 + 0.2 * sqrt(minutes)

	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy(health_mult)
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT

	EventBus.enemy_spawned.emit(enemy)

func _get_free_enemy() -> Node:
	pool = pool.filter(func(e): return is_instance_valid(e))
	for e in pool:
		if e.process_mode == Node.PROCESS_MODE_DISABLED:
			return e
	return null
