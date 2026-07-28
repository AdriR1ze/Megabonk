extends Node

var all_weapons : Array[WeaponData] = [
	preload("res://Resources/Armas/pistolacomun.tres"),
]
var player : Node3D
var weapons : Array = []
const MAX_WEAPONS = 3

func _ready():
	PlayerStats.level_up.connect(level_up)

func level_up():
	print("LEVEL UP")
	print("Armas actuales:", weapons.size())

	if weapons.size() < MAX_WEAPONS:
		add_weapon()
	else:
		upgrade_weapon()

func add_weapon():

	print("Entró a add_weapon")
	print("Todas las armas son: ", all_weapons)
	var disponibles = []

	for weapon in all_weapons:
		print("Revisando:", weapon.weapon_name)

		if !weapons.any(func(w): return w.data.weapon_name == weapon.weapon_name):
			disponibles.append(weapon)

	print("Disponibles:", disponibles.size())

	if disponibles.is_empty():
		print("No hay armas disponibles")
		upgrade_weapon()
		return

	var nueva = disponibles.pick_random()

	print("Arma elegida:", nueva.weapon_name)

	var instancia = nueva.scene.instantiate()

	print("Instanciada:", instancia)

	instancia.data = nueva.duplicate(true)
	instancia.player = player
	print("Data asignada:", instancia.data)

	get_parent().add_child(instancia)

	print("Agregada al árbol")

	weapons.append(instancia)

	print("Total armas:", weapons.size())

func upgrade_weapon():

	if weapons.is_empty():
		return

	weapons.pick_random().upgrade()
