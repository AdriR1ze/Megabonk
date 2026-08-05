extends Resource
class_name WaveData

@export var wave_name : String = "Oleada"
@export var start_time : float = 0.0       # Segundo en que inicia esta oleada
@export var spawn_interval : float = 3.5   # Segundos entre cada grupo de spawns
@export var amount_per_spawn : int = 1     # Enemigos por tick de spawn
@export var enemies : Array[EnemyData] = []# Tipos de enemigos disponibles en esta oleada
@export var is_super_wave : bool = false   # Si lanza oleada masiva al iniciar
@export var super_wave_amount : int = 12   # Cantidad si es super oleada
