extends CharacterBody3D


@export var SPEED = 35.0
@onready var direccion : Vector3
var player_atack : float = 1.0
var damage : float = 10.0
func _ready() -> void:
	if direccion != Vector3.ZERO:
		look_at(global_position + direccion)
	await get_tree().create_timer(5.0).timeout
	queue_free()
	

func _physics_process(delta: float) -> void:
	velocity = SPEED * direccion
	move_and_slide()




func _on_hit_box_bala_body_entered(body):
	if body.is_in_group("enemy"):
		explotar()

func explotar():
	for body in $HitBoxBala.get_overlapping_bodies():
		if body.is_in_group("enemy"):
			var is_crit = randf() < PlayerStats.crit_chance
			var final_damage = damage * player_atack * (PlayerStats.crit_multiplier if is_crit else 1.0)
			if body.has_method("take_damage"):
				body.take_damage(final_damage, is_crit)
		

	queue_free()
