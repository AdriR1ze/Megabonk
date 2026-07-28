extends Node3D

@export var chest_scene: PackedScene
@export var cantidad: int = 5
@export var radio: float = 20.0

func _ready():
	await get_tree().process_frame

	for i in range(cantidad):
		var chest = chest_scene.instantiate()

		var angle = randf() * TAU
		var dist = randf() * radio

		var pos = Vector3(
			cos(angle) * dist,
			0,
			sin(angle) * dist
		)

		get_parent().add_child(chest)
		chest.global_position = global_position + pos
