extends Node
class_name HealthComponent

@export var max_health := 1.0

var health := 1.0

@onready var parent = get_parent()

func _ready():
	health = max_health

func take_damage(damage):
	health -= damage

	if health <= 0:
		die()

func die():
	if parent.is_in_group("enemy"):
		GameManager.coins += randi_range(1, 3)
		PlayerStats.add_xp(3)

	parent.visible = false
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	parent.global_position = Vector3(9999, 9999, 9999)

func reset_health():
	health = max_health
