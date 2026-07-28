extends Node

var items_player: Array = []
var player: Node3D
var label_move_speed : Control
signal stats_changed
func _ready() -> void:
	pass
func agregar_item(id) -> void:
	if id == null:
		return
	items_player.append(id)
	aplicar_item(id)

func remover_item(id) -> void:
	if id == null:
		return
	items_player.erase(id)
	aplicar_items()

func aplicar_item(id) -> void:
	var item: Item = ItemDB.get_item(id)
	if item == null:
		push_error("ItemManager: no existe ningún item con id ", id)
		return
	if item.stats == true:
		_set_stats(item)

func aplicar_items() -> void:
	if player == null:
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
	PlayerStats.move_speed = 0
	PlayerStats.defense = 0
	PlayerStats.evasion = 0
	PlayerStats.atq_speed = 0
	PlayerStats.atack = 0
	PlayerStats.crit_chance = 0
	PlayerStats.xp_multiplicator = 0

func _set_stats(item) -> void:
	PlayerStats.move_speed += item.move_speed
	label_move_speed.text = str(PlayerStats.move_speed)
	PlayerStats.defense += item.defense
	PlayerStats.evasion += item.evasion
	PlayerStats.atq_speed += item.atq_speed
	PlayerStats.atack += item.atack
	PlayerStats.crit_chance += item.crit_chance
	PlayerStats.xp_multiplicator += item.xp_multiplicator
	stats_changed.emit()
