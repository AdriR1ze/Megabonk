extends Node

signal player_connected(peer_id: int, player_name: String)
signal player_disconnected(peer_id: int)
signal connection_succeeded
signal connection_failed(reason: String)
signal server_started
signal game_started
signal lobby_player_list_changed

const DEFAULT_PORT := 7777
const MAX_PLAYERS := 4

var _is_server: bool = false
var _lobby_players: Dictionary = {}

func is_server() -> bool:
	return _is_server

func is_multiplayer_active() -> bool:
	return multiplayer.has_multiplayer_peer() and multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_DISCONNECTED

func get_player_count() -> int:
	return _lobby_players.size()

func get_lobby_players() -> Dictionary:
	return _lobby_players

func host_game(port: int = DEFAULT_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port, MAX_PLAYERS)
	if err != OK:
		connection_failed.emit("No se pudo crear el servidor en el puerto " + str(port))
		return

	multiplayer.multiplayer_peer = peer
	_is_server = true

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	_lobby_players.clear()
	_lobby_players[multiplayer.get_unique_id()] = {"name": "Host", "ready": true}
	lobby_player_list_changed.emit()
	server_started.emit()

func join_game(address: String, port: int = DEFAULT_PORT) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(address, port)
	if err != OK:
		connection_failed.emit("No se pudo conectar a " + address + ":" + str(port))
		return

	multiplayer.multiplayer_peer = peer
	_is_server = false

	multiplayer.connected_to_server.connect(_on_connection_succeeded)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func disconnect_network() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
	_is_server = false
	_lobby_players.clear()

func _on_peer_connected(peer_id: int) -> void:
	if _is_server:
		_lobby_players[peer_id] = {"name": "Jugador " + str(peer_id), "ready": false}
		lobby_player_list_changed.emit()
		rpc_id(peer_id, "_receive_lobby_state", _lobby_players)

func _on_peer_disconnected(peer_id: int) -> void:
	if _lobby_players.has(peer_id):
		_lobby_players.erase(peer_id)
		lobby_player_list_changed.emit()
	player_disconnected.emit(peer_id)

func _on_connection_succeeded() -> void:
	connection_succeeded.emit()

func _on_connection_failed() -> void:
	connection_failed.emit("Conexion fallida al servidor.")

@rpc("any_peer")
func _receive_lobby_state(state: Dictionary) -> void:
	_lobby_players = state
	lobby_player_list_changed.emit()

@rpc("any_peer")
func player_set_ready(peer_id: int, ready_state: bool) -> void:
	if _is_server:
		if _lobby_players.has(peer_id):
			_lobby_players[peer_id]["ready"] = ready_state
		lobby_player_list_changed.emit()

@rpc("authority")
func request_start_game() -> void:
	if _is_server:
		start_game.rpc()

@rpc("authority", "call_local", "reliable")
func start_game() -> void:
	game_started.emit()
