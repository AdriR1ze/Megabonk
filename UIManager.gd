extends Node
# Autoload: gestiona la visibilidad y transiciones de las pantallas del juego.
# Conecta señales de EventBus con la UI correspondiente.

enum Screen { NONE, HUD, UPGRADE_SELECT, WEAPON_SELECT, GAME_OVER, PAUSE }

var active_screen : Screen = Screen.NONE
var hud_node : Control = null
var upgrade_screen_node : Control = null
var weapon_select_node : Control = null
var game_over_node : Control = null

func _ready() -> void:
	EventBus.upgrade_offered.connect(_show_upgrade_screen)
	EventBus.player_died.connect(_show_game_over)
	EventBus.damage_dealt.connect(_spawn_damage_number)

func _spawn_damage_number(target: Node3D, amount: float, is_critical: bool) -> void:
	if not is_instance_valid(target) or not target.is_inside_tree():
		return

	var label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.render_priority = 10
	label.pixel_size = 0.015
	label.font_size = 48 if is_critical else 36
	label.text = str(int(round(amount))) + ("!" if is_critical else "")

	if is_critical:
		label.modulate = Color(1.0, 0.2, 0.1, 1.0)
		label.outline_render_priority = 9
		label.outline_size = 8
		label.outline_modulate = Color(0, 0, 0, 1)
	else:
		label.modulate = Color(1.0, 0.95, 0.3, 1.0)
		label.outline_render_priority = 9
		label.outline_size = 6
		label.outline_modulate = Color(0, 0, 0, 1)

	get_tree().current_scene.add_child(label)

	var random_offset = Vector3(randf_range(-0.4, 0.4), randf_range(1.2, 1.6), randf_range(-0.4, 0.4))
	label.global_position = target.global_position + random_offset

	var tween = label.create_tween().set_parallel(true)
	var target_pos = label.global_position + Vector3(randf_range(-0.3, 0.3), 1.4, randf_range(-0.3, 0.3))

	tween.tween_property(label, "global_position", target_pos, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.65).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(label.queue_free)

# Registrar los nodos de pantalla desde las propias escenas (self-register)
func register_hud(node: Control) -> void:
	hud_node = node

func register_upgrade_screen(node: Control) -> void:
	upgrade_screen_node = node

func register_game_over_screen(node: Control) -> void:
	game_over_node = node

func _show_upgrade_screen(upgrades: Array) -> void:
	if upgrade_screen_node:
		upgrade_screen_node.show_upgrades(upgrades)
		upgrade_screen_node.visible = true
		active_screen = Screen.UPGRADE_SELECT

func _show_game_over() -> void:
	if game_over_node:
		game_over_node.visible = true
		active_screen = Screen.GAME_OVER

func show_hud() -> void:
	if hud_node:
		hud_node.visible = true
	active_screen = Screen.HUD

func hide_all() -> void:
	if hud_node: hud_node.visible = false
	if upgrade_screen_node: upgrade_screen_node.visible = false
	if weapon_select_node: weapon_select_node.visible = false
	if game_over_node: game_over_node.visible = false
	active_screen = Screen.NONE
