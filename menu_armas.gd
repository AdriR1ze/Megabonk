extends Control

func _ready() -> void:
	visible = false
	GameManager.seleccionar_arma.connect(_on_seleccionar_arma)

func _on_seleccionar_arma():
	visible = true
	get_tree().paused = true
