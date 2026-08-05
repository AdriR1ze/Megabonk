extends Node
class_name HealthComponent

@export var max_health := 35.0

var health := 35.0

@onready var parent = get_parent()

signal health_changed(current_health: float, max_health: float)
signal died

func _ready():
	health = max_health
	health_changed.emit(health, max_health)
	# Si el padre es el jugador, conectar al HUD mediante EventBus
	if parent.is_in_group("player"):
		health_changed.connect(func(cur, mx): EventBus.player_health_changed.emit(cur, mx))

func take_damage(damage: float, is_critical: bool = false) -> void:
	# Evasión (solo aplica al jugador)
	if parent.is_in_group("player") and randf() < PlayerStats.evasion:
		return
	health = max(0.0, health - damage)
	health_changed.emit(health, max_health)

	if parent.is_in_group("enemy"):
		EventBus.damage_dealt.emit(parent, damage, is_critical)

	if health <= 0.0:
		die()

func die() -> void:
	if parent.is_in_group("enemy"):
		# Recompensas con multiplicador de suerte
		var coin_chance = 0.6 * PlayerStats.luck
		var xp_reward = 1
		var coin_reward = 0
		if randf() <= coin_chance:
			coin_reward = 1
			GameManager.coins += 1
		PlayerStats.add_xp(xp_reward)
		EventBus.enemy_died.emit(parent, xp_reward, coin_reward)
	elif parent.is_in_group("player"):
		EventBus.player_died.emit()

	parent.visible = false
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	parent.global_position = Vector3(9999, 9999, 9999)
	died.emit()

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)

func reset_health(multiplier: float = 1.0) -> void:
	var base_hp = 35.0 if parent.is_in_group("enemy") else PlayerStats.max_health
	max_health = base_hp * multiplier
	health = max_health
	health_changed.emit(health, max_health)
