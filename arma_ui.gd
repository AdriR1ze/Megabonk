extends VBoxContainer

@onready var a1 = get_parent()
@onready var a2 = a1.get_parent()
@onready var abuelo = a2.get_parent()

var arma

func set_arma(nueva_arma):
	arma = nueva_arma

	var data : WeaponData = arma[0]
	var is_upgrade = (arma[1] == 1)

	$ColorRect2/ColorRect/ArmaTexture.texture = data.texture_sprite

	# Limpiar labels creados dinámicamente si los hay
	for child in $ColorRect2/VBoxContainer.get_children():
		if child.name != "Arma":
			child.queue_free()

	if is_upgrade:
		var current_lvl = 1
		for w in WeaponManager.weapons:
			if is_instance_valid(w) and w.data.id == data.id:
				current_lvl = w.data.level
				break
		
		$ColorRect2/VBoxContainer/Arma.text = data.weapon_name + " (Niv. " + str(current_lvl + 1) + ")"
		
		var desc_label = Label.new()
		desc_label.name = "UpgradeStats"
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3)) # Amarillo para upgrade
		
		var stats_text = "¡MEJORA!\n"
		if data.crecimiento_damage > 0:
			stats_text += "+Daño: +" + str(data.crecimiento_damage) + "\n"
		if data.crecimiento_cooldown > 0:
			stats_text += "-Cooldown: -" + str(data.crecimiento_cooldown) + "s\n"
		if data.crecimiento_rango > 0:
			stats_text += "+Rango: +" + str(data.crecimiento_rango) + "\n"
		if data.crecimiento_pierce > 0:
			stats_text += "+Pierce: +" + str(data.crecimiento_pierce) + "\n"
			
		desc_label.text = stats_text
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$ColorRect2/VBoxContainer.add_child(desc_label)
	else:
		$ColorRect2/VBoxContainer/Arma.text = data.weapon_name + " (NUEVA)"
		
		var desc_label = Label.new()
		desc_label.name = "UpgradeStats"
		desc_label.add_theme_font_size_override("font_size", 12)
		desc_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.4)) # Verde para nueva
		
		var stats_text = "NUEVA ARMA\n"
		stats_text += "Daño: " + str(data.damage) + "\n"
		stats_text += "Cooldown: " + str(data.cooldown) + "s\n"
		stats_text += "Rango: " + str(data.rango)
		
		desc_label.text = stats_text
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$ColorRect2/VBoxContainer.add_child(desc_label)


func _on_seleccionar_pressed() -> void:
	if owner:
		owner.visible = false
	elif is_instance_valid(abuelo):
		abuelo.visible = false

	if arma[1] == 0:
		if WeaponManager.weapons.size() < WeaponManager.MAX_WEAPONS:
			WeaponManager.add_weapon(arma[0])
		else:
			WeaponManager.upgrade_weapon(arma[0])
	else:
		WeaponManager.upgrade_weapon(arma[0])

	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
