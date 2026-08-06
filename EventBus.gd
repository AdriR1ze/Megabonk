extends Node

# --- EVENT BUS GLOBAL ---
# Este singleton maneja toda la comunicación desacoplada en Megabonk.

# Eventos del Jugador
signal player_health_changed(current_health: float, max_health: float)
signal player_overhealth_changed(current_health: float, max_health: float)
signal shield_status_changed(ready: bool)
signal shield_blocked
signal player_xp_changed(current_xp: int, needed_xp: int, level: int)
signal player_died
signal player_coins_changed(total_coins: int)

# Eventos de Combate y Enemigos
signal enemy_spawned(enemy_node: Node3D)
signal enemy_died(enemy_node: Node3D, xp_reward: int, coin_reward: int)
signal damage_dealt(target: Node3D, amount: float, is_critical: bool)

# Eventos del Boss
signal boss_spawned(boss_node: Node3D, boss_name: String)
signal boss_health_changed(current_hp: float, max_hp: float)
signal boss_defeated

# Eventos de Armas y Mejoras
signal weapon_unlocked(weapon_data: Resource)
signal weapon_upgraded(weapon_data: Resource)
signal upgrade_offered(upgrades_list: Array) # Array de UpgradeData
signal upgrade_selected(upgrade_data: Resource)
signal weapon_fired # Al disparar cualquier arma

# Eventos de Audio / Feedback
signal item_picked
signal player_took_damage
signal run_started

# Eventos de Mundo y Oleadas
signal wave_changed(wave_index: int, wave_name: String)
signal super_wave_triggered
signal chest_opened(chest_price: int)
