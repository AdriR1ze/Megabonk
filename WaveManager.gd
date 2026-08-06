extends Node
# Autoload: controla el reloj de la partida y la transición entre oleadas.

var elapsed_time : float = 0.0
var current_wave_index : int = -1
var active_wave : WaveData = null

@export var waves : Array[WaveData] = []

signal wave_started(wave_index: int, wave_data: WaveData)

func _ready() -> void:
	if waves.is_empty():
		_create_default_waves()
	EventBus.run_started.connect(_on_run_started)
	_check_wave_transition()

func _on_run_started() -> void:
	elapsed_time = 0.0
	current_wave_index = -1
	active_wave = null
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

func _create_default_waves() -> void:
	var w0 = WaveData.new()
	w0.wave_name = "Inicio"
	w0.start_time = 0.0
	w0.spawn_interval = 3.5
	w0.amount_per_spawn = 1

	var w1 = WaveData.new()
	w1.wave_name = "Oleada 2"
	w1.start_time = 45.0
	w1.spawn_interval = 2.8
	w1.amount_per_spawn = 2

	var w2 = WaveData.new()
	w2.wave_name = "Presión"
	w2.start_time = 90.0
	w2.spawn_interval = 2.0
	w2.amount_per_spawn = 3

	var w3 = WaveData.new()
	w3.wave_name = "¡MEGABOSS!"
	w3.start_time = 150.0
	w3.spawn_interval = 1.5
	w3.amount_per_spawn = 4
	w3.is_super_wave = true
	w3.super_wave_amount = 10

	waves = [w0, w1, w2, w3]
