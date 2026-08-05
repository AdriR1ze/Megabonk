extends Node
#UI
# --------Seleccionar Arma--------
signal seleccionar_arma
signal coins_changed(new_coins: int)

var coins: int = 20:
	set(value):
		coins = value
		coins_changed.emit(coins)

var chests_opened: int = 0

var xp : int = 0
func get_chest_price() -> int:
	return 30 + chests_opened * 20

func open_chest() -> bool:
	var price = get_chest_price()

	if coins < price:
		return false

	coins -= price
	chests_opened += 1
	return true
