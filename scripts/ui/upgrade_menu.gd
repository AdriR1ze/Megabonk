extends Control
# Pantalla que se muestra al subir de nivel: 3 mejoras para elegir.

const DEFAULT_ICON = preload("res://icon.svg")

const RARITY_COLORS := {
	0: Color(0.62, 0.62, 0.62),   # COMMON
	1: Color(0.25, 0.6, 1.0),     # RARE
	2: Color(0.75, 0.35, 1.0),    # EPIC
	3: Color(1.0, 0.78, 0.2),     # LEGENDARY
}

const RARITY_BG := {
	0: Color(0.12, 0.13, 0.16),   # COMMON
	1: Color(0.09, 0.14, 0.20),   # RARE
	2: Color(0.14, 0.10, 0.20),   # EPIC
	3: Color(0.18, 0.14, 0.06),   # LEGENDARY
}

const RARITY_NAMES := {
	0: "COMÚN",
	1: "RARO",
	2: "ÉPICO",
	3: "LEGENDARIO",
}

@onready var cards_container: HBoxContainer = $Panel/VBoxContainer/CardsContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	UIManager.register_upgrade_screen(self)

func show_upgrades(upgrades: Array) -> void:
	for child in cards_container.get_children():
		child.queue_free()

	for upgrade in upgrades:
		if upgrade is UpgradeData:
			cards_container.add_child(_build_card(upgrade))

	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _build_card(upgrade: UpgradeData) -> Control:
	var rarity: int = upgrade.rarity
	var rarity_color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS[0])
	var bg_color: Color = RARITY_BG.get(rarity, RARITY_BG[0])

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(260, 330)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = rarity_color
	style.set_border_width_all(3)
	style.set_corner_radius_all(14)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 12
	btn.add_theme_stylebox_override("normal", style)

	var hover := style.duplicate() as StyleBoxFlat
	hover.bg_color = bg_color.lightened(0.07)
	hover.border_color = rarity_color.lightened(0.2)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := style.duplicate() as StyleBoxFlat
	pressed.bg_color = bg_color.lightened(0.03)
	btn.add_theme_stylebox_override("pressed", pressed)
	btn.add_theme_stylebox_override("focus", style)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	btn.add_child(vbox)

	var type_tag := Label.new()
	type_tag.text = _type_tag_text(upgrade)
	type_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	type_tag.add_theme_font_size_override("font_size", 11)
	type_tag.add_theme_color_override("font_color", rarity_color)
	vbox.add_child(type_tag)

	var icon_badge := PanelContainer.new()
	icon_badge.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0, 0, 0, 0.25)
	badge_style.set_corner_radius_all(10)
	badge_style.content_margin_left = 10
	badge_style.content_margin_right = 10
	badge_style.content_margin_top = 6
	badge_style.content_margin_bottom = 6
	icon_badge.add_theme_stylebox_override("panel", badge_style)
	var tex := TextureRect.new()
	tex.texture = upgrade.icon if upgrade.icon else DEFAULT_ICON
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.custom_minimum_size = Vector2(76, 76)
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_badge.add_child(tex)
	vbox.add_child(icon_badge)

	var name_lbl := Label.new()
	name_lbl.text = upgrade.upgrade_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 21)
	name_lbl.add_theme_color_override("font_color", rarity_color.lightened(0.2))
	name_lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	name_lbl.add_theme_constant_override("shadow_offset_x", 1)
	name_lbl.add_theme_constant_override("shadow_offset_y", 1)
	vbox.add_child(name_lbl)

	var sep := HSeparator.new()
	sep.modulate = rarity_color
	vbox.add_child(sep)

	var desc_lbl := Label.new()
	desc_lbl.text = upgrade.description
	desc_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.92, 0.92, 0.92))
	desc_lbl.size_flags_vertical = Control.SIZE_EXPAND_FILL
	desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(desc_lbl)

	var foot := Label.new()
	foot.text = RARITY_NAMES.get(rarity, "")
	foot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foot.add_theme_font_size_override("font_size", 11)
	foot.add_theme_color_override("font_color", rarity_color)
	vbox.add_child(foot)

	btn.pressed.connect(func(): _on_upgrade_pressed(upgrade))
	return btn

func _type_tag_text(upgrade: UpgradeData) -> String:
	match upgrade.type:
		UpgradeData.UpgradeType.STAT:
			return "MEJORA"
		UpgradeData.UpgradeType.NEW_WEAPON:
			return "NUEVA ARMA"
		UpgradeData.UpgradeType.UPGRADE_WEAPON:
			return "MEJORAR ARMA"
		UpgradeData.UpgradeType.SYNERGY:
			return "SINERGIA"
	return ""

func _on_upgrade_pressed(upgrade: UpgradeData) -> void:
	UpgradeManager.apply_upgrade(upgrade)
	if PlayerStats.pending_levels == 0:
		visible = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
