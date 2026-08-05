extends Node
# Autoload: estadísticas vivas del jugador durante la partida.

# --- Estadísticas base ---
var max_health : float = 100.0
var defense : float = 1.0        # Reducción plana de daño recibido
var move_speed : float = 1.0     # Multiplicador de velocidad
var atack : float = 1.0          # Multiplicador de daño
var atq_speed : float = 1.0      # Multiplicador de velocidad de ataque
var crit_chance : float = 0.05   # Probabilidad de crítico (0.0 - 1.0)
var crit_multiplier : float = 1.5
var evasion : float = 0.0
var xp_multiplicator : float = 1.0
var regen : float = 0.0          # Vida regenerada por segundo
var projectile_speed : float = 1.0 # Multiplicador de velocidad de proyectiles
var pierce_bonus : int = 0       # Pierce extra sobre el base del arma
var range_multiplier : float = 1.0
var area_multiplier : float = 1.0
var luck : float = 1.0           # Afecta rarezas y drop de monedas

# --- Experiencia y Nivel ---
var level : int = 1
var xp : int = 0
var xp_needed : int = 5

# --- Señales ---
signal level_up
signal xp_changed

func add_xp(amount: int) -> void:
	amount = int(amount * xp_multiplicator)
	xp += amount

	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = int(xp_needed * 1.4) + 2
		level_up.emit()
		UpgradeManager.offer_upgrades()

	EventBus.player_xp_changed.emit(xp, xp_needed, level)
	xp_changed.emit()

func reset_for_new_run() -> void:
	max_health = 100.0
	defense = 1.0
	move_speed = 1.0
	atack = 1.0
	atq_speed = 1.0
	crit_chance = 0.05
	crit_multiplier = 1.5
	evasion = 0.0
	xp_multiplicator = 1.0
	regen = 0.0
	projectile_speed = 1.0
	pierce_bonus = 0
	range_multiplier = 1.0
	area_multiplier = 1.0
	luck = 1.0
	level = 1
	xp = 0
	xp_needed = 5
