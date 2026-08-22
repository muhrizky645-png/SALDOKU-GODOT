extends Node
# Autoload "Dewa" - port dari ModeDewa.cs (logika inti + UI sederhana).
# Peti muncul tiap 90 detik main, tampil 10 detik. Dibuka -> 30 detik mode dewa:
# KEBAL + BADAI PELURU + MAGNET SEMESTA + AURA MAUT.
# Tampilan mewah (Tema/Ikon + gambar peti) menyusul di Fase D.

var aktif := false
var sisa_detik := 0.0

const DURASI := 30.0
const JEDA_ISI_ULANG := 90.0
const DURASI_TAMPIL := 10.0

var _tersedia := false
var _isi_ulang := 0.0
var _tampil_sisa := 0.0
var _pulse := 0.0

var _layer: CanvasLayer = null
var _btn: Button = null
var _lbl: Label = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_buat_ui()

func reset() -> void:
	aktif = false
	sisa_detik = 0.0
	_tersedia = false
	_isi_ulang = 0.0
	_tampil_sisa = 0.0
	_pulse = 0.0
	if _btn != null:
		_btn.visible = false
	if _lbl != null:
		_lbl.visible = false

func _buat_ui() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 90
	add_child(_layer)
	_btn = Button.new()
	_btn.text = "PETI DEWA"
	_btn.add_theme_font_size_override("font_size", 28)
	_btn.anchor_left = 1.0
	_btn.anchor_right = 1.0
	_btn.offset_left = -300.0
	_btn.offset_right = -40.0
	_btn.offset_top = 300.0
	_btn.offset_bottom = 380.0
	_btn.visible = false
	_btn.pressed.connect(_buka)
	_layer.add_child(_btn)
	_lbl = Label.new()
	_lbl.add_theme_font_size_override("font_size", 44)
	_lbl.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl.anchor_left = 0.0
	_lbl.anchor_right = 1.0
	_lbl.offset_top = 1720.0
	_lbl.offset_bottom = 1800.0
	_lbl.visible = false
	_layer.add_child(_lbl)

func _boleh_main() -> bool:
	var Sk = get_node_or_null("/root/Skill")
	if Sk != null and Sk.aktif_memilih:
		return false
	if get_tree().paused:
		return false
	return get_tree().get_first_node_in_group("player") != null

func _process(delta: float) -> void:
	var main_ada := _boleh_main()
	if aktif:
		if main_ada:
			sisa_detik -= delta
			_pulse -= delta
			if _pulse <= 0.0:
				_pulse = 0.45
				_aura_maut()
		if sisa_detik <= 0.0:
			aktif = false
			sisa_detik = 0.0
			_isi_ulang = 0.0
	elif _tersedia:
		if main_ada:
			_tampil_sisa -= delta
			if _tampil_sisa <= 0.0:
				_tersedia = false
				_tampil_sisa = 0.0
				_isi_ulang = 0.0
	else:
		if main_ada:
			_isi_ulang += delta
			if _isi_ulang >= JEDA_ISI_ULANG:
				_tersedia = true
				_tampil_sisa = DURASI_TAMPIL
				_isi_ulang = 0.0
	_perbarui_ui()

func _perbarui_ui() -> void:
	if _btn != null:
		_btn.visible = _tersedia and not aktif
		if _btn.visible:
			_btn.text = "PETI DEWA (%ds)" % int(ceil(_tampil_sisa))
	if _lbl != null:
		_lbl.visible = aktif
		if aktif:
			_lbl.text = "MODE DEWA  %d:%02d" % [int(sisa_detik) / 60, int(sisa_detik) % 60]

func _buka() -> void:
	_aktifkan()

func _aktifkan() -> void:
	aktif = true
	sisa_detik = DURASI
	_tersedia = false
	_tampil_sisa = 0.0
	_isi_ulang = 0.0
	_pulse = 0.0

func _aura_maut() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p == null:
		return
	var radius := 360.0
	for m in get_tree().get_nodes_in_group("musuh"):
		if not is_instance_valid(m):
			continue
		var mm := m as Node2D
		if mm == null:
			continue
		if p.global_position.distance_to(mm.global_position) <= radius:
			if m.has_method("kena"):
				m.kena(9999)
