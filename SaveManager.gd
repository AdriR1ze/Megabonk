extends Node
# Autoload: progresión permanente entre partidas (meta-progresión).

const SAVE_PATH = "user://megabonk_save.json"

var persistent_coins : int = 0
var unlocked_upgrades : Array[int] = [] # IDs de mejoras permanentes compradas
var discovered_items : Array[int] = []  # Ítems obtenidos alguna vez
var discovered_weapons : Array[int] = [] # Armas obtenidas alguna vez
var best_level : int = 0
var best_kills : int = 0
var best_time : float = 0.0
var total_runs : int = 0

# Bonificaciones permanentes acumuladas
var meta_max_health : float = 0.0
var meta_damage : float = 0.0
var meta_move_speed : float = 0.0
var meta_atq_speed : float = 0.0
var meta_defense : float = 0.0
var meta_crit_chance : float = 0.0
var meta_xp : float = 0.0

const META_UPGRADES := [
	{"id": 1, "name": "Vigor", "desc": "+50 Vida máxima", "cost": 50, "stat": "meta_max_health", "value": 50.0},
	{"id": 2, "name": "Fuerza", "desc": "+10% Daño", "cost": 40, "stat": "meta_damage", "value": 0.1},
	{"id": 3, "name": "Velocidad", "desc": "+5% Velocidad de movimiento", "cost": 30, "stat": "meta_move_speed", "value": 0.05},
	{"id": 4, "name": "Reflejos", "desc": "+5% Velocidad de ataque", "cost": 30, "stat": "meta_atq_speed", "value": 0.05},
	{"id": 5, "name": "Armadura", "desc": "+0.5 Armadura", "cost": 35, "stat": "meta_defense", "value": 0.5},
	{"id": 6, "name": "Instinto Crítico", "desc": "+3% Probabilidad de crítico", "cost": 40, "stat": "meta_crit_chance", "value": 0.03},
	{"id": 7, "name": "Sabiduría", "desc": "+10% XP ganada", "cost": 35, "stat": "meta_xp", "value": 0.1},
]

func _ready() -> void:
	load_data()

# --- Persistencia ---

func save_data() -> void:
	var data = {
		"persistent_coins": persistent_coins,
		"unlocked_upgrades": unlocked_upgrades,
		"discovered_items": discovered_items,
		"discovered_weapons": discovered_weapons,
		"best_level": best_level,
		"best_kills": best_kills,
		"best_time": best_time,
		"total_runs": total_runs,
		"meta_max_health": meta_max_health,
		"meta_damage": meta_damage,
		"meta_move_speed": meta_move_speed,
		"meta_atq_speed": meta_atq_speed,
		"meta_defense": meta_defense,
		"meta_crit_chance": meta_crit_chance,
		"meta_xp": meta_xp,
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
	persistent_coins = int(parsed.get("persistent_coins", 0))
	unlocked_upgrades = []
	var arr = parsed.get("unlocked_upgrades", [])
	if arr is Array:
		for v in arr:
			unlocked_upgrades.append(int(v))
	discovered_items = []
	arr = parsed.get("discovered_items", [])
	if arr is Array:
		for v in arr:
			discovered_items.append(int(v))
	discovered_weapons = []
	arr = parsed.get("discovered_weapons", [])
	if arr is Array:
		for v in arr:
			discovered_weapons.append(int(v))
	best_level = int(parsed.get("best_level", 0))
	best_kills = int(parsed.get("best_kills", 0))
	best_time = float(parsed.get("best_time", 0.0))
	total_runs = int(parsed.get("total_runs", 0))
	meta_max_health = float(parsed.get("meta_max_health", 0.0))
	meta_damage = float(parsed.get("meta_damage", 0.0))
	meta_move_speed = float(parsed.get("meta_move_speed", 0.0))
	meta_atq_speed = float(parsed.get("meta_atq_speed", 0.0))
	meta_defense = float(parsed.get("meta_defense", 0.0))
	meta_crit_chance = float(parsed.get("meta_crit_chance", 0.0))
	meta_xp = float(parsed.get("meta_xp", 0.0))

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	persistent_coins = 0
	unlocked_upgrades = []
	discovered_items = []
	discovered_weapons = []
	best_level = 0
	best_kills = 0
	best_time = 0.0
	total_runs = 0
	meta_max_health = 0.0
	meta_damage = 0.0
	meta_move_speed = 0.0
	meta_atq_speed = 0.0
	meta_defense = 0.0
	meta_crit_chance = 0.0
	meta_xp = 0.0
	save_data()

# --- Meta-mejoras (tienda) ---

func get_upgrade(id: int) -> Dictionary:
	for u in META_UPGRADES:
		if int(u.id) == id:
			return u
	return {}

func get_upgrade_count(id: int) -> int:
	return unlocked_upgrades.count(id)

func get_upgrade_cost(id: int) -> int:
	var u := get_upgrade(id)
	if u.is_empty():
		return 0
	return int(u.cost * pow(1.4, get_upgrade_count(id)))

func purchase_upgrade(id: int) -> bool:
	var u := get_upgrade(id)
	if u.is_empty():
		return false
	var cost := get_upgrade_cost(id)
	if persistent_coins < cost:
		return false
	persistent_coins -= cost
	unlocked_upgrades.append(id)
	set(u.stat, get(u.stat) + float(u.value))
	save_data()
	return true

# Aplica las bonificaciones permanentes a PlayerStats (se llama al iniciar partida
# y al resetear para una nueva run). Las estadísticas ya partieron de sus valores base.
func apply_meta_bonuses() -> void:
	if not is_instance_valid(PlayerStats):
		return
	PlayerStats.max_health += meta_max_health
	PlayerStats.atack += meta_damage
	PlayerStats.move_speed += meta_move_speed
	PlayerStats.atq_speed += meta_atq_speed
	PlayerStats.defense += meta_defense
	PlayerStats.crit_chance += meta_crit_chance
	PlayerStats.xp_multiplicator += meta_xp

# Registra el fin de una partida y guarda.
func end_run(coins_earned: int, level: int, kills: int, time_sec: float) -> void:
	persistent_coins += max(0, coins_earned)
	total_runs += 1
	if level > best_level:
		best_level = level
	if kills > best_kills:
		best_kills = kills
	if time_sec > best_time:
		best_time = time_sec
	save_data()

# --- Colección / descubrimiento (para el inventario) ---

func mark_item_discovered(id: int) -> void:
	if not discovered_items.has(id):
		discovered_items.append(id)
		save_data()

func mark_weapon_discovered(id: int) -> void:
	if not discovered_weapons.has(id):
		discovered_weapons.append(id)
		save_data()

func is_item_discovered(id: int) -> bool:
	return discovered_items.has(id)

func is_weapon_discovered(id: int) -> bool:
	return discovered_weapons.has(id)
