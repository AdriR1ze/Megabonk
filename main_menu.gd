extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$CenterContainer/VBoxContainer/JugarBtn.pressed.connect(_on_jugar_pressed)
	$CenterContainer/VBoxContainer/InventarioBtn.pressed.connect(_on_inventario_pressed)
	$CenterContainer/VBoxContainer/SalirBtn.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed() -> void:
	GameManager.reset_run()
	PlayerStats.reset_for_new_run()
	ItemManager.limpiar_items()
	get_tree().change_scene_to_file("res://mundo.tscn")

func _on_inventario_pressed() -> void:
	get_tree().change_scene_to_file("res://inventory.tscn")

func _on_salir_pressed() -> void:
	get_tree().quit()
