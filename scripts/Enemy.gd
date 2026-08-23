extends Area2D
# Port dari EnemyChase.cs (Fase C): variasi tipe musuh + BOSS + tembak + drop item/efek.
# Musuh pakai rig sprite karakter cute (pack Jovial Games, sama seperti Player),
# tanpa senjata, di-tint per tipe via modulate.

var speed := 120.0
var hp := 1
var skor := 10
var radius := 30.0
var xp := 1

var tipe := 0            # 0 Biasa, 1 Cepat, 2 Tank, 3 Peledak, 4 Penembak
var bos := false
var nyawa_maks := 1

var _player: Node2D = null
var _dead := false
var _flash := 0.0
var _warna_dasar := Color(0.6, 0.9, 0.6)
var _t_tembak := 1.2
var _jeda_tembak := 2.0

var _rig: Node2D = null
var _rig_k := 1.0
var _parts := 0
var _face := 1.0

const BASE_TINGGI := 84.0

func setup(player: Node2D, spd: float, life: int, sc: int, rad: float) -> void:
	_player = player
	speed = spd
	hp = life
	skor = sc
	radius = rad

func _ready() -> void:
	add_to_group("musuh")
	if bos:
		add_to_group("bos")
	else:
		_roll_tipe()
	_terapkan_varian()
	nyawa_maks = hp
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = radius
	cs.shape = c
	add_child(cs)
	_bangun_rig()

func _roll_tipe() -> void:
	var W = get_node_or_null("/root/Waktu")
	var detik := 0.0
	if W != null:
		detik = W.detik
	var menit := detik / 60.0
	var peluang: float = clampf(0.12 + menit * 0.05, 0.0, 1.0)
	if randf() < peluang:
		tipe = randi_range(1, 4)
	else:
		tipe = 0

func _terapkan_varian() -> void:
	var tint := Color(0.6, 0.9, 0.6)
	var skala := 1.0
	match tipe:
		1:
			speed *= 1.6
			skala = 0.8
			tint = Color(0.4, 0.95, 0.95)
		2:
			speed *= 0.6
			hp = hp * 3 + 2
			skor += 15
			xp += 1
			skala = 1.4
			tint = Color(0.8, 0.6, 1.0)
		3:
			skala = 1.1
			skor += 5
			tint = Color(1.0, 0.6, 0.35)
		4:
			speed *= 0.85
			skor += 10
			tint = Color(1.0, 0.88, 0.4)
	if bos:
		tint = Color(1.0, 0.45, 0.45)
		skala = 3.0
	_warna_dasar = tint
	scale = Vector2(skala, skala)

func _karakter_untuk_tipe() -> int:
	if bos:
		return 5   # Bajak Laut
	match tipe:
		1:
			return 0   # Pemanah - Cepat
		2:
			return 6   # Tentara - Tank
		3:
			return 2   # Badut - Peledak
		4:
			return 8   # Penyihir - Penembak
		_:
			return 7   # Kesatria - Biasa

func _bangun_rig() -> void:
	var K = get_node_or_null("/root/Karakter")
	if K == null:
		return
	var idx := _karakter_untuk_tipe()
	_rig = Node2D.new()
	add_child(_rig)
	var body: Texture2D = K.tekstur(idx, "Body")
	var head: Texture2D = K.tekstur(idx, "Head")
	var lfoot: Texture2D = K.tekstur(idx, "Left_Foot")
	var rfoot: Texture2D = K.tekstur(idx, "Right_Foot")
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
	_tambah(body, Vector2.ZERO)
	_tambah(head, Vector2(0.0, -bh * 0.5 - hh * 0.2))
	if _parts == 0:
		_rig.queue_free()
		_rig = null
		return
	var total_h := bh + hh * 0.7
	if total_h < 1.0:
		total_h = 1.0
	_rig_k = BASE_TINGGI / total_h
	_rig.scale = Vector2(_rig_k, _rig_k)
	_rig.modulate = _warna_dasar

func _tambah(tex: Texture2D, pos: Vector2) -> void:
	if tex == null:
		return
	_parts += 1
	var s := Sprite2D.new()
	s.texture = tex
	s.position = pos
	s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_rig.add_child(s)

func _physics_process(delta: float) -> void:
	if _dead:
		return
	if _player == null or not is_instance_valid(_player):
		return
	var dir := _player.global_position - global_position
	if dir.length() > 2.0:
		global_position += dir.normalized() * speed * delta
	if _flash > 0.0:
		_flash -= delta
	if _rig != null:
		if dir.x < -0.5:
			_face = -1.0
		elif dir.x > 0.5:
			_face = 1.0
		_rig.scale = Vector2(_face * _rig_k, _rig_k)
		if _flash > 0.0:
			_rig.modulate = Color(1.0, 0.4, 0.4)
		else:
			_rig.modulate = _warna_dasar
	else:
		queue_redraw()
	if tipe == 4:
		_t_tembak -= delta
		if _t_tembak <= 0.0:
			var jarak := global_position.distance_to(_player.global_position)
			if jarak <= 800.0:
				var arah := (_player.global_position - global_position).normalized()
				var main = get_tree().get_first_node_in_group("main")
				if main != null:
					var pm = load("res://scripts/PeluruMusuh.gd").new()
					pm.setup(arah, 450.0, 7.0)
					main.add_child(pm)
					pm.global_position = global_position
				_t_tembak = _jeda_tembak
			else:
				_t_tembak = 0.3

func _draw() -> void:
	if _rig != null:
		return
	var col := Color(1.0, 0.3, 0.3) if _flash > 0.0 else _warna_dasar
	draw_circle(Vector2.ZERO, radius, col)
	draw_circle(Vector2(-radius * 0.3, -radius * 0.15), radius * 0.16, Color.BLACK)
	draw_circle(Vector2(radius * 0.3, -radius * 0.15), radius * 0.16, Color.BLACK)

func kena(dmg: int) -> void:
	if _dead:
		return
	hp -= maxi(1, dmg)
	_flash = 0.08
	if hp <= 0:
		mati()
	else:
		var snd = get_node_or_null("/root/Sound")
		if snd != null:
			snd.musuh_kena()

func mati() -> void:
	if _dead:
		return
	_dead = true
	var snd = get_node_or_null("/root/Sound")
	if snd != null:
		snd.musuh_mati()
	var pos := global_position
	var main = get_tree().get_first_node_in_group("main")
	if main == null:
		queue_free()
		return
	var he = load("res://scripts/HitEffect.gd").new()
	main.add_child(he)
	he.global_position = pos
	if main.has_method("tambah_skor"):
		main.tambah_skor(skor)
	var g = load("res://scripts/XpGem.gd").new()
	g.nilai = xp
	main.add_child(g)
	g.global_position = pos
	if tipe == 3:
		var led = load("res://scripts/Ledakan.gd").new()
		led.radius = 190.0
		led.dmg_musuh = 0
		led.dmg_pemain = 16.0
		led.warna = Color(1.0, 0.6, 0.2, 0.85)
		main.add_child(led)
		led.global_position = pos
	if bos:
		for i in 6:
			var gg = load("res://scripts/XpGem.gd").new()
			gg.nilai = 5
			main.add_child(gg)
			gg.global_position = pos + Vector2(randf_range(-120.0, 120.0), randf_range(-120.0, 120.0))
		var it = load("res://scripts/ItemLapangan.gd").new()
		it.setup(2)
		main.add_child(it)
		it.global_position = pos
	else:
		var roll := randf()
		if roll < 0.02:
			var itb = load("res://scripts/ItemLapangan.gd").new()
			itb.setup(0)
			main.add_child(itb)
			itb.global_position = pos
		elif roll < 0.05:
			var itm = load("res://scripts/ItemLapangan.gd").new()
			itm.setup(1)
			main.add_child(itm)
			itm.global_position = pos
	queue_free()
