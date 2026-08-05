extends Weapon

@export var bala : PackedScene

func perform_attack(target):
	var direccion = (target.global_position - player.spawnpoint.global_position).normalized()

	var bullet = bala.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = player.spawnpoint.global_position + direccion * 1.2
	bullet.direccion = direccion
	bullet.damage = data.damage
	bullet.player_atack = PlayerStats.atack
	$Timer.start()
