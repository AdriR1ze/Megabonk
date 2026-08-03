extends VBoxContainer
@onready var a1 = get_parent()
@onready var a2 = a1.get_parent()
@onready var abuelo = a2.get_parent()

var arma 
func _ready() -> void:
	pass
func _on_seleccionar_pressed() -> void:
	abuelo.visible = false
	if arma[1] == 0:
		if WeaponManager.weapons.size() <= 3:
			WeaponManager.add_weapon(arma[0])
	elif arma[1] == 1:
		WeaponManager.upgrade_weapon(arma[0])
	get_tree().paused = false
	


func _on_visibility_changed() -> void:
	if abuelo.visible == true:
		var armas = ArmaDB.get_all_armas_no_usadas()
		print("ARMA UI", armas)
		arma = armas.pick_random()
		print(arma)
		
		$ColorRect2/ColorRect/ArmaTexture.texture = arma[0].texture_sprite
		$ColorRect2/VBoxContainer/Arma.text = arma[0].weapon_name
