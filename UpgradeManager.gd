extends Node
# Autoload: gestiona las mejoras ofrecidas al subir de nivel y aplica sus efectos.

@export var all_upgrades : Array[UpgradeData] = []
@export var upgrades_offered_count : int = 3

func _ready() -> void:
	EventBus.player_xp_changed.connect(_on_xp_changed)

func _on_xp_changed(current_xp: int, needed_xp: int, level: int) -> void:
	# No hacemos nada aquí — PlayerStats gestiona la lógica de nivel.
	# Esta función queda para posibles efectos extra al subir de nivel.
	pass

# Llamada por PlayerStats cuando se alcanza un nuevo nivel.
func offer_upgrades() -> void:
	# Si no hay mejoras configuradas aún, usar el flujo anterior de selección de armas
	if all_upgrades.is_empty():
		GameManager.seleccionar_arma.emit()
		return

	var pool = _build_pool()
	pool.shuffle()
	var offered = pool.slice(0, min(upgrades_offered_count, pool.size()))
	get_tree().paused = true
	EventBus.upgrade_offered.emit(offered)

# Construye la lista de mejoras disponibles para ofrecer
func _build_pool() -> Array:
	var available : Array = []
	for upgrade in all_upgrades:
		if upgrade == null:
			continue
		# Verificar si es una sinergia y si cumple los requisitos
		if upgrade.type == UpgradeData.UpgradeType.SYNERGY:
			if not _synergy_requirements_met(upgrade):
				continue
		available.append(upgrade)
	return available

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
	get_tree().paused = false

func _apply_stat_changes(upgrade: UpgradeData) -> void:
	for stat_name in upgrade.stat_changes.keys():
		var delta_val = upgrade.stat_changes[stat_name]
		if stat_name in PlayerStats:
			PlayerStats.set(stat_name, PlayerStats.get(stat_name) + delta_val)
	ItemManager.stats_changed.emit()
