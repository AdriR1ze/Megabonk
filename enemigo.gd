extends CharacterBody3D

const SPEED = 6.8
const JUMP_VELOCITY = 4.5
@export var damage: float = 10.0
@export var attack_cooldown: float = 0.8

var attack_timer: float = 0.0
@onready var player = $"../../Player"
@onready var health_component = $HealthComponent

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or not player.is_inside_tree():
		player = get_tree().get_first_node_in_group("player")
		if not player:
			return
			
	var direccion : Vector3 = (player.global_position - global_position).normalized()
	velocity = direccion * SPEED
	move_and_slide()

	attack_timer += delta
	
	# Check slide collisions for player touch
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider and collider.is_in_group("player"):
			if attack_timer >= attack_cooldown:
				attack_timer = 0.0
				if collider.has_method("take_damage"):
					collider.take_damage(damage)
				elif collider.has_node("HealthComponent"):
					collider.get_node("HealthComponent").take_damage(damage)

func take_damage(damage_amount):
	if health_component:
		health_component.take_damage(damage_amount)
		
func reset_enemy(health_multiplier: float = 1.0):
	if health_component:
		health_component.reset_health(health_multiplier)

	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
