extends Node3D

signal shop_closed

@onready var area: Area3D = $Area3D
@onready var prompt: Label3D = $Prompt
@onready var mesh_root: Node3D = $Mesh

var _player_near: bool = false
var _ui_panel: Control = null
var _legendary_items: Array = []
var _shop_items: Array = []
var _item_slots: Array = []

const LEGENDARY_RARITY: int = 3
const ITEMS_PER_SHOP: int = 3

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_visuals()
	add_to_group("tienda_legendaria")
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	_build_legendary_pool()
	_pick_shop_items()
	_start_floating_animation()

func _build_visuals() -> void:
	var mesh_node = Node3D.new()
	mesh_node.name = "Mesh"
	add_child(mesh_node)
	mesh_root = mesh_node

	# Pedestal
	var pedestal_mat = StandardMaterial3D.new()
	pedestal_mat.albedo_color = Color(0.35, 0.3, 0.25)
	pedestal_mat.roughness = 0.5
	pedestal_mat.metallic = 0.3

	var pedestal_mesh = CylinderMesh.new()
	pedestal_mesh.material = pedestal_mat
	pedestal_mesh.top_radius = 0.8
	pedestal_mesh.bottom_radius = 1.0
	pedestal_mesh.height = 2.0

	var pedestal = MeshInstance3D.new()
	pedestal.name = "Pedestal"
	pedestal.position.y = 1.0
	pedestal.mesh = pedestal_mesh
	mesh_node.add_child(pedestal)

	# Orb
	var orb_mat = StandardMaterial3D.new()
	orb_mat.albedo_color = Color(1.0, 0.78, 0.2)
	orb_mat.roughness = 0.2
	orb_mat.metallic = 0.1
	orb_mat.emission_enabled = true
	orb_mat.emission = Color(1.0, 0.65, 0.1)
	orb_mat.emission_energy_multiplier = 2.5

	var orb_mesh = SphereMesh.new()
	orb_mesh.material = orb_mat
	orb_mesh.radius = 0.35
	orb_mesh.height = 0.7

	var orb = MeshInstance3D.new()
	orb.name = "Orb"
	orb.position.y = 2.3
	orb.mesh = orb_mesh
	mesh_node.add_child(orb)

	# Sign
	var sign_mesh = BoxMesh.new()
	sign_mesh.size = Vector3(1.6, 0.6, 0.1)

	var sign = MeshInstance3D.new()
	sign.name = "Sign"
	sign.position.y = 2.85
	sign.mesh = sign_mesh
	mesh_node.add_child(sign)

	# Area3D
	var area_node = Area3D.new()
	area_node.name = "Area3D"

	var col_shape = CollisionShape3D.new()
	col_shape.position.y = 1.5
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = 3.5
	col_shape.shape = sphere_shape
	area_node.add_child(col_shape)
	add_child(area_node)
	area = area_node

	# Prompt
	var label = Label3D.new()
	label.name = "Prompt"
	label.position.y = 3.8
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.render_priority = 10
	label.pixel_size = 0.004
	label.modulate = Color(1, 0.9, 0.4)
	label.outline_size = 1
	add_child(label)
	prompt = label

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_near = true
		_update_prompt()

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		_player_near = false
		prompt.visible = false

func _update_prompt() -> void:
	if _player_near and _ui_panel == null:
		var price = GameManager.get_chest_price() * 3
		prompt.text = "[E] Tienda legendaria ($" + str(price) + " c/u)"
		prompt.visible = true

func _build_legendary_pool() -> void:
	var all = ItemDB.get_all_items()
	_legendary_items.clear()
	for it in all:
		if it is Item and it.rarity == LEGENDARY_RARITY:
			_legendary_items.append(it)

func _pick_shop_items() -> void:
	var pool = _legendary_items.duplicate()
	pool.shuffle()
	_shop_items.clear()
	for i in range(min(ITEMS_PER_SHOP, pool.size())):
		_shop_items.append(pool[i])

func close() -> void:
	_hide_ui()
	queue_free()
	shop_closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if get_tree().paused:
		return
	if not _player_near:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if _ui_panel != null:
				_hide_ui()
			else:
				_show_ui()

func _show_ui() -> void:
	if _legendary_items.is_empty():
		return

	_ui_panel = Control.new()
	_ui_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_panel.process_mode = Node.PROCESS_MODE_ALWAYS

	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.5)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_ui_panel.add_child(overlay)

	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.custom_minimum_size = Vector2(720, 380)
	_ui_panel.add_child(panel)

	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.08, 0.09, 0.12, 0.95)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1.0, 0.78, 0.2)
	panel_style.corner_radius_top_left = 12
	panel_style.corner_radius_top_right = 12
	panel_style.corner_radius_bottom_left = 12
	panel_style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", panel_style)

	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 12)
	panel.add_child(main_vbox)

	var header_hbox = HBoxContainer.new()

	var spacer_left = Control.new()
	spacer_left.custom_minimum_size = Vector2(40, 0)
	header_hbox.add_child(spacer_left)

	var title = Label.new()
	title.text = "TIENDA LEGENDARIA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1.0, 0.78, 0.2))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title)

	var close_btn = Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.custom_minimum_size = Vector2(40, 40)
	close_btn.pressed.connect(func(): _hide_ui(); close())
	header_hbox.add_child(close_btn)

	main_vbox.add_child(header_hbox)

	var sep = HSeparator.new()
	main_vbox.add_child(sep)

	var items_hbox = HBoxContainer.new()
	items_hbox.add_theme_constant_override("separation", 16)
	items_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_child(items_hbox)

	_item_slots.clear()

	for item in _shop_items:
		var card = _create_item_card(item)
		items_hbox.add_child(card)

	var footer = Label.new()
	footer.text = "[ESC] Cerrar tienda"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	footer.add_theme_font_size_override("font_size", 12)
	main_vbox.add_child(footer)

	var canvas = get_tree().current_scene.get_node_or_null("CanvasLayer")
	if canvas:
		canvas.add_child(_ui_panel)
	else:
		add_child(_ui_panel)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true

func _create_item_card(item: Item) -> PanelContainer:
	var card = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var card_style = StyleBoxFlat.new()
	card_style.bg_color = Color(0.12, 0.13, 0.17, 0.95)
	card_style.border_width_left = 1
	card_style.border_width_right = 1
	card_style.border_width_top = 1
	card_style.border_width_bottom = 1
	card_style.border_color = Color(1.0, 0.78, 0.2, 0.6)
	card_style.corner_radius_top_left = 8
	card_style.corner_radius_top_right = 8
	card_style.corner_radius_bottom_left = 8
	card_style.corner_radius_bottom_right = 8
	card_style.content_margin_left = 10
	card_style.content_margin_right = 10
	card_style.content_margin_top = 10
	card_style.content_margin_bottom = 10
	card.add_theme_stylebox_override("panel", card_style)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	card.add_child(vbox)

	var icon = TextureRect.new()
	icon.texture = item.texture_sprite if item.texture_sprite else null
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(80, 80)
	vbox.add_child(icon)

	var name_lbl = Label.new()
	name_lbl.text = item.display_name
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.78, 0.2))
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(name_lbl)

	var desc = Label.new()
	desc.text = item.description
	desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc.add_theme_font_size_override("font_size", 11)
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	desc.custom_minimum_size = Vector2(180, 40)
	vbox.add_child(desc)

	var price_val = GameManager.get_chest_price() * 3
	var price_lbl = Label.new()
	price_lbl.text = "$" + str(price_val)
	price_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_lbl.add_theme_font_size_override("font_size", 20)
	price_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))
	vbox.add_child(price_lbl)

	var buy_btn = Button.new()
	buy_btn.text = "COMPRAR"
	buy_btn.add_theme_font_size_override("font_size", 14)
	buy_btn.custom_minimum_size = Vector2(140, 36)

	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = Color(0.15, 0.12, 0.04)
	btn_style.border_width_left = 1
	btn_style.border_width_right = 1
	btn_style.border_width_top = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = Color(1.0, 0.78, 0.2, 0.8)
	btn_style.corner_radius_top_left = 4
	btn_style.corner_radius_top_right = 4
	btn_style.corner_radius_bottom_left = 4
	btn_style.corner_radius_bottom_right = 4
	buy_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color(0.25, 0.2, 0.05)
	btn_hover.border_width_left = 1
	btn_hover.border_width_right = 1
	btn_hover.border_width_top = 1
	btn_hover.border_width_bottom = 1
	btn_hover.border_color = Color(1.0, 0.85, 0.3)
	btn_hover.corner_radius_top_left = 4
	btn_hover.corner_radius_top_right = 4
	btn_hover.corner_radius_bottom_left = 4
	btn_hover.corner_radius_bottom_right = 4
	buy_btn.add_theme_stylebox_override("hover", btn_hover)

	buy_btn.pressed.connect(func():
		_on_buy(item, price_lbl, buy_btn)
	)

	vbox.add_child(buy_btn)

	_item_slots.append({"btn": buy_btn, "price_lbl": price_lbl})
	return card

func _on_buy(item: Item, price_lbl: Label, buy_btn: Button) -> void:
	var price = GameManager.get_chest_price() * 3
	if GameManager.coins < price:
		price_lbl.text = "FALTAN MONEDAS"
		price_lbl.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
		buy_btn.disabled = true
		return

	GameManager.coins -= price
	ItemManager.agregar_item(item.id)
	EventBus.item_picked.emit(item.id)

	buy_btn.text = "COMPRADO!"
	buy_btn.disabled = true
	price_lbl.text = "OBTENIDO"
	price_lbl.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))

	await get_tree().create_timer(1.2).timeout
	_hide_ui()
	close()

func _hide_ui() -> void:
	if _ui_panel:
		_ui_panel.queue_free()
		_ui_panel = null
	_item_slots.clear()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _input(event: InputEvent) -> void:
	if _ui_panel and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_hide_ui()
			_update_prompt()
			get_viewport().set_input_as_handled()

func _start_floating_animation() -> void:
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(mesh_root, "position:y", 0.15, 1.8).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mesh_root, "position:y", -0.15, 1.8).as_relative().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
