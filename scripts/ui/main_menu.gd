extends Control

var _join_dialog: AcceptDialog = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CenterContainer/VBoxContainer/JugarBtn.pressed.connect(_on_jugar_pressed)
	$CenterContainer/VBoxContainer/HostBtn.pressed.connect(_on_host_pressed)
	$CenterContainer/VBoxContainer/JoinBtn.pressed.connect(_on_join_pressed)
	$CenterContainer/VBoxContainer/InventarioBtn.pressed.connect(_on_inventario_pressed)
	$CenterContainer/VBoxContainer/SalirBtn.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed() -> void:
	GameManager.reset_run()
	PlayerStats.reset_for_new_run()
	ItemManager.limpiar_items()
	get_tree().change_scene_to_file("res://scenes/mundo.tscn")

func _on_host_pressed() -> void:
	NetworkManager.host_game()
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_join_pressed() -> void:
	_show_join_dialog()

func _show_join_dialog() -> void:
	if _join_dialog:
		_join_dialog.queue_free()

	_join_dialog = AcceptDialog.new()
	_join_dialog.title = "Unirse a partida"
	_join_dialog.ok_button_text = "Conectar"
	_join_dialog.exclusive = true

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 10)

	var label = Label.new()
	label.text = "Ingresa la IP del host:"
	vbox.add_child(label)

	var ip_input = LineEdit.new()
	ip_input.placeholder_text = "192.168.1.X"
	ip_input.text = "127.0.0.1"
	vbox.add_child(ip_input)

	_join_dialog.add_child(vbox)

	_join_dialog.confirmed.connect(func():
		var ip = ip_input.text.strip_edges()
		if ip.is_empty():
			ip = "127.0.0.1"
		NetworkManager.join_game(ip)
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
	)

	add_child(_join_dialog)
	_join_dialog.popup_centered()
	ip_input.grab_focus()

func _on_inventario_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/inventory.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()
