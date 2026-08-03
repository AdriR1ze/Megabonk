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

	var opciones = ArmaDB.get_all_armas_no_usadas()
	opciones.shuffle()

	for carta in cartas:
		if opciones.is_empty():
			carta.visible = false
			continue

		carta.visible = true
		carta.set_arma(opciones.pop_front())
