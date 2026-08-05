extends Node
# Autoload: maneja el pool de enemigos y los spawns según la oleada activa del WaveManager.

@export var default_enemy_scene : PackedScene
@export var max_enemies : int = 200
@export var min_spawn_dist : float = 22.0
@export var max_spawn_dist : float = 45.0

var pool : Array = []
var spawn_timer : float = 0.0
var super_wave_fired_for : int = -1

func _ready() -> void:
	# Si no se asignó desde el editor, cargar la escena de enemigo por defecto
	if default_enemy_scene == null:
		default_enemy_scene = load("res://enemigo.tscn")
	await get_tree().physics_frame
	_build_pool()
	WaveManager.wave_started.connect(_on_wave_started)
	# Spawn inicial
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

	# Escalar vida según tiempo: sqrt para escalar rápido al inicio y luego suavizar
	var minutes = WaveManager.get_minutes()
	var health_mult = 1.0 + 0.45 * sqrt(minutes)

	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy(health_mult)
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT

	EventBus.enemy_spawned.emit(enemy)

func _get_free_enemy() -> Node:
	for e in pool:
		if e.process_mode == Node.PROCESS_MODE_DISABLED:
			return e
	return null
