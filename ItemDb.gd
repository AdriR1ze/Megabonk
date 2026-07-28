extends Node

@export var lista_items: Array[Item] = []
var items: Dictionary = {}

func _ready() -> void:
	print(">>> ITEMDB CARGADO <<<")
	print(lista_items)
	registrador()
	print("IDs cargados: ", items.keys())

func registrador() -> void:
	for item in lista_items:
		if item == null:
			continue
		items[item.id] = item

func get_item(id) -> Item:
	return items.get(id, null)

func get_all_items() -> Array:
	return items.values()
