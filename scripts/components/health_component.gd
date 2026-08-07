extends Node
class_name HealthComponent

@export var max_health := 50.0

var health := 50.0

@onready var parent = get_parent()

signal health_changed(current_health: float, max_health: float)
signal died

func _ready():
	health = max_health
	health_changed.emit(health, max_health)
	# Si el padre es el jugador, conectar al HUD mediante EventBus
	if parent.is_in_group("player"):
		health_changed.connect(func(cur, mx): EventBus.player_health_changed.emit(cur, mx))

func take_damage(damage: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	# Evasión (solo aplica al jugador)
	if parent.is_in_group("player") and randf() < PlayerStats.evasion:
		return
	health = max(0.0, health - damage)
	health_changed.emit(health, max_health)

	if parent.is_in_group("enemy"):
		EventBus.damage_dealt.emit(parent, damage, is_critical, crit_tier)

	if health <= 0.0:
		die()

func die() -> void:
	if parent.is_in_group("enemy"):
		var minutes = WaveManager.get_minutes()
		
		var ed = parent.get("enemy_data") if "enemy_data" in parent else null
		var xp_reward = ed.xp_reward if ed else (1 + int(minutes * 0.5))
		var coin_chance = ed.coin_chance if ed else min(0.95, (0.6 + minutes * 0.05) * PlayerStats.luck)
		var coin_reward = 0
		if randf() <= coin_chance:
			coin_reward = 1 + int(minutes * 0.35)
		
		if parent.is_in_group("boss"):
			xp_reward += 25
			coin_reward += 35
			_spawn_boss_loot()
		
		if coin_reward > 0:
			GameManager.coins += coin_reward
			
		PlayerStats.add_xp(xp_reward)
		EventBus.enemy_died.emit(parent, xp_reward, coin_reward)
	elif parent.is_in_group("player"):
		EventBus.player_died.emit()

	parent.visible = false
	parent.process_mode = Node.PROCESS_MODE_DISABLED
	parent.global_position = Vector3(9999, 9999, 9999)
	died.emit()

func _spawn_boss_loot() -> void:
	var loot_scene = load("res://scenes/boss_loot.tscn")
	if not loot_scene:
		return
	var loot = loot_scene.instantiate()
	get_tree().current_scene.add_child(loot)
	loot.global_position = parent.global_position + Vector3(0, 1.5, 0)

func heal(amount: float) -> void:
	health = min(max_health, health + amount)
	health_changed.emit(health, max_health)

func reset_health(multiplier: float = 1.0) -> void:
	var base_hp = max_health if parent.is_in_group("enemy") else PlayerStats.max_health
	max_health = base_hp * multiplier
	health = max_health
	health_changed.emit(health, max_health)
