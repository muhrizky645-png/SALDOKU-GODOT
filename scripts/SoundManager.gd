extends Node
# Autoload "Sound" - port dari SoundManager.cs.
# Musik + SFX di-GENERATE lewat kode (tanpa file audio), pakai AudioStreamWAV 16-bit.

# --- SAKELAR ---
# Musik: loop TIDAK pakai LOOP_FORWARD bawaan (bikin native crash di device Mali),
# tapi di-putar-ulang manual lewat sinyal `finished`.
const MUSIK_AKTIF := true
const EFEK_AKTIF := true

const SR := 22050
const BASE_MUSIK := 0.5
const _PATH := "user://saldoku.cfg"

var vol_musik := 0.8
var vol_efek := 0.9
var mute_musik := false
var mute_efek := false

var _musik: AudioStreamPlayer = null
var _pool: Array = []
var _pool_idx := 0

var _c_tembak: AudioStreamWAV = null
var _c_musuh_kena: AudioStreamWAV = null
var _c_musuh_mati: AudioStreamWAV = null
var _c_ambil_xp: AudioStreamWAV = null
var _c_level_up: AudioStreamWAV = null
var _c_kena: AudioStreamWAV = null
var _c_game_over: AudioStreamWAV = null
var _c_klik: AudioStreamWAV = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_muat()
	if EFEK_AKTIF:
		_buat_semua_suara()
		for i in 8:
			var p := AudioStreamPlayer.new()
			add_child(p)
			_pool.append(p)
	if MUSIK_AKTIF:
		_musik = AudioStreamPlayer.new()
		_musik.stream = _buat_musik()
		add_child(_musik)
		_musik.finished.connect(_ulang_musik)
		_terapkan_musik()
		_musik.play()

func _ulang_musik() -> void:
	if MUSIK_AKTIF and _musik != null:
		_musik.play()

func _muat() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) == OK:
		vol_musik = float(cfg.get_value("suara", "vol_musik", 0.8))
		vol_efek = float(cfg.get_value("suara", "vol_efek", 0.9))
		mute_musik = bool(cfg.get_value("suara", "mute_musik", false))
		mute_efek = bool(cfg.get_value("suara", "mute_efek", false))

func _simpan() -> void:
	var cfg := ConfigFile.new()
	cfg.load(_PATH)
	cfg.set_value("suara", "vol_musik", vol_musik)
	cfg.set_value("suara", "vol_efek", vol_efek)
	cfg.set_value("suara", "mute_musik", mute_musik)
	cfg.set_value("suara", "mute_efek", mute_efek)
	cfg.save(_PATH)

func _terapkan_musik() -> void:
	if _musik != null:
		if mute_musik:
			_musik.volume_db = -80.0
		else:
			_musik.volume_db = linear_to_db(maxf(0.0001, vol_musik * BASE_MUSIK))

# ---- API pengaturan (dipanggil menu) ----
func set_vol_musik(v: float) -> void:
	vol_musik = clampf(v, 0.0, 1.0)
	_simpan()
	_terapkan_musik()

func set_vol_efek(v: float) -> void:
	vol_efek = clampf(v, 0.0, 1.0)
	_simpan()

func toggle_mute_musik() -> void:
	mute_musik = not mute_musik
	_simpan()
	_terapkan_musik()

func toggle_mute_efek() -> void:
	mute_efek = not mute_efek
	_simpan()

# ---- API SFX (statis dipanggil script lain) ----
func tembak() -> void:
	_play(_c_tembak)

func musuh_kena() -> void:
	_play(_c_musuh_kena)

func musuh_mati() -> void:
	_play(_c_musuh_mati)

func ambil_xp() -> void:
	_play(_c_ambil_xp)

func level_up() -> void:
	_play(_c_level_up)

func player_kena() -> void:
	_play(_c_kena)

func game_over() -> void:
	_play(_c_game_over)

func klik() -> void:
	_play(_c_klik)

func _play(c: AudioStreamWAV) -> void:
	if c == null or mute_efek or _pool.is_empty():
		return
	var p: AudioStreamPlayer = _pool[_pool_idx]
	_pool_idx = (_pool_idx + 1) % _pool.size()
	p.stream = c
	p.volume_db = linear_to_db(maxf(0.0001, vol_efek))
	p.play()

# ---------------- generator suara ----------------
func _buat_semua_suara() -> void:
	_c_tembak = _sweep(900.0, 1500.0, 0.07, 0, 0.30)
	_c_musuh_kena = _sweep(260.0, 150.0, 0.06, 0, 0.28)
	_c_musuh_mati = _derau(0.20, 0.40)
	_c_ambil_xp = _sweep(700.0, 1300.0, 0.09, 1, 0.30)
	_c_kena = _sweep(220.0, 80.0, 0.18, 0, 0.40)
	_c_game_over = _sweep(420.0, 110.0, 0.60, 2, 0.40)
	_c_klik = _sweep(680.0, 680.0, 0.035, 0, 0.22)
	# level up = arpeggio naik (C5 E5 G5 C6)
	var n := int(0.40 * SR)
	var b := PackedFloat32Array()
	b.resize(n)
	var fs := [523.25, 659.25, 783.99, 1046.5]
	for i in fs.size():
		_tulis_nada(b, int(i * 0.09 * SR), float(fs[i]), 0.12, 0.30, 0)
	_c_level_up = _wav(b, false)

func _tulis_nada(buf: PackedFloat32Array, mulai: int, freq: float, dur: float, vol: float, tipe: int) -> void:
	var n := int(dur * SR)
	for i in n:
		var idx := mulai + i
		if idx < 0 or idx >= buf.size():
			continue
		var t := float(i) / float(SR)
		var env := minf(1.0, float(i) / (0.004 * SR)) * minf(1.0, float(n - i) / (0.03 * SR))
		buf[idx] += _gelombang(tipe, freq, t) * vol * env

func _gelombang(tipe: int, freq: float, t: float) -> float:
	if tipe == 1:
		return sin(TAU * freq * t)
	if tipe == 2:
		var p := fmod(freq * t, 1.0)
		return 4.0 * absf(p - 0.5) - 1.0
	return signf(sin(TAU * freq * t))

func _sweep(f0: float, f1: float, dur: float, tipe: int, vol: float) -> AudioStreamWAV:
	var n := int(dur * SR)
	var b := PackedFloat32Array()
	b.resize(n)
	var fase := 0.0
	for i in n:
		var f := lerpf(f0, f1, float(i) / float(n))
		fase += TAU * f / float(SR)
		var w := 0.0
		if tipe == 1:
			w = sin(fase)
		elif tipe == 2:
			var p := fmod(fase / TAU, 1.0)
			w = 4.0 * absf(p - 0.5) - 1.0
		else:
			w = signf(sin(fase))
		var env := minf(1.0, float(i) / (0.003 * SR)) * minf(1.0, float(n - i) / (0.02 * SR))
		b[i] = w * vol * env
	return _wav(b, false)

func _derau(dur: float, vol: float) -> AudioStreamWAV:
	var n := int(dur * SR)
	var b := PackedFloat32Array()
	b.resize(n)
	for i in n:
		var env := 1.0 - float(i) / float(n)
		b[i] = (randf() * 2.0 - 1.0) * vol * env * env
	return _wav(b, false)

func _buat_musik() -> AudioStreamWAV:
	var buf := PackedFloat32Array()
	buf.resize(int(8.0 * SR))
	var mel := [0,3,7,12, 7,3,7,3, -4,0,5,8, 5,0,-4,0, 3,7,10,15, 10,7,3,7, -2,2,5,10, 5,2,-2,2]
	for i in mel.size():
		var f := 440.0 * pow(2.0, float(mel[i]) / 12.0)
		_tulis_nada(buf, int(i * 0.25 * SR), f, 0.24, 0.14, 0)
	var bass_root := [-24, -28, -21, -26]
	for bar in 4:
		for k in 4:
			var f := 440.0 * pow(2.0, float(bass_root[bar]) / 12.0)
			_tulis_nada(buf, int((float(bar) * 2.0 + float(k) * 0.5) * SR), f, 0.45, 0.16, 2)
	# non-loop; pengulangan lewat sinyal finished (_ulang_musik) biar aman di Android
	return _wav(buf, false)

func _wav(buf: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		var v := clampf(buf[i], -1.0, 1.0)
		bytes.encode_s16(i * 2, int(v * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SR
	wav.stereo = false
	wav.data = bytes
	if loop:
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = buf.size()
	return wav
