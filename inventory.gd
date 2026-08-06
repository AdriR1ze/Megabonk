extends Control
# Inventario: catálogo de armas e ítems con desbloqueados/bloqueados y sus efectos.

const DEFAULT_ICON = preload("res://icon.svg")

const RARITY_COLORS := {
	0: Color(0.75, 0.75, 0.75),
	1: Color(0.35, 0.6, 1.0),
	2: Color(0.75, 0.35, 1.0),
	3: Color(1.0, 0.85, 0.25),
}

const RARITY_NAMES := {
	0: "COMÚN",
	1: "RARO",
	2: "ÉPICO",
	3: "LEGENDARIO",
}

@onready var tabs: TabContainer = $TabContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$BackBtn.pressed.connect(_on_back_pressed)
	_build_tabs()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _build_tabs() -> void:
	var armas_tab := _build_armas_tab()
	armas_tab.name = "Armas"
	tabs.add_child(armas_tab)

	var items_tab := _build_items_tab()
	items_tab.name = "Ítems"
	tabs.add_child(items_tab)

# --- Armas ---

func _build_armas_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid := GridContainer.new()
	grid.columns = 4
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)

	var armas: Array = ArmaDB.get_all_armas()
	armas.sort_custom(func(a, b): return a.id < b.id)
	for w in armas:
		if w is WeaponData:
			grid.add_child(_build_weapon_card(w))
	return scroll

func _build_weapon_card(w: WeaponData) -> Control:
	var discovered := SaveManager.is_weapon_discovered(w.id)
	var card := _make_card(Vector2(235, 265), w.texture_sprite, w.weapon_name, w.rarity, discovered)
	var body := card.get_meta("body") as Label

	if not discovered:
		body.text = "BLOQUEADO\nObtené esta arma\nen una partida"
		return card

	var lines := PackedStringArray()
	lines.append("Daño: %.0f" % w.damage)
	lines.append("Cadencia: %.2fs" % w.cooldown)
	lines.append("Rango: %.0f" % w.rango)
	lines.append("Alcance vel.: %.0f" % w.projectile_speed)
	lines.append("")
	lines.append("Por nivel:")
	lines.append("+%.0f Daño" % w.crecimiento_damage)
	if w.crecimiento_rango > 0:
		lines.append("+%.1f Rango" % w.crecimiento_rango)
	if w.crecimiento_cooldown > 0:
		lines.append("-%.2fs Cadencia" % w.crecimiento_cooldown)
	body.text = "\n".join(lines)
	return card

# --- Ítems ---

func _build_items_tab() -> Control:
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	var grid := GridContainer.new()
	grid.columns = 5
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 14)
	grid.add_theme_constant_override("v_separation", 14)
	scroll.add_child(grid)

	var items: Array = ItemDB.get_all_items()
	items.sort_custom(func(a, b): return a.id < b.id)
	for it in items:
		if it is Item:
			grid.add_child(_build_item_card(it))
	return scroll

func _build_item_card(it: Item) -> Control:
	var discovered := SaveManager.is_item_discovered(it.id)
	var card := _make_card(Vector2(200, 230), it.texture_sprite, it.display_name, 0, discovered)
	var body := card.get_meta("body") as Label

	if not discovered:
		body.text = "BLOQUEADO\nObtenelo abriendo\ncofres en una partida"
		return card

	var lines := PackedStringArray()
	lines.append(it.description)
	if it.skill:
		lines.append("")
		lines.append("Habilidad: " + it.skill.skill_name)
		if it.skill.description != "":
			lines.append(it.skill.description)
	else:
		if it.move_speed > 0.0:
			lines.append("+%d%% Velocidad de movimiento" % round(it.move_speed * 100))
		if it.atack > 0.0:
			lines.append("+%d%% Daño" % round(it.atack * 100))
		if it.atq_speed > 0.0:
			lines.append("+%d%% Velocidad de ataque" % round(it.atq_speed * 100))
		if it.defense > 0.0:
			lines.append("+%.1f Armadura" % it.defense)
		if it.evasion > 0.0:
			lines.append("+%d%% Evasión" % round(it.evasion * 100))
		if it.crit_chance > 0.0:
			lines.append("+%d%% Crítico" % round(it.crit_chance * 100))
		if it.xp_multiplicator > 0.0:
			lines.append("+%d%% XP" % round(it.xp_multiplicator * 100))
	body.text = "\n".join(lines)
	return card

# --- Utilidades de tarjeta ---

func _make_card(size: Vector2, tex: Texture2D, name_text: String, rarity: int, unlocked: bool) -> Control:
	var card := PanelContainer.new()
	card.custom_minimum_size = size

	var rarity_color: Color = RARITY_COLORS.get(rarity, RARITY_COLORS[0])
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.12, 0.12, 0.18, 0.95)
	style.set_border_width_all(3)
	style.border_color = rarity_color if unlocked else Color(0.35, 0.35, 0.35)
	style.set_corner_radius_all(10)
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	var tex_rect := TextureRect.new()
	tex_rect.texture = tex if tex else DEFAULT_ICON
	tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex_rect.custom_minimum_size = Vector2(48, 48)
	tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex_rect.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	if not unlocked:
		tex_rect.modulate = Color(0.35, 0.35, 0.35)
	vbox.add_child(tex_rect)

	var name_lbl := Label.new()
	name_lbl.text = name_text if unlocked else name_text
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", rarity_color if unlocked else Color(0.5, 0.5, 0.5))
	vbox.add_child(name_lbl)

	var rarity_lbl := Label.new()
	rarity_lbl.text = RARITY_NAMES.get(rarity, "") if unlocked else "BLOQUEADO"
	rarity_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rarity_lbl.add_theme_font_size_override("font_size", 12)
	rarity_lbl.add_theme_color_override("font_color", rarity_color if unlocked else Color(0.5, 0.5, 0.5))
	vbox.add_child(rarity_lbl)

	var body := Label.new()
	body.add_theme_font_size_override("font_size", 12)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	vbox.add_child(body)

	card.set_meta("body", body)
	return card
