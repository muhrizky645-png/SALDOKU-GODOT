extends Node2D
# Uji C: versi lengkap. (fix cast Node2D di loop grup)

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

func _process(delta: float) -> void:
	if sudah_mati:
		return
	_t += delta
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		dir.y += 1.0
	var joy = get_tree().get_first_node_in_group("joystick")
	if joy != null:
		var jd: Vector2 = joy.direction
		dir += jd
	dir = dir.limit_length(1.0)
	global_position += dir * speed * delta
	var jalan := dir.length_squared() > 0.01
	if dir.x < -0.01:
		_face = -1.0
	elif dir.x > 0.01:
		_face = 1.0
	if jalan:
		var bob := 1.0 + abs(sin(_t * bob_speed)) * bob_amount
		scale = Vector2(1.0, bob)
	else:
		scale = Vector2.ONE
	if rig != null:
		rig.scale = Vector2(_face * _k, _k)
		if jalan:
			rig.rotation = sin(_t * goyang_kecepatan) * goyang_sudut
		else:
			rig.rotation = lerp_angle(rig.rotation, 0.0, delta * 12.0)
	_tembak -= delta
	if _tembak <= 0.0:
		_tembak_sekarang()
		_tembak = fire_rate
	for e in get_tree().get_nodes_in_group("musuh"):
		var em := e as Node2D
		if em != null and is_instance_valid(em):
			if global_position.distance_to(em.global_position) < 72.0:
				hp -= 14.0 * delta
	if hp <= 0.0 and not sudah_mati:
		sudah_mati = true
		var main = get_tree().get_first_node_in_group("main")
		if main != null and main.has_method("game_over"):
			main.game_over()

func _tembak_sekarang() -> void:
	var musuh := get_tree().get_nodes_in_group("musuh")
	if musuh.is_empty():
		return
	var terdekat: Node2D = null
	var jd := range_tembak
	for z in musuh:
		var zm := z as Node2D
		if zm == null or not is_instance_valid(zm):
			continue
		var d := global_position.distance_to(zm.global_position)
		if d < jd:
			jd = d
			terdekat = zm
	if terdekat == null:
		return
	var arah := (terdekat.global_position - global_position).normalized()
	var n := maxi(1, jumlah_peluru)
	var total := float(n - 1) * sudut_sebar
	var mulai := -total / 2.0
	var main = get_tree().get_first_node_in_group("main")
	if main == null:
		return
	for i in n:
		var ap := arah.rotated(mulai + float(i) * sudut_sebar)
		var b = load("res://scripts/Bullet.gd").new()
		b.setup(_weapon_tex, ap)
		main.add_child(b)
		b.global_position = global_position
