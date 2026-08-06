class_name SobrevidaZone
extends Node

var max_health := 20.0
var refill_interval := 10.0
var current := 0.0

var _timer: Timer

func _ready() -> void:
	add_to_group("sobrevida")
	current = max_health
	_timer = Timer.new()
	_timer.wait_time = refill_interval
	_timer.timeout.connect(_refill)
	add_child(_timer)
	_timer.start()
	EventBus.player_overhealth_changed.emit(current, max_health)

func _refill() -> void:
	current = max_health
	EventBus.player_overhealth_changed.emit(current, max_health)

func refresh() -> void:
	EventBus.player_overhealth_changed.emit(current, max_health)

func absorb(amount: float) -> float:
	if current <= 0.0:
		return amount
	var absorbed = min(current, amount)
	current -= absorbed
	EventBus.player_overhealth_changed.emit(current, max_health)
	return amount - absorbed
