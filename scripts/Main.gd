extends Node2D
# Orkestrator: kamera ikut pemain, spawner, HUD gaya Unity (plate + font pixel Thaleah), reset sistem global.
# HUD dihitung ulang biar SAMA dengan Unity (Unit=1080): panel LEVEL + bar XP cyan,
# plat SKOR (angka saja), plat TIMER (MM:SS), bar BOSS. Font pixel dari Tema.font_utama().
# Latar: rumput prosedural bertekstur (helai rumput), di-tile & ikut kamera.

const LATAR := Color(0.32728687, 0.6698113, 0.31278923)

# Palet (ikut Tema.cs Unity)
const C_PLATE := Color(0.05, 0.06, 0.04, 0.78)
const C_GARIS_REDUP := Color(0.38, 0.42, 0.24, 0.9)
const C_DARAH := Color(0.82, 0.17, 0.13, 1.0)
const C_TULANG := Color(0.95, 0.94, 0.87, 1.0)
const C_ARMY := Color(0.66, 0.85, 0.38, 1.0)
const C_XP := Color(0.45, 0.95, 1.0, 0.95)
const C_BAR_BG := Color(0.0, 0.0, 0.0, 0.55)

# Ukuran font responsif Unity pada Unit=1080
const FLV := 32
const FSKOR := 54
const FTIMER := 56

# Geometri bar XP (dihitung dari LevelSystem.cs pada Unit=1080)
const XP_X := 58.97
const XP_Y := 117.8
const XP_W := 832.5
const XP_H := 44.16

var player = null
var camera: Camera2D = null
var over := false
var _menu = null
var _font: Font = null
var _latar: Sprite2D = null

var _panel_level: Panel = null
var _lbl_level: Label = null
var _xp_fill: ColorRect = null
var _panel_skor: Panel = null
var _lbl_skor: Label = null
var _panel_waktu: Panel = null
var _lbl_waktu: Label = null

var _lbl_boss: Label = null
var _boss_bg: Panel = null
var _boss_fill: ColorRect = null

func _ready() -> void:
	add_to_group("main")
	RenderingServer.set_default_clear_color(LATAR)

	var tf = get_node_or_null("/root/Tema")
	if tf != null and tf.has_method("font_utama"):
		_font = tf.font_utama()

	for nm in ["Skor", "Level", "Waktu", "Skill", "Senjata", "Dewa"]:
		var g = get_node_or_null("/root/" + nm)
		if g != null and g.has_method("reset"):
			g.reset()

	camera = Camera2D.new()
	camera.zoom = Vector2(1.15, 1.15)
	add_child(camera)
	camera.enabled = true
	camera.make_current()
	camera.global_position = Vector2.ZERO

	_bangun_latar()
	_bangun_ui()
	_buat_menu()

	var t = get_node_or_null("/root/Tema")
	if t != null and t.langsung_main:
		t.langsung_main = false
		if _menu != null:
			_menu.mulai(false)
	else:
		if _menu != null:
			_menu.tampilkan_home()

func _buat_menu() -> void:
	var ms = load("res://scripts/Menu.gd")
	if ms != null:
		_menu = ms.new()
		_menu.main = self
		add_child(_menu)

func mulai_main() -> void:
	if player != null and is_instance_valid(player):
		return
	var ps = load("res://scripts/Player.gd")
	if ps != null:
		player = ps.new()
	if player != null:
		add_child(player)
		player.global_position = Vector2.ZERO
	camera.global_position = Vector2.ZERO
	var spr = load("res://scripts/Spawner.gd")
	if spr != null:
		var sp = spr.new()
		if sp != null:
			sp.player = player
			add_child(sp)

func tambah_skor(n: int) -> void:
	var S = get_node_or_null("/root/Skor")
	if S != null:
		S.tambah(n)

func _process(delta: float) -> void:
	if camera != null and player != null and is_instance_valid(player):
		camera.global_position = camera.global_position.lerp(player.global_position, clampf(delta * 5.0, 0.0, 1.0))
	_perbarui_latar()
	_update_ui()

# ====== LATAR RUMPUT PROSEDURAL ======
func _buat_tekstur_rumput() -> ImageTexture:
	var n := 128
	var img := Image.create(n, n, false, Image.FORMAT_RGBA8)
	var rng := RandomNumberGenerator.new()
	rng.seed = 20240823
	var dasar := Color(0.30, 0.62, 0.29)
	# 1) dasar rumput: variasi petak lembut + noise halus
	for y in n:
		for x in n:
			var c := dasar
			var v := rng.randf_range(-0.03, 0.03)
			c = Color(clampf(c.r + v, 0.0, 1.0), clampf(c.g + v * 1.2, 0.0, 1.0), clampf(c.b + v, 0.0, 1.0), 1.0)
			if (int(x / 24) + int(y / 24)) % 2 == 0:
				c = c.darkened(0.05)
			else:
				c = c.lightened(0.03)
			img.set_pixel(x, y, c)
	# 2) helai rumput: goresan vertikal pendek terang/gelap (jauh dari tepi biar tile mulus)
	var jml := 300
	for i in jml:
		var bx := rng.randi_range(2, n - 3)
		var by := rng.randi_range(7, n - 3)
		var tinggi := rng.randi_range(3, 7)
		var warna: Color
		if rng.randf() < 0.5:
			warna = dasar.lightened(rng.randf_range(0.12, 0.30))
		else:
			warna = dasar.darkened(rng.randf_range(0.12, 0.28))
		var lebar: int = 1 if rng.randf() < 0.7 else 2
		for t in tinggi:
			var yy := by - t
			if yy < 0:
				break
			for lw in lebar:
				var xx := bx + lw
				if xx >= 0 and xx < n and yy >= 0 and yy < n:
					img.set_pixel(xx, yy, warna)
	return ImageTexture.create_from_image(img)

func _bangun_latar() -> void:
	_latar = Sprite2D.new()
	_latar.texture = _buat_tekstur_rumput()
	_latar.centered = true
	_latar.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	_latar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_latar.region_enabled = true
	_latar.z_index = -100
	_latar.z_as_relative = false
	add_child(_latar)
	_perbarui_latar()

func _perbarui_latar() -> void:
	if _latar == null:
		return
	var cam := Vector2.ZERO
	if camera != null and is_instance_valid(camera):
		cam = camera.global_position
	var ukuran := Vector2(3200.0, 4800.0)
	_latar.global_position = cam
	_latar.region_rect = Rect2(cam - ukuran * 0.5, ukuran)

# ====== HUD ======
func _plate(bg: Color, border: Color, tebal: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(tebal)
	sb.set_corner_radius_all(0)
	return sb

func _mk_panel(parent: Node, x: float, y: float, w: float, h: float, bg: Color, border: Color, tebal: int) -> Panel:
	var p := Panel.new()
	p.position = Vector2(x, y)
	p.size = Vector2(w, h)
	p.add_theme_stylebox_override("panel", _plate(bg, border, tebal))
	parent.add_child(p)
	return p

func _mk_label(parent: Node, x: float, y: float, w: float, h: float, ukuran: int, warna: Color, ah: int, av: int) -> Label:
	var l := Label.new()
	l.position = Vector2(x, y)
	l.size = Vector2(w, h)
	l.horizontal_alignment = ah
	l.vertical_alignment = av
	l.add_theme_font_size_override("font_size", ukuran)
	l.add_theme_color_override("font_color", warna)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	if _font != null:
		l.add_theme_font_override("font", _font)
	parent.add_child(l)
	return l

func _bangun_ui() -> void:
	var cl := CanvasLayer.new()
	add_child(cl)

	var jr = load("res://scripts/Joystick.gd")
	if jr != null:
		var joy = jr.new()
		cl.add_child(joy)

	# ---- PANEL LEVEL (kiri atas, memanjang ke kanan) ----
	_panel_level = _mk_panel(cl, 32.4, 32.4, 885.6, 147.2, C_PLATE, C_GARIS_REDUP, 2)
	_lbl_level = _mk_label(cl, 58.97, 45.65, 832.5, 58.88, FLV, C_ARMY, HORIZONTAL_ALIGNMENT_LEFT, VERTICAL_ALIGNMENT_TOP)
	_lbl_level.text = "LEVEL 1"

	# bar XP tebal cyan di bawah panel level
	_mk_panel(cl, XP_X, XP_Y, XP_W, XP_H, C_BAR_BG, C_GARIS_REDUP, 1)
	_xp_fill = ColorRect.new()
	_xp_fill.position = Vector2(XP_X + 1.0, XP_Y + 1.0)
	_xp_fill.size = Vector2(0.0, XP_H - 2.0)
	_xp_fill.color = C_XP
	cl.add_child(_xp_fill)

	# ---- PLAT SKOR (angka saja, di bawah panel level, mepet kiri) ----
	_panel_skor = _mk_panel(cl, 32.4, 199.04, 140.4, 91.8, C_PLATE, C_GARIS_REDUP, 2)
	_lbl_skor = _mk_label(cl, 32.4, 199.04, 140.4, 91.8, FSKOR, C_TULANG, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	_lbl_skor.text = "0"

	# ---- PLAT TIMER (MM:SS, mepet kanan, sejajar skor) ----
	_panel_waktu = _mk_panel(cl, 846.0, 197.34, 201.6, 95.2, C_PLATE, C_GARIS_REDUP, 2)
	_lbl_waktu = _mk_label(cl, 846.0, 197.34, 201.6, 95.2, FTIMER, C_TULANG, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	_lbl_waktu.text = "00:00"

	# ---- BAR BOSS (tengah) ----
	_lbl_boss = _mk_label(cl, 0.0, 288.0, 1080.0, 67.2, 32, C_DARAH, HORIZONTAL_ALIGNMENT_CENTER, VERTICAL_ALIGNMENT_CENTER)
	_lbl_boss.text = "! B O S S !"
	_lbl_boss.visible = false
	_boss_bg = _mk_panel(cl, 162.0, 364.8, 756.0, 49.92, C_BAR_BG, C_GARIS_REDUP, 1)
	_boss_bg.visible = false
	_boss_fill = ColorRect.new()
	_boss_fill.position = Vector2(163.0, 365.8)
	_boss_fill.size = Vector2(0.0, 47.92)
	_boss_fill.color = C_DARAH
	_boss_fill.visible = false
	cl.add_child(_boss_fill)

func _update_ui() -> void:
	var L = get_node_or_null("/root/Level")
	var S = get_node_or_null("/root/Skor")
	var W = get_node_or_null("/root/Waktu")
	if _lbl_level != null and L != null:
		_lbl_level.text = "LEVEL %d" % L.level
	if _xp_fill != null and L != null:
		_xp_fill.size = Vector2((XP_W - 2.0) * clampf(L.rasio_xp(), 0.0, 1.0), XP_H - 2.0)
	if _lbl_skor != null and S != null:
		var s := str(S.skor)
		_lbl_skor.text = s
		var plW: float = maxf(float(FSKOR) * 2.6, float(FSKOR) * (1.1 + 0.62 * float(s.length())))
		if _panel_skor != null:
			_panel_skor.size = Vector2(plW, _panel_skor.size.y)
		_lbl_skor.size = Vector2(plW, _lbl_skor.size.y)
	if _lbl_waktu != null and W != null:
		_lbl_waktu.text = W.teks()
	_update_boss_bar()

func _update_boss_bar() -> void:
	var bos = get_tree().get_first_node_in_group("bos")
	var ada: bool = bos != null and is_instance_valid(bos)
	if _lbl_boss != null:
		_lbl_boss.visible = ada
	if _boss_bg != null:
		_boss_bg.visible = ada
	if _boss_fill != null:
		_boss_fill.visible = ada
		if ada:
			var rasio := 0.0
			if bos.nyawa_maks > 0:
				rasio = clampf(float(bos.hp) / float(bos.nyawa_maks), 0.0, 1.0)
			_boss_fill.size = Vector2((756.0 - 2.0) * rasio, _boss_fill.size.y)

func game_over() -> void:
	if over:
		return
	over = true
	if _menu != null and _menu.has_method("mode_game_over"):
		_menu.mode_game_over()
	var snd = get_node_or_null("/root/Sound")
	if snd != null:
		snd.game_over()
	var W = get_node_or_null("/root/Waktu")
	if W != null:
		W.jalan = false
	var S = get_node_or_null("/root/Skor")
	var skor := 0
	var rekor := 0
	if S != null:
		skor = S.skor
		rekor = S.rekor
	var cl := CanvasLayer.new()
	cl.layer = 80
	add_child(cl)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(bg)
	var lbl := Label.new()
	lbl.text = "GAME OVER\nSKOR %d\nREKOR %d\n\nSentuh untuk main lagi" % [skor, rekor]
	lbl.add_theme_font_size_override("font_size", 56)
	lbl.add_theme_color_override("font_color", Color.WHITE)
	if _font != null:
		lbl.add_theme_font_override("font", _font)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(lbl)

func _unhandled_input(event: InputEvent) -> void:
	if not over:
		return
	if event is InputEventScreenTouch and event.pressed:
		var t = get_node_or_null("/root/Tema")
		if t != null:
			t.langsung_main = true
		get_tree().reload_current_scene()
	elif event is InputEventMouseButton and event.pressed:
		var t2 = get_node_or_null("/root/Tema")
		if t2 != null:
			t2.langsung_main = true
		get_tree().reload_current_scene()
