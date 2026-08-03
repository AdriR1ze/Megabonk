extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 200
@export var spawn_interval: float = 1.0
@export var spawn_radius: float = 10.0
@export var spawn_on_start: int = 20
@export var amount_enemies : int
var pool: Array = []
var timer: Timer
var timer_wave : Timer
var timer_incremento : Timer
func _ready():
	randomize()
	await get_tree().process_frame

	# Crear el pool
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

	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.autostart = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer_wave = Timer.new()
	timer_wave.wait_time = 300
	timer_wave.autostart = true
	timer_wave.timeout.connect(_on_timer_wave_timeout)
	add_child(timer_wave)
	timer_incremento = Timer.new()
	timer_incremento.wait_time = 30
	timer_incremento.autostart = true
	timer_incremento.timeout.connect(_on_timer_incremento_timeout)
	add_child(timer_incremento)


func _on_timer_timeout():
	for i in range(amount_enemies):
		spawn_enemy()
func _on_timer_wave_timeout():
	for i in range(amount_enemies * 5):
		spawn_enemy()
func _on_timer_incremento_timeout():
	amount_enemies *= 1.1


func spawn_enemy():
	var enemy = get_free_enemy()

	if enemy == null:
		return

	var angle = randf() * TAU
	var distance = randf() * spawn_radius

	var offset = Vector3(
		cos(angle) * distance,
		0,
		sin(angle) * distance
	)

	enemy.global_position = global_position + offset

	if enemy.has_method("reset_enemy"):
		enemy.reset_enemy()
	else:
		enemy.visible = true
		enemy.process_mode = Node.PROCESS_MODE_INHERIT


func get_free_enemy():
	for enemy in pool:
		if enemy.process_mode == Node.PROCESS_MODE_DISABLED:
			return enemy

	return null
