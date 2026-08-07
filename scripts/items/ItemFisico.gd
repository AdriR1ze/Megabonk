extends Area3D

var player_inside: bool = false
@onready var prompt_label: Label3D = $PromptLabel

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if prompt_label:
		prompt_label.visible = false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and _is_local_player(body):
		player_inside = true
		_update_prompt()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and _is_local_player(body):
		player_inside = false
		if prompt_label:
			prompt_label.visible = false

func _is_local_player(body: Node3D) -> bool:
	return not multiplayer.has_multiplayer_peer() or body.is_multiplayer_authority()

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

	var item: Item = _pick_item_lucky(items)
	ItemManager.agregar_item(item.id)
	EventBus.item_picked.emit(item.id)
	print("Conseguiste: ", item.display_name)

	if prompt_label:
		prompt_label.visible = false

	queue_free()

# Sistema de suerte: a mayor suerte, más peso en rarezas altas.
func _pick_item_lucky(all_items: Array) -> Item:
	var luck := PlayerStats.luck
	var grouped: Array = [[], [], [], []]
	for it in all_items:
		if it is Item:
			grouped[it.rarity].append(it)

	var tier_weights := PackedFloat32Array([
		50.0,
		25.0 + luck * 8.0,
		10.0 + luck * 5.0,
		5.0 + luck * 3.0,
	])
	var total := 0.0
	for w in tier_weights:
		total += w
	var roll := randf() * total
	var accum := 0.0
	var chosen_tier := 0
	for t in 4:
		accum += tier_weights[t]
		if roll < accum:
			chosen_tier = t
			break

	var pool: Array = grouped[chosen_tier]
	if pool.is_empty():
		pool = grouped[0]
	if pool.is_empty():
		return all_items.pick_random()
	return pool.pick_random()
