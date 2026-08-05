extends Control

@onready var volver_btn: Button = $ButtonsContainer/Button
@onready var salir_btn: Button = $ButtonsContainer/Button2
@onready var items_list: VBoxContainer = $ItemsPanel/MarginContainer/VBoxContainer/ScrollContainer/ItemsList
@onready var hover_desc_label: Label = $ItemsPanel/MarginContainer/VBoxContainer/HoverDescriptionLabel

const DEFAULT_ICON = preload("res://icon.svg")

func _ready() -> void:
	ItemManager.stats_changed.connect(_on_stats_changed)
	if volver_btn:
		volver_btn.pressed.connect(_on_volver_pressed)
	if salir_btn:
		salir_btn.pressed.connect(_on_salir_pressed)

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

func _on_stats_changed() -> void:
	if has_node("ScrollContainer/VBoxContainer/Fuerza/ValorStat"):
		$ScrollContainer/VBoxContainer/Fuerza/ValorStat.text = str(PlayerStats.atack)
	if has_node("ScrollContainer/VBoxContainer/MoveSpeed/ValorStat"):
		$ScrollContainer/VBoxContainer/MoveSpeed/ValorStat.text = str(PlayerStats.move_speed)
	if has_node("ScrollContainer/VBoxContainer/AtqSpeed/ValorStat"):
		$ScrollContainer/VBoxContainer/AtqSpeed/ValorStat.text = str(PlayerStats.atq_speed)

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
