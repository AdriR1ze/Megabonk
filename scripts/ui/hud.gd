extends Control

@onready var health_bar: ProgressBar = $TopLeft/VBoxContainer/HealthContainer/HealthBar
@onready var health_label: Label = $TopLeft/VBoxContainer/HealthContainer/HealthBar/HealthLabel
@onready var overhealth_container: MarginContainer = $TopLeft/VBoxContainer/OverhealthContainer
@onready var overhealth_bar: ProgressBar = $TopLeft/VBoxContainer/OverhealthContainer/OverhealthBar
@onready var overhealth_label: Label = $TopLeft/VBoxContainer/OverhealthContainer/OverhealthBar/OverhealthLabel
@onready var level_label: Label = $TopLeft/VBoxContainer/LevelContainer/LevelLabel
@onready var xp_bar: ProgressBar = $TopLeft/VBoxContainer/XPContainer/XPBar
@onready var xp_label: Label = $TopLeft/VBoxContainer/XPContainer/XPBar/XPLabel
@onready var coins_label: Label = $TopLeft/VBoxContainer/CoinsContainer/CoinsLabel
@onready var timer_label: Label = $TimerPanel/TimerLabel
@onready var credits_label: Label = $TimerPanel.get_node_or_null("CreditsLabel")
@onready var weapons_container: VBoxContainer = $TopRight/VBoxContainer/WeaponsList

@onready var boss_panel: PanelContainer = $BossPanel
@onready var boss_name_label: Label = $BossPanel/VBoxContainer/BossNameLabel
@onready var boss_health_bar: ProgressBar = $BossPanel/VBoxContainer/BossHealthBar
@onready var boss_health_label: Label = $BossPanel/VBoxContainer/BossHealthBar/BossHealthLabel

var _current_boss: Node3D = null
var _boss_queue: Array = []


@onready var item_popup: Control = $ItemPopup
@onready var item_popup_panel: PanelContainer = $ItemPopup/PanelContainer
@onready var item_popup_icon: TextureRect = $ItemPopup/PanelContainer/HBoxContainer/ItemIcon
@onready var item_popup_name: Label = $ItemPopup/PanelContainer/HBoxContainer/VBoxContainer/ItemName
@onready var item_popup_desc: Label = $ItemPopup/PanelContainer/HBoxContainer/VBoxContainer/ItemDesc

const RARITY_COLORS_ITEM: Dictionary = {
	0: Color(0.55, 0.55, 0.55),
	1: Color(0.25, 0.6, 1.0),
	2: Color(0.75, 0.35, 1.0),
	3: Color(1.0, 0.78, 0.2),
}

const RARITY_BG_ITEM: Dictionary = {
	0: Color(0.08, 0.09, 0.11, 0.92),
	1: Color(0.07, 0.11, 0.16, 0.92),
	2: Color(0.11, 0.08, 0.16, 0.92),
	3: Color(0.14, 0.11, 0.05, 0.92),
}

var elapsed_seconds: float = 0.0
var _popup_timer: Timer = null

func _ready() -> void:
	PlayerStats.xp_changed.connect(_update_player_stats)
	PlayerStats.level_up.connect(_update_player_stats)
	WeaponManager.weapons_changed.connect(_update_weapons)
	GameManager.coins_changed.connect(_on_coins_changed)

	EventBus.player_overhealth_changed.connect(_on_overhealth_changed)

	EventBus.boss_spawned.connect(_on_boss_spawned)
	EventBus.item_picked.connect(_show_item_popup)
	EventBus.credits_changed.connect(_on_credits_changed)

	_update_player_stats()
	_update_weapons()
	_on_coins_changed(GameManager.coins)

	_setup_player_health()

func _process(delta: float) -> void:
	if not get_tree().paused:
		elapsed_seconds += delta
		_update_timer()

func _update_timer() -> void:
	if not timer_label:
		return
	var mins = int(elapsed_seconds) / 60
	var secs = int(elapsed_seconds) % 60
	timer_label.text = "%02d:%02d" % [mins, secs]

func _on_coins_changed(new_coins: int) -> void:
	if coins_label:
		coins_label.text = "Plata: $" + str(new_coins)

func _on_credits_changed(current: float, _max_credits: int) -> void:
	if credits_label:
		credits_label.text = "Creditos: " + str(int(max(0, current)))

func _setup_player_health() -> void:
	await get_tree().process_frame
	var player = _find_local_player()
	if player:
		var health_comp = player.get_node_or_null("HealthComponent")
		if health_comp:
			health_comp.health_changed.connect(_on_health_changed)
			_on_health_changed(health_comp.health, health_comp.max_health)

func _find_local_player() -> Node3D:
	if not multiplayer.has_multiplayer_peer():
		return get_tree().get_first_node_in_group("player")
	for p in get_tree().get_nodes_in_group("player"):
		if p.is_multiplayer_authority():
			return p
	return get_tree().get_first_node_in_group("player")

func _update_player_stats() -> void:
	level_label.text = "Nivel " + str(PlayerStats.level)
	xp_bar.max_value = PlayerStats.xp_needed
	xp_bar.value = PlayerStats.xp
	xp_label.text = "XP: " + str(PlayerStats.xp) + " / " + str(PlayerStats.xp_needed)

func _on_overhealth_changed(current: float, max_hp: float) -> void:
	if max_hp <= 0.0:
		overhealth_container.visible = false
		return
	overhealth_container.visible = true
	overhealth_bar.max_value = max_hp
	overhealth_bar.value = current
	overhealth_label.text = "Sobrevida: " + str(int(current)) + " / " + str(int(max_hp))

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "Vida: " + str(int(current)) + " / " + str(int(max_hp))

func _on_boss_spawned(boss_node: Node3D, boss_name: String) -> void:
	if not boss_panel:
		return

	var hc = boss_node.get_node_or_null("HealthComponent")
	if hc:
		hc.health_changed.connect(_on_boss_health.bind(boss_node))
		hc.died.connect(_on_boss_died.bind(boss_node))

	if _current_boss == null or not is_instance_valid(_current_boss):
		_show_boss(boss_node, boss_name)
	else:
		_boss_queue.append({"node": boss_node, "name": boss_name})

func _show_boss(boss_node: Node3D, boss_name: String) -> void:
	_current_boss = boss_node
	boss_panel.visible = true
	if boss_name_label:
		boss_name_label.text = boss_name
	var hc = boss_node.get_node_or_null("HealthComponent")
	if hc:
		boss_health_bar.max_value = hc.max_health
		boss_health_bar.value = hc.health
		boss_health_label.text = str(int(max(0, hc.health))) + " / " + str(int(hc.max_health))

func _on_boss_health(current_hp: float, max_hp: float, boss_node: Node3D) -> void:
	if boss_node != _current_boss:
		return
	boss_health_bar.max_value = max_hp
	boss_health_bar.value = current_hp
	boss_health_label.text = str(int(max(0, current_hp))) + " / " + str(int(max_hp))

func _on_boss_died(boss_node: Node3D) -> void:
	if boss_node == _current_boss:
		_current_boss = null
		_promote_next_boss()

func _promote_next_boss() -> void:
	while not _boss_queue.is_empty():
		var entry = _boss_queue.pop_front()
		if is_instance_valid(entry["node"]):
			_show_boss(entry["node"], entry["name"])
			return
	boss_panel.visible = false

func _update_weapons() -> void:
	for child in weapons_container.get_children():
		child.queue_free()

	for w in WeaponManager.weapons:
		if not is_instance_valid(w) or not "data" in w or w.data == null:
			continue

		var data: WeaponData = w.data
		var item_hbox = HBoxContainer.new()
		item_hbox.custom_minimum_size = Vector2(0, 24)

		if data.texture_sprite:
			var tex = TextureRect.new()
			tex.texture = data.texture_sprite
			tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			tex.custom_minimum_size = Vector2(24, 24)
			tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_hbox.add_child(tex)

		var label = Label.new()
		label.text = data.weapon_name + " (Nvl. " + str(data.level) + ")"
		label.add_theme_font_size_override("font_size", 14)
		item_hbox.add_child(label)

		weapons_container.add_child(item_hbox)

func _show_item_popup(item_id: int) -> void:
	var item: Item = ItemDB.get_item(item_id)
	if item == null:
		return

	var rarity_color: Color = RARITY_COLORS_ITEM.get(item.rarity, RARITY_COLORS_ITEM[0])
	var rarity_bg: Color = RARITY_BG_ITEM.get(item.rarity, RARITY_BG_ITEM[0])

	item_popup_icon.texture = item.texture_sprite
	item_popup_name.text = item.display_name
	item_popup_name.add_theme_color_override("font_color", rarity_color.lightened(0.2))
	item_popup_desc.text = item.description

	var style := StyleBoxFlat.new()
	style.bg_color = rarity_bg
	style.set_border_width_all(2)
	style.border_color = rarity_color
	style.set_corner_radius_all(10)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	item_popup_panel.add_theme_stylebox_override("panel", style)

	item_popup.visible = true
	item_popup.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(item_popup, "modulate:a", 1.0, 0.2)

	if _popup_timer:
		_popup_timer.queue_free()
	_popup_timer = Timer.new()
	_popup_timer.one_shot = true
	_popup_timer.wait_time = 3.0
	_popup_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_popup_timer.timeout.connect(_hide_item_popup)
	add_child(_popup_timer)
	_popup_timer.start()

func _hide_item_popup() -> void:
	var fade_out := create_tween()
	fade_out.tween_property(item_popup, "modulate:a", 0.0, 0.3)
	fade_out.tween_callback(func(): item_popup.visible = false)
