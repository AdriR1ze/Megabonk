extends Node

signal weapons_changed

var player : Node3D
var weapons : Array = []
const MAX_WEAPONS = 3

@onready var disponibles = ArmaDB.get_all_armas()

func _ready():
	# Escuchar EventBus para reagregar armas si el player muere/reinicia
	await get_tree().physics_frame
	var random_id = randi() % max(1, ArmaDB.get_all_armas().size())
	add_weapon(ArmaDB.get_arma(random_id))

func add_weapon(arma: WeaponData) -> void:
	if arma == null:
		push_error("WeaponManager: add_weapon recibió null.")
		return

	_refresh_disponibles()

	# Si ya la tenemos, mejorarla
	var ya_tenemos = false
	for w in weapons:
		if is_instance_valid(w) and w.data.id == arma.id:
			ya_tenemos = true
			break

	if ya_tenemos or not disponibles.any(func(d): return d.id == arma.id):
		upgrade_weapon(arma)
		return

	var instancia = arma.scene.instantiate()
	instancia.data = arma.duplicate(true)
	instancia.player = player
	player.add_child(instancia)
	instancia.position = Vector3.ZERO
	weapons.append(instancia)

	EventBus.weapon_unlocked.emit(arma)
	weapons_changed.emit()

func upgrade_weapon(arma: WeaponData) -> void:
	if weapons.is_empty():
		return
	for instancia in weapons:
		if is_instance_valid(instancia) and (instancia.data.id == arma.id or (arma and instancia.data.weapon_name == arma.weapon_name)):
			if instancia.has_method("upgrade"):
				instancia.upgrade()
			else:
				instancia.data.upgrade()
			EventBus.weapon_upgraded.emit(instancia.data)
			weapons_changed.emit()
			return
	# Fallback: mejorar la primera si no se encontró coincidencia
	if is_instance_valid(weapons[0]):
		if weapons[0].has_method("upgrade"):
			weapons[0].upgrade()
		else:
			weapons[0].data.upgrade()
		EventBus.weapon_upgraded.emit(weapons[0].data)
		weapons_changed.emit()

func _refresh_disponibles() -> void:
	disponibles.clear()
	for weapon in ArmaDB.get_all_armas():
		var tiene = weapons.any(func(w): return is_instance_valid(w) and w.data.id == weapon.id)
		if not tiene:
			disponibles.append(weapon)
