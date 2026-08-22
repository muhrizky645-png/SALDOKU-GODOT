extends Node2D
# Orkestrator Fase 1-A: kamera ikut pemain, spawner, HUD (Level/XP, Skor, Timer, Nyawa).

const VER := "ISO11A"
const BAR_W := 360.0
const BAR_H := 26.0

var player = null
var camera: Camera2D = null
var over := false
var _diag := ""

var _lbl_level: Label = null
var _bar_bg: ColorRect = null
var _bar_fill: ColorRect = null
var _lbl_skor: Label = null
var _lbl_hp: Label = null
var _lbl_waktu: Label = null
var _lbl_dbg: Label = null

func _ready() -> void:
	add_to_group("main")
	RenderingServer.set_default_clear_color(Color(0.12, 0.13, 0.18))

	var S = get_node_or_null("/root/Skor")
	if S != null:
		S.reset()
	var L = get_node_or_null("/root/Level")
	if L != null:
		L.reset()
	var W = get_node_or_null("/root/Waktu")
	if W != null:
		W.reset()

	for nm in ["PlayerA", "PlayerB", "PlayerC"]:
		_cek(nm)

	camera = Camera2D.new()
	camera.zoom = Vector2(1.15, 1.15)
	add_child(camera)
	camera.enabled = true
	camera.make_current()

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

	_bangun_ui()

func _cek(nm: String) -> void:
	var s = load("res://scripts/" + nm + ".gd")
	if s == null:
		_diag += nm + "=L "
		return
	var o = s.new()
	if o == null:
		_diag += nm + "=N "
	else:
		o.free()

func _process(delta: float) -> void:
	if camera != null and player != null and is_instance_valid(player):
		camera.global_position = camera.global_position.lerp(player.global_position, clampf(delta * 5.0, 0.0, 1.0))
	_update_ui()

func _bangun_ui() -> void:
	var cl := CanvasLayer.new()
	add_child(cl)

	var jr = load("res://scripts/Joystick.gd")
	if jr != null:
		var joy = jr.new()
		cl.add_child(joy)

	_lbl_level = _mk_label(cl, Vector2(40, 34), 40)
	_lbl_level.add_theme_color_override("font_color", Color(0.7, 0.95, 0.5))

	_bar_bg = ColorRect.new()
	_bar_bg.position = Vector2(40, 86)
	_bar_bg.size = Vector2(BAR_W, BAR_H)
	_bar_bg.color = Color(0, 0, 0, 0.55)
	cl.add_child(_bar_bg)

	_bar_fill = ColorRect.new()
	_bar_fill.position = Vector2(42, 88)
	_bar_fill.size = Vector2(0, BAR_H - 4.0)
	_bar_fill.color = Color(0.45, 0.95, 1.0, 0.95)
	cl.add_child(_bar_fill)

	_lbl_skor = _mk_label(cl, Vector2(40, 124), 44)
	_lbl_hp = _mk_label(cl, Vector2(40, 186), 40)
	_lbl_dbg = _mk_label(cl, Vector2(40, 244), 24)

	_lbl_waktu = Label.new()
	_lbl_waktu.add_theme_font_size_override("font_size", 48)
	_lbl_waktu.add_theme_color_override("font_color", Color.WHITE)
	_lbl_waktu.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_lbl_waktu.anchor_left = 1.0
	_lbl_waktu.anchor_right = 1.0
	_lbl_waktu.offset_left = -300.0
	_lbl_waktu.offset_top = 34.0
	_lbl_waktu.offset_right = -40.0
	_lbl_waktu.offset_bottom = 100.0
	cl.add_child(_lbl_waktu)

func _mk_label(parent: Node, pos: Vector2, ukuran: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", ukuran)
	l.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(l)
	return l

func _update_ui() -> void:
	var hidup := player != null and is_instance_valid(player)
	var L = get_node_or_null("/root/Level")
	var S = get_node_or_null("/root/Skor")
	var W = get_node_or_null("/root/Waktu")
	if _lbl_level != null and L != null:
		_lbl_level.text = "LEVEL %d" % L.level
	if _bar_fill != null and L != null:
		_bar_fill.size = Vector2((BAR_W - 4.0) * L.rasio_xp(), BAR_H - 4.0)
	if _lbl_skor != null and S != null:
		_lbl_skor.text = "SKOR: %d" % S.skor
	if _lbl_hp != null:
		if hidup:
			_lbl_hp.text = "NYAWA: %d" % int(maxf(0.0, player.hp))
		else:
			_lbl_hp.text = "NYAWA: -"
	if _lbl_waktu != null and W != null:
		_lbl_waktu.text = W.teks()
	if _lbl_dbg != null:
		var pl := -1
		if hidup:
			pl = int(player.parts_loaded)
		var jml := get_tree().get_nodes_in_group("musuh").size()
		var lv := 0
		if L != null:
			lv = L.level
		_lbl_dbg.text = "DBG %s hidup=%s parts=%d musuh=%d lv=%d [%s]" % [VER, str(hidup), pl, jml, lv, _diag]

func tambah_skor(n: int) -> void:
	var S = get_node_or_null("/root/Skor")
	if S != null:
		S.tambah(n)

func game_over() -> void:
	if over:
		return
	over = true
	var W = get_node_or_null("/root/Waktu")
	if W != null:
		W.jalan = false
	var skor_txt := 0
	var rekor_txt := 0
	var S = get_node_or_null("/root/Skor")
	if S != null:
		skor_txt = S.skor
		rekor_txt = S.rekor
	var cl := CanvasLayer.new()
	add_child(cl)
	var l := Label.new()
	l.text = "GAME OVER\nSKOR: %d\nREKOR: %d\n\nSentuh untuk main lagi" % [skor_txt, rekor_txt]
	l.add_theme_font_size_override("font_size", 80)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(l)

func _unhandled_input(event: InputEvent) -> void:
	if over and event is InputEventScreenTouch and event.pressed:
		get_tree().reload_current_scene()
