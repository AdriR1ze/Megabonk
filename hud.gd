extends Control

@onready var health_bar: ProgressBar = $TopLeft/VBoxContainer/HealthContainer/HealthBar
@onready var health_label: Label = $TopLeft/VBoxContainer/HealthContainer/HealthBar/HealthLabel
@onready var level_label: Label = $TopLeft/VBoxContainer/LevelContainer/LevelLabel
@onready var xp_bar: ProgressBar = $TopLeft/VBoxContainer/XPContainer/XPBar
@onready var xp_label: Label = $TopLeft/VBoxContainer/XPContainer/XPBar/XPLabel
@onready var coins_label: Label = $TopLeft/VBoxContainer/CoinsContainer/CoinsLabel
@onready var timer_label: Label = $TimerPanel/TimerLabel
@onready var weapons_container: VBoxContainer = $TopRight/VBoxContainer/WeaponsList

var elapsed_seconds: float = 0.0

func _ready() -> void:
	PlayerStats.xp_changed.connect(_update_player_stats)
	PlayerStats.level_up.connect(_update_player_stats)
	WeaponManager.weapons_changed.connect(_update_weapons)
	GameManager.coins_changed.connect(_on_coins_changed)
	
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

func _setup_player_health() -> void:
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var health_comp = player.get_node_or_null("HealthComponent")
		if health_comp:
			health_comp.health_changed.connect(_on_health_changed)
			_on_health_changed(health_comp.health, health_comp.max_health)

func _update_player_stats() -> void:
	level_label.text = "Nivel " + str(PlayerStats.level)
	xp_bar.max_value = PlayerStats.xp_needed
	xp_bar.value = PlayerStats.xp
	xp_label.text = "XP: " + str(PlayerStats.xp) + " / " + str(PlayerStats.xp_needed)

func _on_health_changed(current: float, max_hp: float) -> void:
	health_bar.max_value = max_hp
	health_bar.value = current
	health_label.text = "Vida: " + str(int(current)) + " / " + str(int(max_hp))

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
