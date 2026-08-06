class_name SobrevidaSkill
extends Skill

@export var amount := 20.0
@export var refill_interval := 10.0

var _zone: SobrevidaZone
var _stacks := 0

func _init() -> void:
	skill_name = "Sobrevida"
	description = "Escudo naranja de +%d de vida que se recarga cada %d segundos. Apilable (+%d por stack)." % [int(amount), int(refill_interval), int(amount)]

func apply(player: Node3D) -> void:
	if player == null:
		return
	_stacks += 1
	var total := amount * _stacks
	if _zone and is_instance_valid(_zone):
		_zone.max_health = total
		_zone.current = total
		_zone.refresh()
		return
	var zone := SobrevidaZone.new()
	zone.max_health = total
	zone.refill_interval = refill_interval
	player.add_child(zone)
	_zone = zone

func remove(player: Node3D) -> void:
	if _zone and is_instance_valid(_zone):
		_stacks = max(0, _stacks - 1)
		if _stacks <= 0:
			_zone.queue_free()
			_zone = null
			return
		_zone.max_health = amount * _stacks
		_zone.current = min(_zone.current, _zone.max_health)
		_zone.refresh()
