extends Node


var player : Node3D
var weapons : Array = []
const MAX_WEAPONS = 3
@onready var disponibles = ArmaDB.get_all_armas()
func _ready():
#	PlayerStats.level_up.connect(level_up)
	await get_tree().physics_frame
	var random_number = randi_range(0,ArmaDB.get_all_armas().size() - 1)
	add_weapon(ArmaDB.get_arma(random_number))

#		upgrade_weapon()

func add_weapon(Arma):
	print("Entró a add_weapon")
	print("Todas las armas son: ", ArmaDB.get_all_armas())
	disponibles.clear()

	for weapon in ArmaDB.get_all_armas():
		var tiene = false

		for a in weapons:
			if a.data.id == weapon.id:
				tiene = true
				break

		if !tiene:
			disponibles.append(weapon)
	print("Disponibles:", disponibles.size())
	
	var nueva 

	for ag in disponibles:
		if ag == Arma:
			nueva = Arma
	if !nueva:
		upgrade_weapon(Arma)
		print("UPGRADEANDOOOOOOOO")
		return
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

	weapons.append(instancia)

	print("Total armas:", weapons.size())

func upgrade_weapon(Arma):

	if weapons.is_empty():
		return

	Arma.upgrade()
