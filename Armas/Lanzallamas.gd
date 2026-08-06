extends Weapon

@export var bala : PackedScene

func perform_attack(target):
	var base = (target.global_position - player.spawnpoint.global_position).normalized()
	var dir = base.rotated(Vector3.UP, randf_range(-0.1, 0.1))
	dir = dir.rotated(Vector3.RIGHT, randf_range(-0.06, 0.06)).normalized()

	var bullet = bala.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = player.spawnpoint.global_position + dir * 1.2
	bullet.direccion = dir
	bullet.damage = data.damage
	bullet.player_atack = PlayerStats.atack

	$Timer.start()
