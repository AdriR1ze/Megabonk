class_name AuraDeFuego
extends AuraSkill

func _init() -> void:
	skill_name = "Aura de Fuego"
	description = "Una llama ardiente quema a los enemigos cercanos."
	damage = 8.0
	radius = 4.5
	tick_interval = 0.4
	color = Color(1.0, 0.45, 0.1, 0.35)
