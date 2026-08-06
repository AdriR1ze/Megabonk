extends CharacterBody3D


@export var SPEED = 35.0
@onready var direccion : Vector3
var player_atack : float = 1.0
var damage : float = 10.0
var _hit_targets : Array = []
func _ready() -> void:
	if direccion != Vector3.ZERO:
		look_at(global_position + direccion)
	await get_tree().create_timer(5.0).timeout
	queue_free()
	

func _physics_process(delta: float) -> void:
	velocity = SPEED * PlayerStats.projectile_speed * direccion
	move_and_slide()




func _on_hit_box_bala_body_entered(body):
	if body.is_in_group("enemy"):
		_damage_overlapping()
		_hit_targets.append(body)
		# Perforación: si no quedan golpes extra, la bala se consume.
		var max_hits := PlayerStats.pierce_bonus + 1
		if _hit_targets.size() >= max_hits:
			queue_free()

func _damage_overlapping() -> void:
	for body in $HitBoxBala.get_overlapping_bodies():
		if body.is_in_group("enemy") and not _hit_targets.has(body):
			_hit_targets.append(body)
			_apply_damage(body)

func _apply_damage(body) -> void:
	var is_crit = randf() < PlayerStats.crit_chance
	var final_damage = damage * player_atack * (PlayerStats.crit_multiplier if is_crit else 1.0)
	if randf() < PlayerStats.dano_extra_chance:
		final_damage += PlayerStats.dano_extra_amount
	if body.has_method("take_damage"):
		body.take_damage(final_damage, is_crit)
