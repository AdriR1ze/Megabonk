extends Area3D
class_name Weapon

@export var data: WeaponData
@export var player: Node3D

var enemies_in_range: Array = []
var mas_cercano: Node3D

func _ready():
	actualizar_stats()
	$Timer.one_shot = false
	$Timer.stop()

	ItemManager.stats_changed.connect(_on_stats_change)

func actualizar_stats():
	$Timer.wait_time = data.cooldown / PlayerStats.atq_speed

	var shape = $CollisionShape3D.shape
	if shape is SphereShape3D:
		shape.radius = data.rango


func _on_body_entered(body):
	if body.is_in_group("enemy"):
		if !enemies_in_range.has(body):
			enemies_in_range.append(body)

		if $Timer.is_stopped():
			attack()
			$Timer.start()


func _on_body_exited(body):
	if body.is_in_group("enemy"):
		enemies_in_range.erase(body)

		if enemies_in_range.is_empty():
			$Timer.stop()


func _on_timer_timeout():
	attack()


func attack():
	enemies_in_range = enemies_in_range.filter(
		func(e): return is_instance_valid(e)
	)

	if enemies_in_range.is_empty():
		$Timer.stop()
		return

	var distancia_minima := INF
	mas_cercano = null

	for enemigo in enemies_in_range:
		var d = global_position.distance_to(enemigo.global_position)

		if d < distancia_minima:
			distancia_minima = d
			mas_cercano = enemigo

	if mas_cercano != null:
		perform_attack(mas_cercano)


func perform_attack(target):
	pass


func _on_stats_change():
	$Timer.wait_time = data.cooldown / PlayerStats.atq_speed


func upgrade():
	data.upgrade()
	actualizar_stats()
