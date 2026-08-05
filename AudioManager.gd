extends Node
# Autoload: gestiona música de fondo y efectos de sonido con canales independientes.

@onready var music_player : AudioStreamPlayer = AudioStreamPlayer.new()
@onready var sfx_players : Array = []

const SFX_CHANNELS = 8

var music_volume : float = 0.8  # 0.0 - 1.0
var sfx_volume : float = 1.0    # 0.0 - 1.0

func _ready() -> void:
	add_child(music_player)
	music_player.volume_db = linear_to_db(music_volume)
	for i in range(SFX_CHANNELS):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)

func play_music(stream: AudioStream, fade_in: bool = true) -> void:
	if music_player.stream == stream:
		return
	music_player.stream = stream
	music_player.play()
	if fade_in:
		music_player.volume_db = -80.0
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), 1.5)

func stop_music() -> void:
	music_player.stop()

func play_sfx(stream: AudioStream, volume_scale: float = 1.0) -> void:
	for player in sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * volume_scale)
			player.play()
			return
	# Si todos están ocupados, reutilizamos el primero
	sfx_players[0].stream = stream
	sfx_players[0].play()

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)
