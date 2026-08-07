extends Node

var max_health : float = 100.0
var defense : float = 1.0
var move_speed : float = 1.0
var atack : float = 1.0
var atq_speed : float = 1.0
var crit_chance : float = 0.05
var crit_multiplier : float = 1.3
var evasion : float = 0.0
var xp_multiplicator : float = 1.0
var regen : float = 0.0
var projectile_speed : float = 1.0
var pierce_bonus : int = 0
var range_multiplier : float = 1.0
var area_multiplier : float = 1.0
var luck : float = 1.0
var dano_extra_chance : float = 0.0
var dano_extra_amount : float = 0.0

var level : int = 1
var xp : int = 0
var xp_needed : int = 5
var pending_levels : int = 0

signal level_up
signal xp_changed

func add_xp(amount: int) -> void:
	amount = int(amount * xp_multiplicator)
	xp += amount

	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = int(xp_needed * 1.4) + 2
		pending_levels += 1
		level_up.emit()

	EventBus.player_xp_changed.emit(xp, xp_needed, level)
	xp_changed.emit()

	if pending_levels > 0:
		UpgradeManager.offer_upgrades()

@rpc("authority")
func add_xp_rpc(amount: int) -> void:
	add_xp(amount)

func reset_for_new_run() -> void:
	max_health = 100.0
	defense = 1.0
	move_speed = 1.0
	atack = 1.0
	atq_speed = 1.0
	crit_chance = 0.05
	crit_multiplier = 1.3
	evasion = 0.0
	xp_multiplicator = 1.0
	regen = 0.0
	projectile_speed = 1.0
	pierce_bonus = 0
	range_multiplier = 1.0
	area_multiplier = 1.0
	luck = 1.0
	dano_extra_chance = 0.0
	dano_extra_amount = 0.0
	level = 1
	xp = 0
	xp_needed = 5
	pending_levels = 0
	SaveManager.apply_meta_bonuses()

func _ready() -> void:
	SaveManager.apply_meta_bonuses()
