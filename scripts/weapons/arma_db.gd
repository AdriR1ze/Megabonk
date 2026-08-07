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
	var max_alcanzado = WeaponManager.weapons.size() >= WeaponManager.MAX_WEAPONS
	for a in armas.values():
		if a == null:
			continue
		var tiene = false
		for w in WeaponManager.weapons:
			if is_instance_valid(w) and (w.data.id == a.id or w.data.weapon_name == a.weapon_name):
				tiene = true
				break
		
		# Si ya hay el máximo de armas equipadas, no ofrecer armas nuevas
		if max_alcanzado and not tiene:
			continue
		
		if tiene:
			armas_elegibles.append([a, 1]) # 1 = Upgrade de arma equipada
		else:
			armas_elegibles.append([a, 0]) # 0 = Nueva arma
			
	return armas_elegibles
