extends Weapon

@export var bala : PackedScene

const PELLETS := 10
const SPREAD := 0.18

func perform_attack(target):
	var base = (target.global_position - player.spawnpoint.global_position).normalized()

	for i in PELLETS:
		var dir = base.rotated(Vector3.UP, randf_range(-SPREAD, SPREAD))
		dir = dir.rotated(Vector3.RIGHT, randf_range(-SPREAD * 0.4, SPREAD * 0.4)).normalized()

		var bullet = bala.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = player.spawnpoint.global_position + base * 1.2
		bullet.direccion = dir
		bullet.damage = data.damage / PELLETS
		bullet.player_atack = PlayerStats.atack
		bullet.pierce = data.pierce

	$Timer.start()
