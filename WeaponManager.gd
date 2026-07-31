extends Node


var player : Node3D
var weapons : Array = []
const MAX_WEAPONS = 3
@onready var disponibles = ArmaDB.get_all_armas()
func _ready():
#	PlayerStats.level_up.connect(level_up)
	await get_tree().physics_frame
	var random_number = randi_range(0,ArmaDB.get_all_armas().size() - 1)
	add_weapon(random_number)

#		upgrade_weapon()

func add_weapon(ArmaID):

	print("Entró a add_weapon")
	print("Todas las armas son: ", ArmaDB.get_all_armas())

	for a in weapons:
		for weapon in ArmaDB.get_all_armas():
			print("Revisando:", weapon.weapon_name)
			push_error("HOLAl")
			if a.id == weapon.id:
				disponibles.append(weapon.id)


	print("Disponibles:", disponibles.size())

	if disponibles.is_empty():
		print("No hay armas disponibles")
		upgrade_weapon(ArmaID)
		return

	var nueva = ArmaDB.get_arma(disponibles.find(ArmaID))
	print("Arma elegida:", nueva.weapon_name)


	var instancia = nueva.scene.instantiate()

	instancia.data = nueva.duplicate(true)
	instancia.player = player

	print("---------------")
	print("Arma:", instancia.name)	
	print("Padre:", get_parent().name)
	print("Player:", player)
	print("Scene:", nueva.scene)
	print("Data:", instancia.data.weapon_name)

	player.add_child(instancia)
	instancia.position = Vector3.ZERO
	print("Ahora el padre es:", instancia.get_parent())
	print("---------------")
	for hijo in instancia.get_children():
		print(hijo)
	print("Agregada al árbol")

	weapons.append(instancia)

	print("Total armas:", weapons.size())

func upgrade_weapon(ArmaID):

	if weapons.is_empty():
		return

	ArmaDB.get_arma(ArmaID).upgrade()
