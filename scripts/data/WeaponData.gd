extends Resource
class_name WeaponData

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export_category("Identificación")
@export var weapon_name := ""
@export var id : int
@export var texture_sprite : Texture2D
@export var scene : PackedScene # Escena del área del arma que se acopla al player

@export_category("Estadísticas Base")
@export var damage : float = 10.0
@export var cooldown : float = 0.5
@export var rango : float = 7.0
@export var projectile_speed : float = 35.0
@export var pierce : int = 1
@export var knockback : float = 0.0
@export var crit_chance : float = 0.05
@export var crit_multiplier : float = 1.5
@export var projectile_scale : float = 1.0
@export var rarity : Rarity = Rarity.COMMON

@export_category("Crecimiento por Nivel")
@export var crecimiento_damage : float = 2.0
@export var crecimiento_rango : float = 0.5
@export var crecimiento_cooldown : float = 0.04
@export var crecimiento_pierce : int = 0
@export var crecimiento_crit_chance : float = 0.01

var level := 1

func upgrade():
	level += 1
	damage += crecimiento_damage
	rango += crecimiento_rango
	cooldown = max(0.05, cooldown - crecimiento_cooldown)
	pierce += crecimiento_pierce
	crit_chance = min(1.0, crit_chance + crecimiento_crit_chance)
