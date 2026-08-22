extends Node2D
# Uji B: variabel + pembuatan rig/tekstur.

var speed := 340.0
var bob_amount := 0.08
var bob_speed := 12.0
var goyang_sudut := deg_to_rad(8.0)
var goyang_kecepatan := 12.0
var fire_rate := 1.2
var jumlah_peluru := 1
var sudut_sebar := deg_to_rad(12.0)
var range_tembak := 560.0
var _tembak := 0.5
var hp := 100.0
var hp_maks := 100.0
var sudah_mati := false
var nama := "?"
var parts_loaded := 0
var rig: Node2D = null
var _k := 1.0
var _face := 1.0
var _t := 0.0
var _weapon_tex: Texture2D = null
const TARGET_TINGGI := 210.0

func _ready() -> void:
	_bangun_rig()

func _bangun_rig() -> void:
	var K = get_node_or_null("/root/Karakter")
	rig = Node2D.new()
	add_child(rig)
	var body: Texture2D = null
	var head: Texture2D = null
	var lfoot: Texture2D = null
	var rfoot: Texture2D = null
	if K != null:
		var idx: int = K.dipilih
		nama = K.nama_dipilih()
		_weapon_tex = K.tekstur(idx, "Weapon")
		body = K.tekstur(idx, "Body")
		head = K.tekstur(idx, "Head")
		lfoot = K.tekstur(idx, "Left_Foot")
		rfoot = K.tekstur(idx, "Right_Foot")
	var bw := 32.0
	var bh := 48.0
	var hh := 28.0
	if body != null:
		bw = float(body.get_width())
		bh = float(body.get_height())
	if head != null:
		hh = float(head.get_height())
	_tambah(rfoot, Vector2(bw * 0.22, bh * 0.45))
	_tambah(lfoot, Vector2(-bw * 0.22, bh * 0.45))
	_tambah(_weapon_tex, Vector2(bw * 0.5, bh * 0.05))
	_tambah(body, Vector2.ZERO)
	_tambah(head, Vector2(0.0, -bh * 0.5 - hh * 0.2))
	if parts_loaded == 0:
		_fallback()
	var total_h := bh + hh * 0.7
	if total_h < 1.0:
		total_h = 1.0
	_k = TARGET_TINGGI / total_h
	rig.scale = Vector2(_k, _k)

func _fallback() -> void:
	var b := Polygon2D.new()
	b.polygon = PackedVector2Array([Vector2(-30, -45), Vector2(30, -45), Vector2(30, 45), Vector2(-30, 45)])
	b.color = Color(0.30, 0.65, 1.0)
	rig.add_child(b)
	var pts := PackedVector2Array()
	for i in 16:
		var ang := TAU * float(i) / 16.0
		pts.append(Vector2(cos(ang), sin(ang)) * 22.0 + Vector2(0, -66))
	var h := Polygon2D.new()
	h.polygon = pts
	h.color = Color(1.0, 0.85, 0.6)
	rig.add_child(h)

func _tambah(tex: Texture2D, pos: Vector2) -> void:
	if tex == null:
		return
	parts_loaded += 1
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	rig.add_child(s)
