extends VBoxContainer

@onready var a1 = get_parent()
@onready var a2 = a1.get_parent()
@onready var abuelo = a2.get_parent()

var arma

func set_arma(nueva_arma):
	arma = nueva_arma

	$ColorRect2/ColorRect/ArmaTexture.texture = arma[0].texture_sprite
	$ColorRect2/VBoxContainer/Arma.text = arma[0].weapon_name


func _on_seleccionar_pressed() -> void:
	abuelo.visible = false

	if arma[1] == 0:
		if WeaponManager.weapons.size() < WeaponManager.MAX_WEAPONS:
			WeaponManager.add_weapon(arma[0])
	else:
		WeaponManager.upgrade_weapon(arma[0])

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
