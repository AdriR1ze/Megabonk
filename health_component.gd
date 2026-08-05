extends Node
class_name HealthComponent

@export var max_health := 35.0

var health := 35.0

@onready var parent = get_parent()

signal health_changed(current_health: float, max_health: float)

func _ready():
	health = max_health
	health_changed.emit(health, max_health)

func take_damage(damage):
	health = max(0.0, health - damage)
	health_changed.emit(health, max_health)

	if health <= 0:
		die()

func die():
	if parent.is_in_group("enemy"):
		if randf() <= 0.6:
			GameManager.coins += 1
		PlayerStats.add_xp(1)

	parent.visible = false
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	parent.global_position = Vector3(9999, 9999, 9999)

func reset_health(multiplier: float = 1.0):
	var base_hp = 35.0 if parent.is_in_group("enemy") else 100.0
	max_health = base_hp * multiplier
	health = max_health
	health_changed.emit(health, max_health)
