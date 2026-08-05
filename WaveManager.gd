extends Node
# Autoload: controla el reloj de la partida y la transición entre oleadas.

var elapsed_time : float = 0.0
var current_wave_index : int = -1
var active_wave : WaveData = null

# Lista de oleadas ordenadas por start_time. Asignar desde el editor o
# desde WaveManager.create_default_waves() si no hay recursos cargados.
@export var waves : Array[WaveData] = []

signal wave_started(wave_index: int, wave_data: WaveData)

func _ready() -> void:
	if waves.is_empty():
		_create_default_waves()
	_check_wave_transition()

func _process(delta: float) -> void:
	if get_tree().paused:
		return
	elapsed_time += delta
	_check_wave_transition()

func get_minutes() -> float:
	return elapsed_time / 60.0

func _check_wave_transition() -> void:
	for i in range(waves.size() - 1, -1, -1):
		var wave = waves[i]
		if elapsed_time >= wave.start_time and i > current_wave_index:
			current_wave_index = i
			active_wave = wave
			EventBus.wave_changed.emit(current_wave_index, wave.wave_name)
			wave_started.emit(current_wave_index, wave)
			break

# Oleadas predeterminadas — se usan si no hay recursos .tres asignados.
# Reemplazalas creando WaveData .tres en el editor y asignándolos arriba.
func _create_default_waves() -> void:
	var w0 = WaveData.new()
	w0.wave_name = "Inicio"
	w0.start_time = 0.0
	w0.spawn_interval = 3.5
	w0.amount_per_spawn = 1

	var w1 = WaveData.new()
	w1.wave_name = "Oleada 2"
	w1.start_time = 90.0
	w1.spawn_interval = 2.8
	w1.amount_per_spawn = 2

	var w2 = WaveData.new()
	w2.wave_name = "Presión"
	w2.start_time = 240.0
	w2.spawn_interval = 2.0
	w2.amount_per_spawn = 3

	var w3 = WaveData.new()
	w3.wave_name = "Élite"
	w3.start_time = 360.0
	w3.spawn_interval = 1.5
	w3.amount_per_spawn = 4
	w3.is_super_wave = true
	w3.super_wave_amount = 15

	var w4 = WaveData.new()
	w4.wave_name = "¡BOSS!"
	w4.start_time = 600.0
	w4.spawn_interval = 1.0
	w4.amount_per_spawn = 5
	w4.is_super_wave = true
	w4.super_wave_amount = 25

	waves = [w0, w1, w2, w3, w4]
