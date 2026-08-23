extends CanvasLayer
# Menu: Home (pilih karakter, REKOR, MAIN, PENGATURAN), Jeda, Pengaturan.
# Meniru GameMenu.cs + Tema.cs dari versi Unity.

var main: Node = null

var _home: Control = null
var _jeda: Control = null
var _setting: Control = null
var _tombol_jeda: Button = null

var _lbl_nama: Label = null
var _portrait: TextureRect = null
var _lbl_rekor: Label = null
var _btn_mute_musik: Button = null
var _btn_mute_efek: Button = null

var _setting_dari := "home"

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 90
	_bangun_home()
	_bangun_setting()
	_bangun_jeda()
	_bangun_tombol_jeda()

# ---------- util ----------
func _snd():
	return get_node_or_null("/root/Sound")

func _klik() -> void:
	var s = _snd()
	if s != null:
		s.klik()

func _overlay(warna: Color) -> ColorRect:
	var r := ColorRect.new()
	r.color = warna
	r.set_anchors_preset(Control.PRESET_FULL_RECT)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r

func _vbox() -> VBoxContainer:
	var v := VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation", 26)
	return v

func _center(child: Control) -> CenterContainer:
	var c := CenterContainer.new()
	c.set_anchors_preset(Control.PRESET_FULL_RECT)
	c.add_child(child)
	return c

func _label(teks: String, ukuran: int, warna: Color) -> Label:
	var l := Label.new()
	l.text = teks
	l.add_theme_font_size_override("font_size", ukuran)
	l.add_theme_color_override("font_color", warna)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l

func _tombol(teks: String, ukuran: int) -> Button:
	var b := Button.new()
	b.text = teks
	b.add_theme_font_size_override("font_size", ukuran)
	b.add_theme_color_override("font_color", Tema.TULANG)
	b.add_theme_color_override("font_hover_color", Tema.TULANG)
	b.add_theme_color_override("font_pressed_color", Tema.AMBER)
	b.add_theme_stylebox_override("normal", Tema.gaya_panel(Tema.PANEL, Tema.GARIS))
	b.add_theme_stylebox_override("hover", Tema.gaya_panel(Tema.PANEL_TERANG, Tema.ARMY))
	b.add_theme_stylebox_override("pressed", Tema.gaya_panel(Tema.PLATE, Tema.ARMY))
	b.add_theme_stylebox_override("focus", Tema.gaya_panel(Tema.PANEL, Tema.GARIS))
	b.custom_minimum_size = Vector2(460, 104)
	return b

func _panel(child: Control) -> PanelContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", Tema.gaya_panel(Tema.PANEL, Tema.GARIS_REDUP))
	p.add_child(child)
	return p

# ---------- HOME ----------
func _bangun_home() -> void:
	_home = Control.new()
	_home.set_anchors_preset(Control.PRESET_FULL_RECT)
	_home.add_child(_overlay(Color(0.04, 0.10, 0.05, 0.6)))
	var v := _vbox()
	v.add_child(_label("SALDOKU", Tema.font(0.13), Tema.TULANG))
	v.add_child(_label("LAST STAND", Tema.font(0.055), Tema.AMBER))
	_lbl_rekor = _label("REKOR 0", Tema.font(0.04), Tema.ARMY)
	v.add_child(_panel(_lbl_rekor))
	var hb := HBoxContainer.new()
	hb.alignment = BoxContainer.ALIGNMENT_CENTER
	hb.add_theme_constant_override("separation", 30)
	var kiri := _tombol("<", Tema.font(0.06))
	kiri.custom_minimum_size = Vector2(120, 120)
	kiri.pressed.connect(_on_prev)
	var tengah := VBoxContainer.new()
	tengah.alignment = BoxContainer.ALIGNMENT_CENTER
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(220, 220)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tengah.add_child(_portrait)
	_lbl_nama = _label("?", Tema.font(0.04), Tema.TULANG)
	tengah.add_child(_lbl_nama)
	var kanan := _tombol(">", Tema.font(0.06))
	kanan.custom_minimum_size = Vector2(120, 120)
	kanan.pressed.connect(_on_next)
	hb.add_child(kiri)
	hb.add_child(tengah)
	hb.add_child(kanan)
	v.add_child(hb)
	var main_btn := _tombol("MAIN", Tema.font(0.05))
	main_btn.pressed.connect(_on_main)
	v.add_child(main_btn)
	var set_btn := _tombol("PENGATURAN", Tema.font(0.045))
	set_btn.pressed.connect(_on_buka_setting_home)
	v.add_child(set_btn)
	_home.add_child(_center(v))
	add_child(_home)
	_home.visible = false

# ---------- PENGATURAN ----------
func _bangun_setting() -> void:
	_setting = Control.new()
	_setting.set_anchors_preset(Control.PRESET_FULL_RECT)
	_setting.add_child(_overlay(Tema.OVERLAY))
	var v := _vbox()
	v.add_child(_label("PENGATURAN", Tema.font(0.07), Tema.TULANG))
	var s = _snd()
	v.add_child(_label("MUSIK", Tema.font(0.04), Tema.ARMY))
	var sl_musik := HSlider.new()
	sl_musik.min_value = 0.0
	sl_musik.max_value = 1.0
	sl_musik.step = 0.05
	sl_musik.custom_minimum_size = Vector2(560, 60)
	if s != null:
		sl_musik.value = s.vol_musik
	sl_musik.value_changed.connect(_on_musik_ubah)
	v.add_child(sl_musik)
	_btn_mute_musik = _tombol("MUSIK: AKTIF", Tema.font(0.038))
	_btn_mute_musik.pressed.connect(_on_mute_musik)
	v.add_child(_btn_mute_musik)
	v.add_child(_label("EFEK", Tema.font(0.04), Tema.ARMY))
	var sl_efek := HSlider.new()
	sl_efek.min_value = 0.0
	sl_efek.max_value = 1.0
	sl_efek.step = 0.05
	sl_efek.custom_minimum_size = Vector2(560, 60)
	if s != null:
		sl_efek.value = s.vol_efek
	sl_efek.value_changed.connect(_on_efek_ubah)
	v.add_child(sl_efek)
	_btn_mute_efek = _tombol("EFEK: AKTIF", Tema.font(0.038))
	_btn_mute_efek.pressed.connect(_on_mute_efek)
	v.add_child(_btn_mute_efek)
	var kembali := _tombol("KEMBALI", Tema.font(0.045))
	kembali.pressed.connect(_on_tutup_setting)
	v.add_child(kembali)
	_setting.add_child(_center(v))
	add_child(_setting)
	_setting.visible = false
	_refresh_mute()

# ---------- JEDA ----------
func _bangun_jeda() -> void:
	_jeda = Control.new()
	_jeda.set_anchors_preset(Control.PRESET_FULL_RECT)
	_jeda.add_child(_overlay(Tema.OVERLAY))
	var v := _vbox()
	v.add_child(_label("JEDA", Tema.font(0.08), Tema.TULANG))
	var b1 := _tombol("LANJUT", Tema.font(0.05))
	b1.pressed.connect(_on_lanjut)
	v.add_child(b1)
	var b2 := _tombol("ULANGI", Tema.font(0.05))
	b2.pressed.connect(_on_ulangi)
	v.add_child(b2)
	var b3 := _tombol("PENGATURAN", Tema.font(0.045))
	b3.pressed.connect(_on_buka_setting_jeda)
	v.add_child(b3)
	var b4 := _tombol("KE HOME", Tema.font(0.045))
	b4.pressed.connect(_on_ke_home)
	v.add_child(b4)
	_jeda.add_child(_center(v))
	add_child(_jeda)
	_jeda.visible = false

func _bangun_tombol_jeda() -> void:
	_tombol_jeda = _tombol("II", Tema.font(0.05))
	_tombol_jeda.anchor_left = 1.0
	_tombol_jeda.anchor_right = 1.0
	_tombol_jeda.offset_left = -140.0
	_tombol_jeda.offset_top = 30.0
	_tombol_jeda.offset_right = -24.0
	_tombol_jeda.offset_bottom = 146.0
	_tombol_jeda.pressed.connect(_on_jeda)
	add_child(_tombol_jeda)
	_tombol_jeda.visible = false

# ---------- STATE ----------
func tampilkan_home() -> void:
	get_tree().paused = true
	_home.visible = true
	_jeda.visible = false
	_setting.visible = false
	_tombol_jeda.visible = false
	_refresh_rekor()
	_refresh_picker()

func mulai(pakai_klik: bool = true) -> void:
	if pakai_klik:
		_klik()
	_home.visible = false
	_jeda.visible = false
	_setting.visible = false
	_tombol_jeda.visible = true
	get_tree().paused = false
	if main != null and main.has_method("mulai_main"):
		main.mulai_main()

func mode_game_over() -> void:
	_tombol_jeda.visible = false
	_jeda.visible = false
	_setting.visible = false

func _on_main() -> void:
	mulai()

func _on_jeda() -> void:
	_klik()
	get_tree().paused = true
	_jeda.visible = true
	_tombol_jeda.visible = false

func _on_lanjut() -> void:
	_klik()
	_jeda.visible = false
	_tombol_jeda.visible = true
	get_tree().paused = false

func _on_ulangi() -> void:
	_klik()
	Tema.langsung_main = true
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_ke_home() -> void:
	_klik()
	Tema.langsung_main = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_buka_setting_home() -> void:
	_klik()
	_setting_dari = "home"
	_home.visible = false
	_setting.visible = true

func _on_buka_setting_jeda() -> void:
	_klik()
	_setting_dari = "jeda"
	_jeda.visible = false
	_setting.visible = true

func _on_tutup_setting() -> void:
	_klik()
	_setting.visible = false
	if _setting_dari == "home":
		_home.visible = true
	else:
		_jeda.visible = true

# ---------- PICKER / REKOR ----------
func _on_prev() -> void:
	_klik()
	var K = get_node_or_null("/root/Karakter")
	if K != null:
		K.sebelumnya()
	_refresh_picker()

func _on_next() -> void:
	_klik()
	var K = get_node_or_null("/root/Karakter")
	if K != null:
		K.berikutnya()
	_refresh_picker()

func _refresh_picker() -> void:
	var K = get_node_or_null("/root/Karakter")
	if K == null:
		return
	if _lbl_nama != null:
		_lbl_nama.text = K.nama_dipilih()
	if _portrait != null:
		_portrait.texture = K.tekstur(K.dipilih, "Head")

func _refresh_rekor() -> void:
	var S = get_node_or_null("/root/Skor")
	if S != null and _lbl_rekor != null:
		_lbl_rekor.text = "REKOR %d" % S.rekor

# ---------- SUARA ----------
func _on_musik_ubah(v: float) -> void:
	var s = _snd()
	if s != null:
		s.set_vol_musik(v)

func _on_efek_ubah(v: float) -> void:
	var s = _snd()
	if s != null:
		s.set_vol_efek(v)

func _on_mute_musik() -> void:
	_klik()
	var s = _snd()
	if s != null:
		s.toggle_mute_musik()
	_refresh_mute()

func _on_mute_efek() -> void:
	_klik()
	var s = _snd()
	if s != null:
		s.toggle_mute_efek()
	_refresh_mute()

func _refresh_mute() -> void:
	var s = _snd()
	if s == null:
		return
	if _btn_mute_musik != null:
		_btn_mute_musik.text = "MUSIK: BISU" if s.mute_musik else "MUSIK: AKTIF"
	if _btn_mute_efek != null:
		_btn_mute_efek.text = "EFEK: BISU" if s.mute_efek else "EFEK: AKTIF"
