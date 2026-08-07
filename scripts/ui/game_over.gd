extends Control

@onready var tiempo_val: Label = $Panel/VBoxContainer/StatsGrid/TiempoVal
@onready var nivel_val: Label = $Panel/VBoxContainer/StatsGrid/NivelVal
@onready var kills_val: Label = $Panel/VBoxContainer/StatsGrid/KillsVal
@onready var monedas_val: Label = $Panel/VBoxContainer/StatsGrid/MonedasVal
@onready var plata_guardada_val: Label = $Panel/VBoxContainer/StatsGrid/PlataGuardadaVal
@onready var items_container: HBoxContainer = $Panel/VBoxContainer/ScrollContainer/ItemsContainer
@onready var reintentar_btn: Button = $Panel/VBoxContainer/ButtonsHBox/ReintentarBtn
@onready var salir_btn: Button = $Panel/VBoxContainer/ButtonsHBox/SalirBtn

const DEFAULT_ICON = preload("res://icon.svg")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	UIManager.register_game_over_screen(self)
	EventBus.player_died.connect(show_game_over)
	
	if reintentar_btn:
		reintentar_btn.pressed.connect(_on_reintentar_pressed)
	if salir_btn:
		salir_btn.pressed.connect(_on_salir_pressed)

func show_game_over() -> void:
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Cargar estadísticas
	var total_sec = int(WaveManager.elapsed_time)
	var mins = total_sec / 60
	var secs = total_sec % 60
	if tiempo_val:
		tiempo_val.text = "%02d:%02d" % [mins, secs]
	if nivel_val:
		nivel_val.text = str(PlayerStats.level)
	if kills_val:
		kills_val.text = str(GameManager.enemies_killed)
	if monedas_val:
		monedas_val.text = str(GameManager.coins)

	# Guardar progresión permanente (monedas acumuladas)
	SaveManager.end_run(GameManager.coins, PlayerStats.level, GameManager.enemies_killed, WaveManager.elapsed_time)
	if plata_guardada_val:
		plata_guardada_val.text = str(SaveManager.persistent_coins)

	# Cargar Ítems recolectados
	_populate_items()

func _populate_items() -> void:
	if not items_container:
		return

	for child in items_container.get_children():
		child.queue_free()

	if ItemManager.items_player.is_empty():
		var empty_lbl = Label.new()
		empty_lbl.text = "Sin ítems recolectados"
		empty_lbl.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		items_container.add_child(empty_lbl)
		return

	# Agrupar ítems por ID
	var item_counts = {}
	for item_id in ItemManager.items_player:
		if item_counts.has(item_id):
			item_counts[item_id] += 1
		else:
			item_counts[item_id] = 1

	for item_id in item_counts.keys():
		var item: Item = ItemDB.get_item(item_id)
		var count = item_counts[item_id]

		var item_card = PanelContainer.new()
		var vbox = VBoxContainer.new()
		vbox.custom_minimum_size = Vector2(60, 60)
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER

		var tex_rect = TextureRect.new()
		if item and item.texture_sprite:
			tex_rect.texture = item.texture_sprite
		else:
			tex_rect.texture = DEFAULT_ICON
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.custom_minimum_size = Vector2(36, 36)
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		vbox.add_child(tex_rect)

		var count_lbl = Label.new()
		var text_name = item.display_name if (item and item.display_name != "") else "Item #" + str(item_id)
		count_lbl.text = "x" + str(count)
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count_lbl.add_theme_font_size_override("font_size", 12)
		vbox.add_child(count_lbl)

		item_card.add_child(vbox)
		var desc = item.description if (item and item.description != "") else ""
		item_card.tooltip_text = text_name + "\n" + desc
		items_container.add_child(item_card)

func _on_reintentar_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_run()
	PlayerStats.reset_for_new_run()
	ItemManager.limpiar_items()
	get_tree().reload_current_scene()

func _on_salir_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_run()
	PlayerStats.reset_for_new_run()
	ItemManager.limpiar_items()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
