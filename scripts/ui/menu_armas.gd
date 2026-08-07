extends Control

@onready var cartas = [
	$ColorRect/HBoxContainer/ArmaSelect,
	$ColorRect/HBoxContainer/ArmaSelect2,
	$ColorRect/HBoxContainer/ArmaSelect3
]

func _ready() -> void:
	visible = false
	GameManager.seleccionar_arma.connect(_on_seleccionar_arma)

func _on_seleccionar_arma():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	# Forzar mouse mode en el próximo frame por si el juego lo sobreescribe
	await get_tree().process_frame
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE



	var opciones = ArmaDB.get_all_armas_no_usadas()
	opciones.shuffle()

	for carta in cartas:
		if opciones.is_empty():
			carta.visible = false
			continue

		carta.visible = true
		carta.set_arma(opciones.pop_front())
