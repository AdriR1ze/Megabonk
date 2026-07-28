extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var player = $"../../Player"
@onready var health_component = $HealthComponent
func _physics_process(delta: float) -> void:
	var direccion : Vector3 = (player.global_position - global_position).normalized()
	velocity = direccion * SPEED
	move_and_slide()

func take_damage(damage):
	if health_component:
		health_component.take_damage(damage)
		
func reset_enemy():
	health_component.reset_health()

	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
