extends Resource
class_name CharacterData

@export var character_name : String = "Megabonk"
@export var description : String = "El soldado orbital definitivo."
@export var icon : Texture2D

@export_category("Estadísticas Iniciales")
@export var max_health : float = 100.0
@export var defense : float = 1.0 # Reducción plana de daño
@export var speed_multiplier : float = 1.0
@export var attack_multiplier : float = 1.0
@export var crit_chance : float = 0.05
@export var regen : float = 0.0 # Vida regenerada por segundo
@export var magnet_radius : float = 5.0 # Radio de atracción de XP/monedas

@export_category("Equipamiento Inicial")
@export var starting_weapon : WeaponData
