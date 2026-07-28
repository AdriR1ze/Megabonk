extends Node3D

@export var enemy_scene: PackedScene
@export var max_enemies: int = 200
@export var spawn_interval: float = 1.0
@export var spawn_radius: float = 10.0
@export var spawn_on_start: int = 20

var pool: Array = []
var timer: Timer


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


func _on_timer_timeout():
	spawn_enemy()


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
