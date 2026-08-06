extends CharacterBody3D

@export var damage: float = 10.0
@export var attack_cooldown: float = 0.8

# Datos del tipo de enemigo (asignado por EnemyManager al spawnear)
var enemy_data : EnemyData = null

var attack_timer: float = 0.0
var player : Node3D = null

@onready var health_component : HealthComponent = $HealthComponent

func _ready() -> void:
	# Buscar al jugador en el grupo en lugar de usar rutas relativas
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	# Refrescar referencia al jugador si se invalidó
	if not is_instance_valid(player) or not player.is_inside_tree():
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return

	var dir : Vector3 = (player.global_position - global_position).normalized()
	velocity = dir * damage  # 'damage' aquí es la variable de velocidad — renombrada abajo
	# Velocidad real de movimiento desde los datos del enemigo
	var spd = enemy_data.speed if enemy_data else 6.8
	velocity = dir * spd
	move_and_slide()

	attack_timer += delta
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= attack_cooldown:
				attack_timer = 0.0
				var dmg = enemy_data.damage if enemy_data else damage
				if collider.has_method("take_damage"):
					collider.take_damage(dmg)

func take_damage(damage_amount: float, is_critical: bool = false, crit_tier: int = 0) -> void:
	if health_component:
		health_component.take_damage(damage_amount, is_critical, crit_tier)

func reset_enemy(health_multiplier: float = 1.0) -> void:
	if health_component:
		health_component.reset_health(health_multiplier)
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	attack_timer = 0.0
	player = get_tree().get_first_node_in_group("player")
