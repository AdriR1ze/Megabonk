extends Node
# Autoload: música ambiental y efectos de sonido generados proceduralmente (sin assets).

const SFX_CHANNELS := 8
const MIX_RATE := 22050

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var _sfx_index := 0

var music_volume : float = 0.5
var sfx_volume : float = 0.9

var _sounds := {}

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	for i in range(SFX_CHANNELS):
		var p := AudioStreamPlayer.new()
		add_child(p)
		sfx_players.append(p)

	_build_sounds()

	# Esperar un frame para que todos los autoloads estén disponibles.
	await get_tree().process_frame
	_connect_events()
	play_music("ambient")

func _connect_events() -> void:
	if is_instance_valid(EventBus):
		EventBus.weapon_fired.connect(func(): play_sfx("shoot"))
		EventBus.damage_dealt.connect(func(_t, _a, _c): play_sfx("hit"))
		EventBus.enemy_died.connect(func(_e, _x, _c): play_sfx("enemy_die"))
		EventBus.shield_blocked.connect(func(): play_sfx("shield"))
		EventBus.player_took_damage.connect(func(): play_sfx("player_damage"))
		EventBus.player_died.connect(_on_player_died)
		EventBus.item_picked.connect(func(): play_sfx("item"))
		EventBus.run_started.connect(func(): play_music("ambient"))
	if is_instance_valid(GameManager):
		GameManager.coins_changed.connect(func(_c): play_sfx("coin"))
	if is_instance_valid(PlayerStats):
		PlayerStats.level_up.connect(func(): play_sfx("level_up"))

func _on_player_died() -> void:
	play_sfx("player_die")
	stop_music()

# --- API pública ---

func play_sfx(sfx_name: String) -> void:
	if not _sounds.has(sfx_name):
		return
	_play_stream(_sounds[sfx_name])

func play_music(music_name: String) -> void:
	if not _sounds.has(music_name):
		return
	var stream: AudioStream = _sounds[music_name]
	if music_player.stream == stream and music_player.playing:
		return
	music_player.stream = stream
	music_player.volume_db = linear_to_db(music_volume)
	music_player.play()

func stop_music() -> void:
	music_player.stop()

func set_music_volume(vol: float) -> void:
	music_volume = clamp(vol, 0.0, 1.0)
	music_player.volume_db = linear_to_db(music_volume)

func set_sfx_volume(vol: float) -> void:
	sfx_volume = clamp(vol, 0.0, 1.0)

func _play_stream(stream: AudioStream) -> void:
	var p := sfx_players[_sfx_index]
	_sfx_index = (_sfx_index + 1) % SFX_CHANNELS
	p.stream = stream
	p.volume_db = linear_to_db(sfx_volume)
	p.play()

# --- Síntesis ---

func _build_sounds() -> void:
	_sounds["shoot"] = _to_stream(_mix([
		_noise(0.12, 0.30, 14.0),
		_tone(180.0, 0.08, 0.25),
	]))
	_sounds["hit"] = _to_stream(_mix([
		_noise(0.06, 0.18, 22.0),
		_tone(90.0, 0.05, 0.20, "square"),
	]))
	_sounds["enemy_die"] = _to_stream(_sweep(500.0, 120.0, 0.28, 0.35))
	_sounds["coin"] = _to_stream(_concat([
		_tone(1046.5, 0.07, 0.30),
		_tone(1568.0, 0.16, 0.30),
	]))
	_sounds["item"] = _to_stream(_concat([
		_tone(523.25, 0.09, 0.30),
		_tone(659.25, 0.09, 0.30),
		_tone(783.99, 0.18, 0.30),
	]))
	_sounds["level_up"] = _to_stream(_concat([
		_tone(392.0, 0.10, 0.30),
		_tone(523.25, 0.10, 0.30),
		_tone(659.25, 0.10, 0.30),
		_tone(783.99, 0.30, 0.30),
	]))
	_sounds["player_damage"] = _to_stream(_mix([
		_tone(130.0, 0.18, 0.40, "square"),
		_noise(0.12, 0.12, 10.0),
	]))
	_sounds["player_die"] = _to_stream(_sweep(440.0, 60.0, 1.2, 0.45))
	_sounds["shield"] = _to_stream(_mix([
		_tone(880.0, 0.10, 0.25, "square"),
		_tone(1760.0, 0.12, 0.15),
	]))
	_sounds["ambient"] = _generate_music()

func _generate_music() -> AudioStreamWAV:
	# Progresión ambiental: Am - F - C - G
	var chord_len := 4.0
	var chords := [
		[220.0, 261.63, 329.63],
		[174.61, 220.0, 261.63],
		[261.63, 329.63, 392.0],
		[196.0, 246.94, 293.66],
	]
	var bass := [110.0, 87.31, 130.81, 98.0]
	var parts: Array[PackedFloat32Array] = []
	for c in range(chords.size()):
		var seg: Array[PackedFloat32Array] = []
		for f in chords[c]:
			seg.append(_pad(f, chord_len, 0.10))
		seg.append(_pad(bass[c], chord_len, 0.14))
		parts.append(_mix(seg))
	var loop := _concat(parts)
	var stream := _to_stream(loop)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = loop.size()
	return stream

func _tone(freq: float, dur: float, amp: float = 0.5, wave := "sine") -> PackedFloat32Array:
	var n := int(dur * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var attack := int(MIX_RATE * 0.01)
	for i in n:
		var t := float(i) / MIX_RATE
		var env: float = clamp(float(i) / float(max(attack, 1)), 0.0, 1.0) * exp(-4.0 * t)
		var v := 0.0
		match wave:
			"sine":
				v = sin(TAU * freq * t)
			"square":
				v = 1.0 if fmod(freq * t, 1.0) < 0.5 else -1.0
		out[i] = v * amp * env
	return out

func _noise(dur: float, amp: float = 0.4, decay: float = 6.0) -> PackedFloat32Array:
	var n := int(dur * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	for i in n:
		var t := float(i) / MIX_RATE
		out[i] = randf_range(-1.0, 1.0) * amp * exp(-decay * t)
	return out

func _sweep(f_start: float, f_end: float, dur: float, amp: float = 0.4) -> PackedFloat32Array:
	var n := int(dur * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var phase := 0.0
	for i in n:
		var t := float(i) / MIX_RATE
		var f: float = lerpf(f_start, f_end, clamp(t / dur, 0.0, 1.0))
		phase += TAU * f / MIX_RATE
		out[i] = sin(phase) * amp * exp(-3.0 * t)
	return out

func _pad(freq: float, dur: float, amp: float = 0.12) -> PackedFloat32Array:
	var n := int(dur * MIX_RATE)
	var out := PackedFloat32Array()
	out.resize(n)
	var attack := int(MIX_RATE * 0.6)
	var release := int(MIX_RATE * 1.2)
	var phase := 0.0
	for i in n:
		phase += TAU * freq / MIX_RATE
		var env: float = clamp(float(i) / float(attack), 0.0, 1.0)
		env *= clamp(float(n - 1 - i) / float(release), 0.0, 1.0)
		out[i] = sin(phase) * amp * env
	return out

func _concat(parts: Array[PackedFloat32Array]) -> PackedFloat32Array:
	var total := 0
	for p in parts:
		total += p.size()
	var out := PackedFloat32Array()
	out.resize(total)
	var pos := 0
	for p in parts:
		for i in p.size():
			out[pos] = p[i]
			pos += 1
	return out

func _mix(parts: Array[PackedFloat32Array]) -> PackedFloat32Array:
	var max_len := 0
	for p in parts:
		max_len = max(max_len, p.size())
	var out := PackedFloat32Array()
	out.resize(max_len)
	for i in max_len:
		var s := 0.0
		for p in parts:
			if i < p.size():
				s += p[i]
		out[i] = clamp(s, -1.0, 1.0)
	return out

func _to_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clamp(samples[i], -1.0, 1.0) * 32000.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
