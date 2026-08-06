class_name DanoExtraSkill
extends Skill

@export var chance := 0.2
@export var extra_damage := 20.0

func _init() -> void:
	skill_name = "Daño Extra"
	description = "Probabilidad del 20%% de causar 20 de daño adicional al disparar."

func apply(player: Node3D) -> void:
	if player == null:
		return
	PlayerStats.dano_extra_chance += chance
	PlayerStats.dano_extra_amount = max(PlayerStats.dano_extra_amount, extra_damage)

func remove(player: Node3D) -> void:
	if player == null:
		return
	PlayerStats.dano_extra_chance = max(0.0, PlayerStats.dano_extra_chance - chance)
	if PlayerStats.dano_extra_chance <= 0.0:
		PlayerStats.dano_extra_amount = 0.0
