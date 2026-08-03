extends Node

@export var lista_armas: Array[WeaponData] = []
var armas: Dictionary = {}

func _ready() -> void:
	print(">>> armaDB CARGADO <<<")
	print(lista_armas)
	registrador()
	print("IDs cargados: ", armas.keys())

func registrador() -> void:
	for arma in lista_armas:
		if arma == null:
			continue
		armas[arma.id] = arma

func get_arma(id) -> WeaponData:
	return armas.get(id, null)

func get_all_armas() -> Array:
	return armas.values()
	
func get_all_armas_no_usadas() -> Array:
	var armas_elegibles = []
	for a in armas.values():
		print(WeaponManager.disponibles)
		if WeaponManager.disponibles.has(a):
			armas_elegibles.append([a,0])
		if WeaponManager.weapons.has(a):
			armas_elegibles.append([a,1])
	return armas_elegibles
