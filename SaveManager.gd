extends Node
# Autoload: gestiona la economía permanente entre partidas (meta-progresión).

const SAVE_PATH = "user://megabonk_save.json"

var persistent_coins : int = 0
var unlocked_upgrades : Array[int] = [] # IDs de mejoras permanentes desbloqueadas

func _ready() -> void:
	load_data()

func save_data() -> void:
	var data = {
		"persistent_coins": persistent_coins,
		"unlocked_upgrades": unlocked_upgrades,
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

func load_data() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		return
	persistent_coins = parsed.get("persistent_coins", 0)
	unlocked_upgrades = parsed.get("unlocked_upgrades", [])

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	persistent_coins = 0
	unlocked_upgrades = []
