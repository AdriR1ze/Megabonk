extends Resource
class_name WeaponData

@export var weapon_name := ""
@export var scene : PackedScene

@export var damage : float = 10
@export var cooldown : float = 0.5
@export var rango : float = 5.0

@export var crecimiento_damage : float = 2
@export var crecimiento_rango : float = 0.5
@export var crecimiento_cooldown : float = 0.05

var level := 1

func upgrade():
	level += 1
	damage += crecimiento_damage
	rango += crecimiento_rango
	cooldown = max(0.05, cooldown - crecimiento_cooldown)
