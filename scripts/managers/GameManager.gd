extends Node
# Manager global de estado del juego y recompensas

signal seleccionar_arma
signal coins_changed(new_coins: int)

var coins: int = 0:
	set(value):
		coins = value
		coins_changed.emit(coins)

var chests_opened: int = 0
var enemies_killed: int = 0
var xp: int = 0
var chest_price : int = 20

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died)

func _on_enemy_died(_enemy_node: Node3D, _xp_reward: int, _coin_reward: int) -> void:
	enemies_killed += 1

func get_chest_price() -> int: 
	chest_price = 20
	calc_chest_price(chests_opened)
	return chest_price
func calc_chest_price(x):
	if x == 0:
		return
	chest_price = chest_price ** 1.1
	print(chest_price)
	return calc_chest_price(x-1)
func open_chest() -> bool:
	var price = get_chest_price()

	if coins < price:
		return false

	coins -= price
	chests_opened += 1
	return true

func reset_run() -> void:
	coins = 0
	chests_opened = 0
	enemies_killed = 0
	xp = 0
