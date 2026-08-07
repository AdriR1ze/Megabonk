extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 200
@export var spawn_interval: float = 1.0
@export var spawn_radius: float = 10.0
@export var spawn_on_start: int = 20
@export var amount_enemies : int
var pool: Array = []
var timer: Timer
var timer_super_wave : Timer
var timer_incremento : Timer
var total_elapsed_time: float = 0.0

func _ready():
	randomize()
	await get_tree().process_frame

	# Crear el pool de enemigos
	for i in range(max_enemies):
		var enemy = enemy_scene.instantiate()
		get_parent().add_child(enemy)
		enemy.visible = false
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		enemy.global_position = Vector3(9999, 9999, 9999)
		pool.append(enemy)

	# Spawnear algunos al empezar
	for i in range(spawn_on_start):
		spawn_enemy()

	# Timer para spawn regular
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

	# Timer para super oleadas cada minuto (60 segundos)
	timer_super_wave = Timer.new()
	timer_super_wave.wait_time = 60.0
	timer_super_wave.autostart = true
	timer_super_wave.timeout.connect(_on_timer_super_wave_timeout)
	add_child(timer_super_wave)

	# Timer para incrementar la cantidad de spawn regular cada 30 segundos
	timer_incremento = Timer.new()
	timer_incremento.wait_time = 30.0
	timer_incremento.autostart = true
	timer_incremento.timeout.connect(_on_timer_incremento_timeout)
	add_child(timer_incremento)

func _process(delta: float) -> void:
	if not get_tree().paused:
		total_elapsed_time += delta

func _on_timer_timeout():
	for i in range(amount_enemies):
		spawn_enemy()

func _on_timer_super_wave_timeout():
	# Super oleada: spawnear 12 enemigos al instante alrededor del jugador
	print("¡Super oleada del minuto!")
	for i in range(12):
		spawn_enemy()

func _on_timer_incremento_timeout():
	amount_enemies = int(amount_enemies * 1.1) + 1

func spawn_enemy():
	var enemy = get_free_enemy()
	if enemy == null:
		return

	# Obtener jugador para spawnear alrededor de él
	var player = get_tree().get_first_node_in_group("player")
	var spawn_center = player.global_position if is_instance_valid(player) else global_position

	var angle = randf() * TAU
	# Distancia mínima de 22.0 y máxima de 45.0 para que no aparezcan pegados pero sí cerca
	var distance = randf_range(22.0, 45.0)

	var offset = Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)

	# Limitar la posición al área del mapa (-95 a 95 en X y Z para no salir de los muros)
	var spawn_pos = spawn_center + offset
	spawn_pos.x = clamp(spawn_pos.x, -160.0, 160.0)
	spawn_pos.z = clamp(spawn_pos.z, -160.0, 160.0)
	# Forzar altura del suelo
	spawn_pos.y = 2.0

	if not enemy.is_inside_tree():
		await get_tree().process_frame
		if not enemy.is_inside_tree():
			return

	enemy.global_position = spawn_pos

	# Escalado de vida: aumenta más rápido al principio, pero luego se desacelera (raíz cuadrada)
	var minutes = total_elapsed_time / 60.0
	var health_mult = 1.0 + 0.45 * sqrt(minutes)

	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy(health_mult)
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT

func get_free_enemy():
	for enemy in pool:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			return enemy
	return null
