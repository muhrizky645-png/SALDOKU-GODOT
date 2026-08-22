extends Node
# Autoload "Senjata" - port dari SenjataManager.cs.
# Orbit (pisau berputar), Aura (medan setrum), Roket pelacak. Evolusi di Lv5+.
# Skala: 1 unit Unity ~= 100 px.

const MAKS := 6

var lv_orbit := 0
var lv_aura := 0
var lv_roket := 0

var _player: Node2D = null
var _bilah: Array = []
var _sudut_orbit := 0.0
var _aura_visual: Node2D = null
var _aura_timer := 0.0
var _roket_timer := 0.0

func reset() -> void:
	lv_orbit = 0
	lv_aura = 0
	lv_roket = 0
	for b in _bilah:
		if is_instance_valid(b):
			b.queue_free()
	_bilah = []
	_sudut_orbit = 0.0
	_aura_timer = 0.0
	_roket_timer = 0.0
	if is_instance_valid(_aura_visual):
		_aura_visual.queue_free()
	_aura_visual = null
	_player = null

func _player_node() -> Node2D:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	return _player

func tambah_orbit() -> void:
	lv_orbit = mini(MAKS, lv_orbit + 1)
	_bangun_orbit()

func tambah_aura() -> void:
	lv_aura = mini(MAKS, lv_aura + 1)
	_bangun_aura()

func tambah_roket() -> void:
	lv_roket = mini(MAKS, lv_roket + 1)

func _bangun_orbit() -> void:
	for b in _bilah:
		if is_instance_valid(b):
			b.queue_free()
	_bilah = []
	var evo := lv_orbit >= 5
	var jumlah: int = lv_orbit + 1 + (2 if evo else 0)
	var dmg: int = 3 + lv_orbit * 2 + (5 if evo else 0)
	for i in jumlah:
		var po = load("res://scripts/PisauOrbit.gd").new()
		po.dmg = dmg
		add_child(po)
		_bilah.append(po)

func _bangun_aura() -> void:
	if not is_instance_valid(_aura_visual):
		var poly := Polygon2D.new()
		var pts := PackedVector2Array()
		for i in 32:
			var a := TAU * float(i) / 32.0
			pts.append(Vector2(cos(a), sin(a)))
		poly.polygon = pts
		poly.color = Color(0.4, 0.8, 1.0, 0.16)
		poly.z_index = 5
		add_child(poly)
		_aura_visual = poly

func _process(delta: float) -> void:
	var pl := _player_node()
	if pl == null:
		return
	if _bilah.size() > 0:
		var evo := lv_orbit >= 5
		var radius: float = 210.0 if evo else 160.0
		var kecepatan := deg_to_rad(200.0 if evo else 140.0)
		_sudut_orbit += kecepatan * delta
		var n := _bilah.size()
		for i in n:
			var b = _bilah[i]
			if not is_instance_valid(b):
				continue
			var a := _sudut_orbit + float(i) * (TAU / float(n))
			b.global_position = pl.global_position + Vector2(cos(a), sin(a)) * radius
	if lv_aura > 0 and is_instance_valid(_aura_visual):
		var evo2 := lv_aura >= 5
		var radius2: float = ((2.6 if evo2 else 1.8) + lv_aura * 0.18) * 100.0
		var dmg2: int = 2 + lv_aura * 2 + (5 if evo2 else 0)
		_aura_visual.global_position = pl.global_position
		_aura_visual.scale = Vector2(radius2, radius2)
		_aura_timer += delta
		if _aura_timer >= 0.4:
			_aura_timer = 0.0
			for m in get_tree().get_nodes_in_group("musuh"):
				if not is_instance_valid(m):
					continue
				var mm := m as Node2D
				if mm == null:
					continue
				if pl.global_position.distance_to(mm.global_position) <= radius2:
					if m.has_method("kena"):
						m.kena(dmg2)
	if lv_roket > 0:
		var evo3 := lv_roket >= 5
		var jeda: float = maxf(0.7, 2.0 - lv_roket * 0.2)
		var dmg3: int = 8 + lv_roket * 3 + (8 if evo3 else 0)
		var radius3: float = (2.4 if evo3 else 1.8) * 100.0
		var jumlah_roket: int = lv_roket + (2 if evo3 else 0)
		_roket_timer += delta
		if _roket_timer >= jeda:
			_roket_timer = 0.0
			var ts := []
			for m in get_tree().get_nodes_in_group("musuh"):
				if is_instance_valid(m):
					ts.append(m)
			if ts.size() > 0:
				ts.sort_custom(func(a, b): return pl.global_position.distance_squared_to(a.global_position) < pl.global_position.distance_squared_to(b.global_position))
				var main = get_tree().get_first_node_in_group("main")
				if main != null:
					for i in jumlah_roket:
						var t = ts[i % ts.size()]
						var r = load("res://scripts/Roket.gd").new()
						r.setup(t, 800.0, dmg3, radius3)
						main.add_child(r)
						r.global_position = pl.global_position
