class_name AuraSkill
extends Skill

@export var damage := 5.0
@export var radius := 4.0
@export var tick_interval := 0.5
@export var color := Color(1.0, 0.4, 0.1, 0.35)

var _zones: Array[AuraZone] = []

func apply(player: Node3D) -> void:
	if player == null:
		return
	var zone := AuraZone.new()
	zone.damage = damage
	zone.radius = radius
	zone.tick_interval = tick_interval
	zone.color = color
	player.add_child(zone)
	zone.position = Vector3(0, 1.0, 0)
	_zones.append(zone)

func remove(player: Node3D) -> void:
	if _zones.is_empty():
		return
	var zone: AuraZone = _zones.pop_back()
	if is_instance_valid(zone):
		zone.queue_free()

func remove_all(player: Node3D) -> void:
	for zone in _zones:
		if is_instance_valid(zone):
			zone.queue_free()
	_zones.clear()
