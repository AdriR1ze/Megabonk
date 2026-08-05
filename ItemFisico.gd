extends Area3D

var player_inside: bool = false
@onready var prompt_label: Label3D = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		_update_prompt()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		if prompt_label:
			prompt_label.visible = false

func _update_prompt() -> void:
	if not prompt_label:
		return
	var price = GameManager.get_chest_price()
	prompt_label.text = "[E] Abrir ($" + str(price) + ")"
	prompt_label.modulate = Color(1, 1, 1, 1)
	prompt_label.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if not player_inside:
		return
		
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E or event.physical_keycode == KEY_E:
			_try_open_chest()

func _try_open_chest() -> void:
	if !GameManager.open_chest():
		if prompt_label:
			prompt_label.text = "¡Faltan monedas! ($" + str(GameManager.get_chest_price()) + ")"
			prompt_label.modulate = Color(1, 0.3, 0.3, 1)
		print("No tenés monedas suficentes. Tienes:", GameManager.coins)
		return

	var items = ItemDB.get_all_items()
	if items.is_empty():
		return

	var item: Item = items.pick_random()
	ItemManager.agregar_item(item.id)
	print("Conseguiste: ", item.display_name)

	if prompt_label:
		prompt_label.visible = false

	queue_free()
