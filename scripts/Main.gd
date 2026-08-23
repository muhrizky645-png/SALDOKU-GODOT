extends Node2D
# Orkestrator Fase 1-C: kamera ikut pemain, spawner, HUD, bar nyawa BOSS, reset semua sistem global.

const VER := "ISO13D"
const BAR_W := 360.0
const BAR_H := 26.0
# Warna "Paper_4" hijau dari scene Unity (SampleScene): RGB 0.327, 0.670, 0.313.
const LATAR := Color(0.32728687, 0.6698113, 0.31278923)

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

var _lbl_boss: Label = null
var _boss_bg: ColorRect = null
var _boss_fill: ColorRect = null

func _ready() -> void:
	add_to_group("main")
	RenderingServer.set_default_clear_color(LATAR)

	for nm in ["Skor", "Level", "Waktu", "Skill", "Senjata", "Dewa"]:
		var g = get_node_or_null("/root/" + nm)
		if g != null and g.has_method("reset"):
			g.reset()

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

	_lbl_boss = Label.new()
	_lbl_boss.add_theme_font_size_override("font_size", 32)
	_lbl_boss.add_theme_color_override("font_color", Color(1.0, 0.5, 0.5))
	_lbl_boss.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_lbl_boss.anchor_left = 0.0
	_lbl_boss.anchor_right = 1.0
	_lbl_boss.offset_top = 320.0
	_lbl_boss.offset_bottom = 360.0
	_lbl_boss.text = "BOSS"
	_lbl_boss.visible = false
	cl.add_child(_lbl_boss)

	_boss_bg = ColorRect.new()
	_boss_bg.color = Color(0, 0, 0, 0.55)
	_boss_bg.anchor_left = 0.5
	_boss_bg.anchor_right = 0.5
	_boss_bg.offset_left = -300.0
	_boss_bg.offset_right = 300.0
	_boss_bg.offset_top = 364.0
	_boss_bg.offset_bottom = 392.0
	_boss_bg.visible = false
	cl.add_child(_boss_bg)

	_boss_fill = ColorRect.new()
	_boss_fill.color = Color(1.0, 0.3, 0.3, 0.95)
	_boss_fill.anchor_left = 0.5
	_boss_fill.anchor_right = 0.5
	_boss_fill.offset_left = -298.0
	_boss_fill.offset_right = 298.0
	_boss_fill.offset_top = 366.0
	_boss_fill.offset_bottom = 390.0
	_boss_fill.visible = false
	cl.add_child(_boss_fill)

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
		_lbl_skor.text = "SKOR %d" % S.skor
	if _lbl_hp != null:
		var hpv := 0
		if hidup:
			hpv = int(maxf(0.0, player.hp))
		_lbl_hp.text = "NYAWA %d" % hpv
	if _lbl_waktu != null and W != null:
		_lbl_waktu.text = W.teks()
	_update_boss_bar()
	if _lbl_dbg != null:
		var jml := get_tree().get_nodes_in_group("musuh").size()
		var nb := get_tree().get_nodes_in_group("bos").size()
		var lv := 0
		if L != null:
			lv = L.level
		var pl := 0
		if hidup:
			pl = player.parts_loaded
		var sinfo := ""
		var Sen = get_node_or_null("/root/Senjata")
		if Sen != null:
			sinfo = "O%d A%d R%d" % [Sen.lv_orbit, Sen.lv_aura, Sen.lv_roket]
		_lbl_dbg.text = "DBG %s hidup=%s parts=%d musuh=%d bos=%d lv=%d %s [%s]" % [VER, str(hidup), pl, jml, nb, lv, sinfo, _diag]

func _update_boss_bar() -> void:
	var bos = get_tree().get_first_node_in_group("bos")
	var ada_bos: bool = bos != null and is_instance_valid(bos)
	if _lbl_boss != null:
		_lbl_boss.visible = ada_bos
	if _boss_bg != null:
		_boss_bg.visible = ada_bos
	if _boss_fill != null:
		_boss_fill.visible = ada_bos
		if ada_bos:
			var rasio := 0.0
			if bos.nyawa_maks > 0:
				rasio = clampf(float(bos.hp) / float(bos.nyawa_maks), 0.0, 1.0)
			_boss_fill.offset_left = -298.0
			_boss_fill.offset_right = -298.0 + 596.0 * rasio

func game_over() -> void:
	if over:
		return
	over = true
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
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	cl.add_child(lbl)

func _unhandled_input(event: InputEvent) -> void:
	if not over:
		return
	if event is InputEventScreenTouch and event.pressed:
		get_tree().reload_current_scene()
	elif event is InputEventMouseButton and event.pressed:
		get_tree().reload_current_scene()
