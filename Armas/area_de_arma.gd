extends Area3D
signal shoot(direccion)

var enemies_in_range : Array = []
var mas_cercano : Node3D
var distancia_minima = INF
var direccion : Vector3

@export var bala : PackedScene
@export var cooldown := 0.5
@export var player : Node3D
@export var data : WeaponData

func _ready():
	actualizar_stats()
	$Timer.one_shot = false
	$Timer.stop()
	ItemManager.stats_changed.connect(_on_stats_change)

func actualizar_stats():
	cooldown = data.cooldown
	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		shape.radius = data.rango
	$Timer.wait_time = cooldown / PlayerStats.atq_speed


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		enemies_in_range.append(body)
		if enemies_in_range.size() == 1:
			disparar()
			$Timer.start()

func _on_timer_timeout() -> void:

	disparar()

func disparar():
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	if enemies_in_range.is_empty():
		return

	distancia_minima = INF
	mas_cercano = null

	for enemigo in enemies_in_range:
		var distancia_actual = global_position.distance_to(enemigo.global_position)
		if distancia_actual < distancia_minima:
			distancia_minima = distancia_actual
			mas_cercano = enemigo

	if mas_cercano == null:
		return

	direccion = (mas_cercano.global_position - player.spawnpoint.global_position).normalized()
	var bullet = bala.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.direccion = direccion
	bullet.global_position = player.spawnpoint.global_position
	bullet.global_position = player.spawnpoint.global_position + direccion * 1.2
	bullet.direccion = direccion
	bullet.damage = data.damage
	bullet.player_atack = PlayerStats.atack

	$Timer.start()

func _on_stats_change():
	$Timer.wait_time = data.cooldown / PlayerStats.atq_speed

func upgrade():
	data.upgrade()
	actualizar_stats()
