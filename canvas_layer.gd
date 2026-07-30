extends Control
func _ready() -> void:
	ItemManager.stats_changed.connect(_on_stats_changed)
	
func _process(delta: float) -> void:
	print("hola")
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		visible = !visible
		get_tree().paused = not get_tree().paused
		
func _on_stats_changed():
	$ScrollContainer/VBoxContainer/Fuerza/ValorStat.text = str(PlayerStats.atack)
	$ScrollContainer/VBoxContainer/MoveSpeed/ValorStat.text = str(PlayerStats.move_speed)
	$ScrollContainer/VBoxContainer/AtqSpeed/ValorStat.text = str(PlayerStats.atq_speed)
	
	
	
