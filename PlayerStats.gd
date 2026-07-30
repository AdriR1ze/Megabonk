extends Node

@export var move_speed : float = 1.0
@export var defense : float = 1.0
@export var atack : float = 1.0
@export var evasion : float = 1.0
@export var atq_speed : float = 1.0
@export var crit_chance : float = 0.0
@export var xp_multiplicator : float = 1.0


signal level_up

var level := 1
var xp := 0
var xp_needed := 4

func add_xp(amount):

	xp += amount
	print("XP ",xp)
	while xp >= xp_needed:

		xp -= xp_needed
		level += 1
		xp_needed = int(xp_needed * 1.5)

		level_up.emit()
