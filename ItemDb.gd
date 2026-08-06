extends Node

@export var lista_items: Array[Item] = []
var items: Dictionary = {}

func _ready() -> void:
	print(">>> ITEMDB CARGADO <<<")
	print(lista_items)
	registrador()
	print("IDs cargados: ", items.keys())

func registrador() -> void:
	var next_id := 1
	for item in lista_items:
		if item == null:
			continue
		item.id = next_id
		items[item.id] = item
		next_id += 1

func get_item(id) -> Item:
	return items.get(id, null)

func get_all_items() -> Array:
	return items.values()
