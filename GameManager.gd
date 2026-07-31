extends Node
#UI
# --------Seleccionar Arma--------
signal seleccionar_arma
var coins: int = 1000
var chests_opened: int = 0

var xp : int = 0
func get_chest_price() -> int:
	return 0 + chests_opened * 10

func open_chest() -> bool:
	var price = get_chest_price()

	if coins < price:
		return false

	coins -= price
	chests_opened += 1
	return true
