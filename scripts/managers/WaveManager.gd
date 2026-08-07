extends Node

var elapsed_time : float = 0.0
var current_wave_index : int = -1
var active_wave : WaveData = null
var last_minute_emitted : int = 0

@export var waves : Array[WaveData] = []

signal wave_started(wave_index: int, wave_data: WaveData)
signal minute_passed(minute: int)

func _ready() -> void:
	if waves.is_empty():
		_create_default_waves()
	EventBus.run_started.connect(_on_run_started)
	_check_wave_transition()

func _on_run_started() -> void:
	elapsed_time = 0.0
	current_wave_index = -1
	active_wave = null
	last_minute_emitted = 0
	_check_wave_transition()

func _process(delta: float) -> void:
	if not _should_run():
		return
	if get_tree().paused:
		return
	elapsed_time += delta
	_check_wave_transition()
	_check_minute_event()

func _should_run() -> bool:
	return not _is_mp() or multiplayer.is_server()

func _is_mp() -> bool:
	return multiplayer.has_multiplayer_peer()

func get_minutes() -> float:
	return elapsed_time / 60.0

func get_current_minute() -> int:
	return int(elapsed_time / 60.0)

func _check_minute_event() -> void:
	var minute = get_current_minute()
	if minute > last_minute_emitted:
		last_minute_emitted = minute
		minute_passed.emit(minute)

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
	waves = [
		_make_wave("Llegada", 0.0, 4, 1, 2.5),
		_make_wave("Oleada 2", 25.0, 6, 0.55, 2.2),
		_make_wave("Patrulla", 50.0, 8, 0.7, 2.0),
		_make_wave("Refuerzos", 72.0, 10, 0.9, 1.8),
		_make_wave("Presion", 95.0, 12, 1.1, 1.6),
		_make_wave("Emboscada", 115.0, 14, 1.4, 1.5),
		_make_wave("Asedio", 138.0, 16, 1.7, 1.3),
		_make_wave("MEGABOSS!", 158.0, 20, 2.0, 1.2),
		_make_wave("Infierno", 180.0, 22, 2.5, 1.1),
		_make_wave("Apocalipsis", 210.0, 28, 3.5, 0.9),
	]

func _make_wave(name: String, start: float, credits_start: int, cps: float, interval: float) -> WaveData:
	var w = WaveData.new()
	w.wave_name = name
	w.start_time = start
	w.starting_credits = credits_start
	w.credits_per_second = cps
	w.spawn_interval = interval
	return w
