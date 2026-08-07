extends Node

@export var spawn_interval_minutes: int = 4
@export var shop_duration: float = 90.0
@export var spawn_radius: float = 50.0

const SHOP_SCRIPT = preload("res://scripts/tienda/tienda_legendaria.gd")

var _shop_active: bool = false
var _current_shop: Node3D = null
var _minutes_elapsed: int = 0

func _ready() -> void:
	WaveManager.minute_passed.connect(_on_minute_passed)
	EventBus.run_started.connect(_on_run_started)

func _on_run_started() -> void:
	_minutes_elapsed = 0
	if is_instance_valid(_current_shop):
		_current_shop.close()
	_current_shop = null
	_shop_active = false

func _on_minute_passed(minute: int) -> void:
	_minutes_elapsed += 1
	if _minutes_elapsed % spawn_interval_minutes == 0 and not _shop_active:
		_spawn_shop()

func _spawn_shop() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not is_instance_valid(player):
		return

	var angle = randf() * TAU
	var dist = randf_range(30.0, spawn_radius)
	var pos = player.global_position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
	pos.x = clamp(pos.x, -150.0, 150.0)
	pos.z = clamp(pos.z, -150.0, 150.0)
	pos.y = 2.0

	var shop = Node3D.new()
	shop.name = "TiendaLegendaria"
	shop.set_script(SHOP_SCRIPT)
	shop.global_position = pos

	get_tree().current_scene.add_child(shop)
	shop.shop_closed.connect(_on_shop_closed)
	_current_shop = shop
	_shop_active = true

	var timer = get_tree().create_timer(shop_duration)
	timer.timeout.connect(func():
		if is_instance_valid(_current_shop):
			_current_shop.close()
	)

func _on_shop_closed() -> void:
	_shop_active = false
	_current_shop = null
