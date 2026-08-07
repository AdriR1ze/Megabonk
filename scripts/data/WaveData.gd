extends Resource
class_name WaveData

@export var wave_name : String = "Oleada"
@export var start_time : float = 0.0
@export var starting_credits : int = 5
@export var credits_per_second : float = 0.5
@export var spawn_interval : float = 2.0
@export var available_enemies : Array[EnemyData] = []
@export var bosses : Array[PackedScene] = []
