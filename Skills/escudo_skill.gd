class_name EscudoSkill
extends Skill

@export var cooldown := 10.0

var _escudo: EscudoAbsorbente
var _stacks := 0

func _init() -> void:
	skill_name = "Escudo Absorbente"
	description = "Un escudo mágico que bloquea un golpe completo cada %d segundos. Apilable (+1 bloqueo por stack)." % [int(cooldown)]

func apply(player: Node3D) -> void:
	if player == null:
		return
	_stacks += 1
	if _escudo and is_instance_valid(_escudo):
		_escudo.max_charges = _stacks
		_escudo.charges = _stacks
		_escudo.refresh()
		return
	var escudo := EscudoAbsorbente.new()
	escudo.cooldown = cooldown
	escudo.max_charges = _stacks
	player.add_child(escudo)
	_escudo = escudo

func remove(player: Node3D) -> void:
	if _escudo and is_instance_valid(_escudo):
		_stacks = max(0, _stacks - 1)
		if _stacks <= 0:
			_escudo.queue_free()
			_escudo = null
			return
		_escudo.max_charges = _stacks
		_escudo.charges = min(_escudo.charges, _stacks)
		_escudo.refresh()
