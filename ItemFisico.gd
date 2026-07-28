extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if !body.is_in_group("player"):
		return

	if !GameManager.open_chest():
		print("No tenés monedas", GameManager.coins)
		return

	var items = ItemDB.get_all_items()

	if items.is_empty():
		return

	var item: Item = items.pick_random()

	ItemManager.agregar_item(item.id)

	print("Conseguiste: ", item.display_name)

	queue_free()
