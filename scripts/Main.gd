extends Node2D
# Orkestrator Fase 1: kamera ikut pemain, spawner, HUD, joystick.

const VER := "MIN9"

var player = null
var camera: Camera2D = null
var skor := 0
var waktu := 0.0
var over := false
var _diag := ""

var _lbl_skor: Label = null
var _lbl_hp: Label = null
var _lbl_waktu: Label = null
var _lbl_dbg: Label = null

func _ready() -> void:
	add_to_group("main")
	RenderingServer.set_default_clear_color(Color(0.12, 0.13, 0.18))

	for nm in ["KarakterData", "Bullet", "Enemy", "Spawner", "Joystick", "Player"]:
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
		camera.global_position = camera.global_position.lerp(player.global_position, clampf(delta * 6.0, 0.0, 1.0))
	if not over:
		waktu += delta
	_update_ui()

func _bangun_ui() -> void:
	var cl := CanvasLayer.new()
	add_child(cl)

	var jr = load("res://scripts/Joystick.gd")
	if jr != null:
		var joy = jr.new()
		cl.add_child(joy)

	_lbl_skor = _mk_label(cl, Vector2(40, 40), 52)
	_lbl_hp = _mk_label(cl, Vector2(40, 110), 44)
	_lbl_waktu = _mk_label(cl, Vector2(40, 172), 44)
	_lbl_dbg = _mk_label(cl, Vector2(40, 234), 28)

func _mk_label(parent: Node, pos: Vector2, ukuran: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_font_size_override("font_size", ukuran)
	l.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(l)
	return l

func _update_ui() -> void:
	var hidup := player != null and is_instance_valid(player)
	if _lbl_skor != null:
		_lbl_skor.text = "SKOR: %d" % skor
	if _lbl_hp != null:
		if hidup:
			_lbl_hp.text = "NYAWA: %d" % int(maxf(0.0, player.hp))
		else:
			_lbl_hp.text = "NYAWA: -"
	if _lbl_waktu != null:
		_lbl_waktu.text = "WAKTU: %02d:%02d" % [int(waktu) / 60, int(waktu) % 60]
	if _lbl_dbg != null:
		var pl := -1
		if hidup:
			pl = int(player.parts_loaded)
		var jml := get_tree().get_nodes_in_group("musuh").size()
		_lbl_dbg.text = "DBG %s hidup=%s parts=%d musuh=%d [%s]" % [VER, str(hidup), pl, jml, _diag]

func tambah_skor(n: int) -> void:
	skor += n

func game_over() -> void:
	if over:
		return
	over = true
	var cl := CanvasLayer.new()
	add_child(cl)
	var l := Label.new()
	l.text = "GAME OVER\nSKOR: %d\n\nSentuh untuk main lagi" % skor
	l.add_theme_font_size_override("font_size", 80)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(l)

func _unhandled_input(event: InputEvent) -> void:
	if over and event is InputEventScreenTouch and event.pressed:
		get_tree().reload_current_scene()
