extends Control

# Stats mostradas en el panel de pausa (nombre, propiedad de PlayerStats, formato).
const STATS := [
	{"name": "Vida Máxima", "prop": "max_health", "fmt": "%.0f"},
	{"name": "Fuerza", "prop": "atack", "fmt": "x%.2f"},
	{"name": "Vel. Movimiento", "prop": "move_speed", "fmt": "x%.2f"},
	{"name": "Vel. Ataque", "prop": "atq_speed", "fmt": "x%.2f"},
	{"name": "Armadura", "prop": "defense", "fmt": "%.1f"},
	{"name": "Crítico", "prop": "crit_chance", "fmt": "%.0f%%", "mult": 100},
	{"name": "Daño Crítico", "prop": "crit_multiplier", "fmt": "x%.1f"},
	{"name": "Evasión", "prop": "evasion", "fmt": "%.0f%%", "mult": 100},
	{"name": "Regeneración", "prop": "regen", "fmt": "%.1f/s"},
	{"name": "XP Bonus", "prop": "xp_multiplicator", "fmt": "x%.2f"},
	{"name": "Vel. Proyectiles", "prop": "projectile_speed", "fmt": "x%.2f"},
	{"name": "Perforación Extra", "prop": "pierce_bonus", "fmt": "+%d"},
	{"name": "Rango", "prop": "range_multiplier", "fmt": "x%.2f"},
	{"name": "Área", "prop": "area_multiplier", "fmt": "x%.2f"},
	{"name": "Suerte", "prop": "luck", "fmt": "x%.2f"},
	{"name": "Daño Extra", "prop": "dano_extra_amount", "fmt": "+%.0f"},
	{"name": "Prob. Daño Extra", "prop": "dano_extra_chance", "fmt": "%.0f%%", "mult": 100},
]

@onready var volver_btn: Button = $ButtonsContainer/Button
@onready var salir_btn: Button = $ButtonsContainer/Button2
@onready var menu_btn: Button = $ButtonsContainer/Button3
@onready var items_list: VBoxContainer = $ItemsPanel/MarginContainer/VBoxContainer/ScrollContainer/ItemsList
@onready var hover_desc_label: Label = $ItemsPanel/MarginContainer/VBoxContainer/HoverDescriptionLabel

const DEFAULT_ICON = preload("res://icon.svg")

func _ready() -> void:
	ItemManager.stats_changed.connect(_on_stats_changed)
	if volver_btn:
		volver_btn.pressed.connect(_on_volver_pressed)
	if salir_btn:
		salir_btn.pressed.connect(_on_salir_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
	_build_stats_list()
	_on_stats_changed()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_menu()

func toggle_menu() -> void:
	visible = not visible
	get_tree().paused = visible
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_on_stats_changed()
		_update_items_list()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_volver_pressed() -> void:
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_salir_pressed() -> void:
	get_tree().quit()

func _on_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_run()
	PlayerStats.reset_for_new_run()
	ItemManager.limpiar_items()
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _build_stats_list() -> void:
	var list: VBoxContainer = $MenuPanel/VBoxContainer/ScrollContainer/VBoxContainer
	for child in list.get_children():
		child.queue_free()
	for stat in STATS:
		list.add_child(_make_stat_row(stat))

func _make_stat_row(stat: Dictionary) -> Control:
	var hbox := HBoxContainer.new()
	hbox.custom_minimum_size = Vector2(0, 26)
	hbox.set_meta("stat", stat)

	var name_lbl := Label.new()
	name_lbl.text = stat["name"]
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	hbox.add_child(name_lbl)

	var value_lbl := Label.new()
	value_lbl.name = "ValorStat"
	value_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_lbl.add_theme_font_size_override("font_size", 14)
	value_lbl.add_theme_color_override("font_color", Color(1, 0.85, 0.35))
	hbox.add_child(value_lbl)

	return hbox

func _on_stats_changed() -> void:
	var list: VBoxContainer = $MenuPanel/VBoxContainer/ScrollContainer/VBoxContainer
	for row in list.get_children():
		if not row.has_meta("stat"):
			continue
		var stat: Dictionary = row.get_meta("stat")
		var value_lbl: Label = row.get_node("ValorStat")
		var mult: float = stat.get("mult", 1.0)
		var raw = PlayerStats.get(stat["prop"])
		var val = raw * mult
		if (stat["fmt"] as String).contains("%d"):
			value_lbl.text = stat["fmt"] % int(val)
		else:
			value_lbl.text = stat["fmt"] % val

func _update_items_list() -> void:
	if not items_list:
		return
		
	if hover_desc_label:
		hover_desc_label.text = "Pasa el mouse sobre un ítem para ver su descripción"
		
	for child in items_list.get_children():
		child.queue_free()
		
	if ItemManager.items_player.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "No tenés ítems juntados"
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		items_list.add_child(empty_lbl)
		return
		
	# Count items by ID
	var item_counts = {}
	for item_id in ItemManager.items_player:
		if item_counts.has(item_id):
			item_counts[item_id] += 1
		else:
			item_counts[item_id] = 1
			
	for item_id in item_counts.keys():
		var item: Item = ItemDB.get_item(item_id)
		var count = item_counts[item_id]
		
		# Item container panel for hover detection
		var item_box = PanelContainer.new()
		item_box.mouse_filter = Control.MOUSE_FILTER_STOP
		
		var hbox = HBoxContainer.new()
		hbox.custom_minimum_size = Vector2(0, 36)
		
		# Item Icon Image
		var tex_rect = TextureRect.new()
		if item and item.texture_sprite:
			tex_rect.texture = item.texture_sprite
		else:
			tex_rect.texture = DEFAULT_ICON
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.custom_minimum_size = Vector2(32, 32)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(tex_rect)
		
		# Item Name & Count
		var name_lbl = Label.new()
		var text_name = item.display_name if (item and item.display_name != "") else ("Item #" + str(item_id))
		if count > 1:
			text_name += " x" + str(count)
		name_lbl.text = " " + text_name
		name_lbl.add_theme_font_size_override("font_size", 15)
		hbox.add_child(name_lbl)
		
		item_box.add_child(hbox)
		
		var desc_text = item.description if (item and item.description != "") else "Sin descripción."
		item_box.tooltip_text = text_name + "\n" + desc_text
		
		# Connect mouse enter/exit for description display
		item_box.mouse_entered.connect(func():
			if hover_desc_label:
				hover_desc_label.text = text_name + ": " + desc_text
		)
		item_box.mouse_exited.connect(func():
			if hover_desc_label:
				hover_desc_label.text = "Pasa el mouse sobre un ítem para ver su descripción"
		)
		
		items_list.add_child(item_box)
