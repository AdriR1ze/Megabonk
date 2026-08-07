extends Node3D

@export var player_scene: PackedScene = preload("res://scenes/player.tscn")

func _ready() -> void:
	if not multiplayer.has_multiplayer_peer():
		return

	var existing_player = $Player
	if is_instance_valid(existing_player):
		existing_player.queue_free()

	if multiplayer.is_server():
		_spawn_player(1)
		for peer_id in multiplayer.get_peers():
			_spawn_player(peer_id)
	else:
		var my_id = multiplayer.get_unique_id()
		_spawn_local_player(my_id)

func _spawn_local_player(peer_id: int) -> void:
	var player = player_scene.instantiate()
	player.name = "Player_" + str(peer_id)
	add_child(player)
	var spawn_pos = Vector3(randf_range(-5, 5), 0.325, randf_range(-5, 5))
	player.global_position = spawn_pos
	player.set_multiplayer_authority(peer_id)

@rpc("any_peer")
func _spawn_player(peer_id: int) -> void:
	if not multiplayer.is_server():
		return

	var player = player_scene.instantiate()
	player.name = "Player_" + str(peer_id)
	add_child(player, true)

	var spawn_pos = Vector3(randf_range(-5, 5), 0.325, randf_range(-5, 5))
	player.global_position = spawn_pos
	player.set_multiplayer_authority(peer_id)
