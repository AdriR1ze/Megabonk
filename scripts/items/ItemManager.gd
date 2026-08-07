extends Node

var items_player: Array = []
var player: Node3D
var control_node : Control
signal stats_changed
func _ready() -> void:
	pass
func agregar_item(id) -> void:
	if id == null:
		return
	items_player.append(id)
	SaveManager.mark_item_discovered(id)
	aplicar_item(id)

func remover_item(id) -> void:
	if id == null:
		return
	var item: Item = ItemDB.get_item(id)
	items_player.erase(id)
	if item and item.skill and is_instance_valid(player):
		item.skill.remove(player)
	aplicar_items()

func limpiar_items() -> void:
	for id in items_player:
		var item = ItemDB.get_item(id)
		if item and item.skill and is_instance_valid(player):
			item.skill.remove(player)
	items_player.clear()

func aplicar_item(id) -> void:
	var item: Item = ItemDB.get_item(id)
	if item == null:
		push_error("ItemManager: no existe ningún item con id ", id)
		return
	if item.stats == true:
		_set_stats(item)
	if item.skill and is_instance_valid(player):
		item.skill.apply(player)

func aplicar_items() -> void:
	if not is_instance_valid(player):
		push_error("ItemManager: 'player' no está asignado")
		return
	_reset_stats()
	for id in items_player:
		var item = ItemDB.get_item(id)
		if item == null:
			continue
		if item.stats == true:
			_set_stats(item)

func _reset_stats() -> void:
	PlayerStats.move_speed = 1.0
	PlayerStats.defense = 1.0
	PlayerStats.evasion = 0.0
	PlayerStats.atq_speed = 1.0
	PlayerStats.atack = 1.0
	PlayerStats.crit_chance = 0.05
	PlayerStats.xp_multiplicator = 1.0
	PlayerStats.dano_extra_chance = 0.0
	PlayerStats.dano_extra_amount = 0.0

func _set_stats(item) -> void:
	PlayerStats.move_speed += item.move_speed
	PlayerStats.defense += item.defense
	PlayerStats.evasion += item.evasion
	PlayerStats.atq_speed += item.atq_speed
	PlayerStats.atack += item.atack
	PlayerStats.crit_chance += item.crit_chance / 100.0
	PlayerStats.xp_multiplicator += item.xp_multiplicator
	stats_changed.emit()
