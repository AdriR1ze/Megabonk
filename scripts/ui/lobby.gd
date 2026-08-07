extends Control

@onready var player_list: VBoxContainer = $Panel/VBoxContainer/PlayerList
@onready var start_btn: Button = $Panel/VBoxContainer/StartBtn
@onready var back_btn: Button = $Panel/VBoxContainer/BackBtn
@onready var status_label: Label = $Panel/VBoxContainer/StatusLabel
@onready var ip_label: Label = $Panel/VBoxContainer/IPLabel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	NetworkManager.server_started.connect(_on_server_started)
	NetworkManager.connection_succeeded.connect(_on_connected)
	NetworkManager.connection_failed.connect(_on_connection_failed)
	NetworkManager.lobby_player_list_changed.connect(_on_player_list_changed)
	NetworkManager.game_started.connect(_on_game_started)
	NetworkManager.player_disconnected.connect(_on_player_list_changed.bind())

	if start_btn:
		start_btn.pressed.connect(_on_start_pressed)
		start_btn.visible = false
	if back_btn:
		back_btn.pressed.connect(_on_back_pressed)

	if NetworkManager.is_server():
		show_as_host()
	elif multiplayer.has_multiplayer_peer():
		show_as_client()

func show_as_host() -> void:
	visible = true
	status_label.text = "Esperando jugadores..."
	start_btn.visible = true
	if ip_label:
		ip_label.text = "Tu IP: " + _get_local_ip()
	_refresh_player_list()

func show_as_client() -> void:
	visible = true
	status_label.text = "Conectado al servidor. Esperando inicio..."
	start_btn.visible = false
	if ip_label:
		ip_label.visible = false
	_refresh_player_list()

func _on_server_started() -> void:
	show_as_host()

func _on_connected() -> void:
	show_as_client()

func _on_connection_failed(reason: String) -> void:
	status_label.text = "Error: " + reason
	visible = true

func _on_player_list_changed(_id = null) -> void:
	_refresh_player_list()

func _refresh_player_list() -> void:
	for child in player_list.get_children():
		child.queue_free()

	var players = NetworkManager.get_lobby_players()
	for peer_id in players:
		var info = players[peer_id]
		var label = Label.new()
		var ready_text = " [LISTO]" if info.get("ready", false) else " [ESPERANDO]"
		label.text = str(info.get("name", "Jugador")) + ready_text
		player_list.add_child(label)

	status_label.text = "Jugadores: " + str(players.size()) + "/" + str(NetworkManager.MAX_PLAYERS)

func _on_start_pressed() -> void:
	if not NetworkManager.is_server():
		return
	NetworkManager.request_start_game()

func _on_game_started() -> void:
	get_tree().change_scene_to_file("res://scenes/mundo.tscn")

func _on_back_pressed() -> void:
	NetworkManager.disconnect_network()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _get_local_ip() -> String:
	var ip_list = IP.get_local_addresses()
	for ip in ip_list:
		if ip.begins_with("192.168.") or ip.begins_with("10.") or ip.begins_with("172."):
			return ip
	return ip_list[0] if not ip_list.is_empty() else "Desconocida"
