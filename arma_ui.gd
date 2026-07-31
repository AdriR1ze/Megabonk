extends VBoxContainer
@onready var a1 = get_parent()
@onready var a2 = a1.get_parent()
@onready var abuelo = a2.get_parent()
@export var ArmaID : int
var arma : WeaponData
func _ready() -> void:
	pass
func _on_seleccionar_pressed() -> void:
	abuelo.visible = false
	if WeaponManager.weapons.size() <= 3:
		WeaponManager.add_weapon(arma.id)
	elif WeaponManager.weapons.size() > 3:
		WeaponManager.upgrade_weapon()
	get_tree().paused = false
	


func _on_visibility_changed() -> void:
	if visible == true:
		var armas = ArmaDB.get_all_armas_no_usadas()
		$ColorRect2/ColorRect/ArmaTexture.texture = arma.texture_sprite
		$ColorRect2/VBoxContainer/Arma.text = arma.weapon_name
