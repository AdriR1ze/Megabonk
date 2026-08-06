extends Node
# Autoload: gestiona las mejoras ofrecidas al subir de nivel y aplica sus efectos.

@export var all_upgrades : Array[UpgradeData] = []
@export var upgrades_offered_count : int = 3

func _ready() -> void:
	EventBus.player_xp_changed.connect(_on_xp_changed)
	_load_upgrades()

# Carga las mejoras de estadísticas desde Resources/Upgrades.
func _load_upgrades() -> void:
	var dir := DirAccess.open("res://Resources/Upgrades")
	if dir == null:
		return
	for file in dir.get_files():
		if not file.ends_with(".tres"):
			continue
		var res = load("res://Resources/Upgrades/" + file)
		if res is UpgradeData and res not in all_upgrades:
			all_upgrades.append(res)

func _on_xp_changed(current_xp: int, needed_xp: int, level: int) -> void:
	pass

# Llamada por PlayerStats cuando se alcanza un nuevo nivel.
func offer_upgrades() -> void:
	var pool := _build_pool()
	if pool.is_empty():
		GameManager.seleccionar_arma.emit()
		return

	# Separar mejoras de stats y opciones de armas (nueva o upgrade).
	var stat_opts: Array = []
	var weapon_opts: Array = []
	for u in pool:
		if u.type == UpgradeData.UpgradeType.STAT:
			stat_opts.append(u)
		else:
			weapon_opts.append(u)
	stat_opts.shuffle()
	weapon_opts.shuffle()

	# Garantizar al menos una opción de arma cuando haya disponible.
	var offered: Array = []
	if not weapon_opts.is_empty():
		offered.append(weapon_opts.pop_front())
	while offered.size() < upgrades_offered_count and (not stat_opts.is_empty() or not weapon_opts.is_empty()):
		if not stat_opts.is_empty():
			offered.append(stat_opts.pop_front())
		elif not weapon_opts.is_empty():
			offered.append(weapon_opts.pop_front())
	offered.shuffle()

	get_tree().paused = true
	EventBus.upgrade_offered.emit(offered)

# Construye la lista de mejoras disponibles: stats configuradas + opciones de armas.
func _build_pool() -> Array:
	var available : Array = []
	for upgrade in all_upgrades:
		if upgrade == null:
			continue
		if upgrade.type == UpgradeData.UpgradeType.SYNERGY:
			if not _synergy_requirements_met(upgrade):
				continue
		available.append(upgrade)
	available.append_array(_build_weapon_options())
	return available

# Genera opciones de armas en tiempo real según lo que ya tiene el jugador.
func _build_weapon_options() -> Array:
	var options : Array = []
	var at_max := WeaponManager.weapons.size() >= WeaponManager.MAX_WEAPONS
	for weapon_data in ArmaDB.get_all_armas():
		if weapon_data == null:
			continue
		var owned := false
		for w in WeaponManager.weapons:
			if is_instance_valid(w) and w.data and w.data.id == weapon_data.id:
				owned = true
				break
		if owned:
			options.append(_make_weapon_upgrade(weapon_data, false))
		elif not at_max:
			options.append(_make_weapon_upgrade(weapon_data, true))
	return options

func _make_weapon_upgrade(weapon_data: WeaponData, is_new: bool) -> UpgradeData:
	var u := UpgradeData.new()
	u.type = UpgradeData.UpgradeType.NEW_WEAPON if is_new else UpgradeData.UpgradeType.UPGRADE_WEAPON
	u.weapon_id = weapon_data.id
	u.icon = weapon_data.texture_sprite
	u.rarity = weapon_data.rarity
	if is_new:
		u.upgrade_name = weapon_data.weapon_name
		u.description = "NUEVA ARMA\nDaño: %.0f · Cadencia: %.2fs\nRango: %.0f" % [weapon_data.damage, weapon_data.cooldown, weapon_data.rango]
	else:
		var current_level := 1
		for w in WeaponManager.weapons:
			if is_instance_valid(w) and w.data and w.data.id == weapon_data.id:
				current_level = w.data.level
				break
		u.upgrade_name = weapon_data.weapon_name + " (Nv. " + str(current_level + 1) + ")"
		u.description = "MEJORAR ARMA\n+Daño: %.0f\n+Rango: +%.1f · Pierce: +%d" % [
			weapon_data.crecimiento_damage, weapon_data.crecimiento_rango, weapon_data.crecimiento_pierce]
	return u

func _synergy_requirements_met(upgrade: UpgradeData) -> bool:
	for weapon_id in upgrade.synergy_requires_weapon_ids:
		var found = false
		for weapon_inst in WeaponManager.weapons:
			if is_instance_valid(weapon_inst) and weapon_inst.data.id == weapon_id:
				found = true
				break
		if not found:
			return false
	return true

# Llamada desde la UI cuando el jugador elige una mejora
func apply_upgrade(upgrade: UpgradeData) -> void:
	match upgrade.type:
		UpgradeData.UpgradeType.STAT:
			_apply_stat_changes(upgrade)
		UpgradeData.UpgradeType.NEW_WEAPON:
			WeaponManager.add_weapon(ArmaDB.get_arma(upgrade.weapon_id))
		UpgradeData.UpgradeType.UPGRADE_WEAPON:
			WeaponManager.upgrade_weapon(ArmaDB.get_arma(upgrade.weapon_id))
		UpgradeData.UpgradeType.SYNERGY:
			_apply_stat_changes(upgrade)
			if upgrade.weapon_id >= 0:
				WeaponManager.upgrade_weapon(ArmaDB.get_arma(upgrade.weapon_id))

	EventBus.upgrade_selected.emit(upgrade)
	PlayerStats.pending_levels = max(0, PlayerStats.pending_levels - 1)
	if PlayerStats.pending_levels > 0:
		offer_upgrades()
	else:
		get_tree().paused = false

func _apply_stat_changes(upgrade: UpgradeData) -> void:
	for stat_name in upgrade.stat_changes.keys():
		var delta_val = upgrade.stat_changes[stat_name]
		if stat_name in PlayerStats:
			PlayerStats.set(stat_name, PlayerStats.get(stat_name) + delta_val)
	ItemManager.stats_changed.emit()
