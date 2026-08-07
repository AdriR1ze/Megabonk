extends CharacterBody3D


@export var SPEED = 35.0
@onready var direccion : Vector3
var player_atack : float = 1.0
@export var damage : float = 10.0
var pierce : int = 1
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
		# Perforación: la bala atraviesa (pierce del arma + pierce extra del jugador) enemigos.
		var max_hits := pierce + PlayerStats.pierce_bonus
		if _hit_targets.size() >= max_hits:
			queue_free()

func _damage_overlapping() -> void:
	for body in $HitBoxBala.get_overlapping_bodies():
		if body.is_in_group("enemy") and not _hit_targets.has(body):
			_hit_targets.append(body)
			_apply_damage(body)

func _apply_damage(body) -> void:
	var crits := _roll_crits()
	var final_damage = damage * player_atack * pow(PlayerStats.crit_multiplier, crits)
	if randf() < PlayerStats.dano_extra_chance:
		final_damage += PlayerStats.dano_extra_amount
	if body.has_method("take_damage"):
		body.take_damage(final_damage, crits > 0, crits)

# Crítico multi-nivel: cada 100% de probabilidad es un crítico garantizado más.
# Ej: 250% = 2 críticos + 50% de chance para un tercero.
func _roll_crits() -> int:
	var chance := PlayerStats.crit_chance
	var crits := 0
	while chance >= 1.0:
		crits += 1
		chance -= 1.0
	if randf() < chance:
		crits += 1
	return crits
