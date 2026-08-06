class_name AuraVenenosa
extends AuraSkill

func _init() -> void:
	skill_name = "Aura Venenosa"
	description = "Un veneno corrosivo que daña a los enemigos cercanos."
	damage = 6.0
	radius = 3.5
	tick_interval = 0.7
	color = Color(0.4, 0.8, 0.2, 0.35)
