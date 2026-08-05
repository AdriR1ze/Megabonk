extends Resource
class_name EnemyData

@export var enemy_name : String = "Enemigo"
@export var scene : PackedScene
@export var base_hp : float = 50.0
@export var speed : float = 6.8
@export var damage : float = 10.0
@export var attack_cooldown : float = 0.8
@export var xp_reward : int = 1
@export var coin_chance : float = 0.6
@export var is_boss : bool = false
