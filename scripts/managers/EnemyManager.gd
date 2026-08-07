extends Node

@export var default_enemy_scene : PackedScene
@export var boss_scene : PackedScene
@export var max_enemies : int = 200
@export var min_spawn_dist : float = 22.0
@export var max_spawn_dist : float = 45.0

var pool : Array = []
var spawn_timer : float = 0.0

var remaining_credits : float = 0.0
var credit_regen_multiplier : float = 1.0

var _all_enemy_types : Array[EnemyData] = []
var _all_boss_scenes : Array[PackedScene] = []

func _ready() -> void:
	if default_enemy_scene == null:
		default_enemy_scene = load("res://scenes/enemigo.tscn")
	if boss_scene == null:
		boss_scene = load("res://scenes/boss.tscn")

	_load_enemy_resources()
	EventBus.run_started.connect(_on_run_started)
	WaveManager.wave_started.connect(_on_wave_started)
	WaveManager.minute_passed.connect(_on_minute_passed)

func _load_enemy_resources() -> void:
	_all_enemy_types.clear()
	var dir = DirAccess.open("res://Resources/Enemigos/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var res = load("res://Resources/Enemigos/" + file_name)
				if res is EnemyData:
					_all_enemy_types.append(res)
			file_name = dir.get_next()
		dir.list_dir_end()

	_all_boss_scenes.clear()
	if boss_scene:
		_all_boss_scenes.append(boss_scene)
	var boss_dir_path = "res://Resources/Bosses/"
	if DirAccess.dir_exists_absolute(boss_dir_path):
		var boss_dir = DirAccess.open(boss_dir_path)
		if boss_dir:
			boss_dir.list_dir_begin()
			var bfile = boss_dir.get_next()
			while bfile != "":
				if not boss_dir.current_is_dir() and bfile.ends_with(".tscn"):
					var bscene = load(boss_dir_path + bfile)
					if bscene:
						_all_boss_scenes.append(bscene)
				bfile = boss_dir.get_next()
			boss_dir.list_dir_end()

func _on_run_started() -> void:
	for e in pool:
		if is_instance_valid(e):
			e.queue_free()
	pool.clear()
	remaining_credits = 0.0
	credit_regen_multiplier = 1.0
	spawn_timer = 0.0
	await get_tree().physics_frame
	if get_tree().current_scene == null:
		return
	_build_pool()

	for i in range(2):
		var enemy = _spawn_enemy(null)
		if enemy == null:
			break

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
		enemy.set_meta("pool_index", i)
		pool.append(enemy)

func _process(delta: float) -> void:
	if not _should_run():
		return

	if get_tree().paused or WaveManager.active_wave == null:
		return

	var wave : WaveData = WaveManager.active_wave
	remaining_credits += wave.credits_per_second * credit_regen_multiplier * delta

	spawn_timer += delta
	if spawn_timer >= wave.spawn_interval and remaining_credits >= 1.0:
		spawn_timer = 0.0
		_try_spend_credits(wave)

func _should_run() -> bool:
	return not _is_mp() or multiplayer.is_server()

func _is_mp() -> bool:
	return multiplayer.has_multiplayer_peer()

func _try_spend_credits(wave: WaveData) -> void:
	var available = _get_available_enemies(wave)
	if available.is_empty():
		return

	var enemy_data = _pick_random_enemy(available)
	if enemy_data.credit_cost <= 0:
		return
	if remaining_credits < enemy_data.credit_cost:
		return

	var affordable = int(remaining_credits) / enemy_data.credit_cost
	var count_in_tick = clampi(affordable, 1, 3)

	for i in range(count_in_tick):
		if remaining_credits < enemy_data.credit_cost:
			break
		if _spawn_enemy(enemy_data) != null:
			remaining_credits -= enemy_data.credit_cost
			EventBus.credits_changed.emit(remaining_credits, 0)

func _pick_random_enemy(available: Array) -> EnemyData:
	var total_weight = 0.0
	for e in available:
		total_weight += 1.0 / max(float(e.credit_cost), 1.0)

	var roll = randf() * total_weight
	var cumulative = 0.0
	for e in available:
		cumulative += 1.0 / max(float(e.credit_cost), 1.0)
		if roll <= cumulative:
			return e
	return available[0]

func _get_available_enemies(wave: WaveData) -> Array:
	if not wave.available_enemies.is_empty():
		return wave.available_enemies
	if not _all_enemy_types.is_empty():
		return _all_enemy_types
	return []

func _spawn_enemy(enemy_data: EnemyData) -> Node:
	var enemy = _get_free_enemy()
	if enemy == null:
		return null

	if enemy_data:
		enemy.enemy_data = enemy_data

	var player = get_tree().get_first_node_in_group("player")
	var center : Vector3 = player.global_position if is_instance_valid(player) else Vector3.ZERO

	var angle = randf() * TAU
	var distance = randf_range(min_spawn_dist, max_spawn_dist)
	var offset = Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)
	var pos = center + offset
	pos.x = clamp(pos.x, -160.0, 160.0)
	pos.z = clamp(pos.z, -160.0, 160.0)
	pos.y = 2.0

	if not enemy.is_inside_tree():
		get_tree().current_scene.add_child(enemy)

	enemy.global_position = pos

	var minutes = WaveManager.get_minutes()
	var health_mult = 1.0 + 0.2 * sqrt(minutes)

	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy(health_mult)
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT

	EventBus.enemy_spawned.emit(enemy)

	if _is_mp():
		var pool_index = enemy.get_meta("pool_index", -1)
		if pool_index >= 0:
			_activate_enemy_on_client.rpc(pool_index, pos, health_mult)

	return enemy

func _on_wave_started(wave_index: int, wave_data: WaveData) -> void:
	remaining_credits += wave_data.starting_credits
	spawn_timer = 0.0
	EventBus.credits_changed.emit(remaining_credits, 0)

func _on_minute_passed(minute: int) -> void:
	if WaveManager.active_wave == null:
		return
	remaining_credits *= 2.0
	credit_regen_multiplier *= 2.0
	EventBus.credits_changed.emit(remaining_credits, 0)
	EventBus.minute_event.emit(minute)
	_spawn_random_boss()

func get_credits() -> float:
	return remaining_credits

func _spawn_random_boss() -> void:
	var wave = WaveManager.active_wave
	var boss_list : Array[PackedScene] = []
	if wave and not wave.bosses.is_empty():
		boss_list = wave.bosses
	else:
		boss_list = _all_boss_scenes

	boss_list = boss_list.filter(func(s): return s != null)
	if boss_list.is_empty():
		return

	var chosen = boss_list[randi() % boss_list.size()]

	var root = get_tree().current_scene
	var boss = chosen.instantiate()
	root.add_child(boss)

	var player = get_tree().get_first_node_in_group("player")
	var center : Vector3 = player.global_position if is_instance_valid(player) else Vector3.ZERO

	var angle = randf() * TAU
	var pos = center + Vector3(cos(angle) * 30.0, 0.0, sin(angle) * 30.0)
	pos.x = clamp(pos.x, -130.0, 130.0)
	pos.z = clamp(pos.z, -130.0, 130.0)
	pos.y = 2.0

	boss.global_position = pos

func _get_free_enemy() -> Node:
	pool = pool.filter(func(e): return is_instance_valid(e))
	for e in pool:
		if e.process_mode == Node.PROCESS_MODE_DISABLED:
			return e
	return null

func _on_run_started_local() -> void:
	for e in pool:
		if is_instance_valid(e):
			e.queue_free()
	pool.clear()
	await get_tree().physics_frame
	if get_tree().current_scene == null:
		return
	_build_pool()

@rpc("authority")
func _activate_enemy_on_client(pool_index: int, pos: Vector3, health_mult: float) -> void:
	if pool_index < 0 or pool_index >= pool.size():
		return
	var enemy = pool[pool_index]
	if not is_instance_valid(enemy):
		return
	enemy.global_position = pos
	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy(health_mult)
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT
	EventBus.enemy_spawned.emit(enemy)
