extends Node2D
# Port dari ItemLapangan.cs - item jatuh di lapangan, dipungut saat disentuh.
# Bom: bunuh semua musuh + kilat. Magnet: tarik semua permata XP. Peti: XP besar (naik level).

enum Jenis { BOM, MAGNET, PETI }
var jenis := Jenis.BOM

var _player: Node2D = null
var _t := 0.0
var jarak_ambil := 60.0
var jarak_magnet := 220.0
var kecepatan := 800.0
var _ukuran := 0.9
var _warna := Color(1.0, 0.5, 0.3)

func setup(j: int) -> void:
	jenis = j

func _ready() -> void:
	add_to_group("item")
	z_index = 42
	_player = get_tree().get_first_node_in_group("player") as Node2D
	match jenis:
		Jenis.BOM:
			_warna = Color(1.0, 0.5, 0.3)
			_ukuran = 1.0
		Jenis.MAGNET:
			_warna = Color(0.5, 0.8, 1.0)
			_ukuran = 0.9
		_:
			_warna = Color(1.0, 0.82, 0.3)
			_ukuran = 1.1

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	var d := global_position.distance_to(_player.global_position)
	if d <= jarak_ambil:
		_efek()
		queue_free()
		return
	if d <= jarak_magnet:
		global_position = global_position.move_toward(_player.global_position, kecepatan * delta)

func _efek() -> void:
	var main = get_tree().get_first_node_in_group("main")
	match jenis:
		Jenis.BOM:
			for m in get_tree().get_nodes_in_group("musuh"):
				if is_instance_valid(m) and m.has_method("kena"):
					m.kena(9999)
			if main != null and _player != null:
				var led = load("res://scripts/Ledakan.gd").new()
				led.radius = 600.0
				led.dmg_musuh = 0
				led.dmg_pemain = 0.0
				led.warna = Color(1.0, 0.85, 0.35, 0.7)
				main.add_child(led)
				led.global_position = _player.global_position
		Jenis.MAGNET:
			for g in get_tree().get_nodes_in_group("xp"):
				if is_instance_valid(g) and g.has_method("paksa_tarik"):
					g.paksa_tarik()
		Jenis.PETI:
			var L = get_node_or_null("/root/Level")
			if L != null:
				L.tambah_xp(maxi(5, L.xp_untuk_naik))

func _draw() -> void:
	var denyut := 1.0 + 0.1 * sin(_t * 5.0)
	var s := _ukuran * denyut
	match jenis:
		Jenis.BOM:
			draw_circle(Vector2.ZERO, 26.0 * s, Color(0.15, 0.15, 0.18))
			draw_circle(Vector2(-8.0 * s, -8.0 * s), 7.0 * s, Color(0.55, 0.55, 0.6, 0.7))
			draw_line(Vector2(6.0 * s, -24.0 * s), Vector2(16.0 * s, -40.0 * s), Color(0.8, 0.6, 0.3), 4.0)
			draw_circle(Vector2(18.0 * s, -42.0 * s), 6.0 * s, Color(1.0, 0.6, 0.2))
		Jenis.MAGNET:
			draw_arc(Vector2.ZERO, 22.0 * s, PI, TAU, 20, _warna, 12.0 * s)
			draw_line(Vector2(-22.0 * s, 0.0), Vector2(-22.0 * s, 20.0 * s), Color(0.9, 0.2, 0.2), 12.0 * s)
			draw_line(Vector2(22.0 * s, 0.0), Vector2(22.0 * s, 20.0 * s), Color(0.9, 0.2, 0.2), 12.0 * s)
		_:
			var w := 30.0 * s
			var h := 24.0 * s
			draw_rect(Rect2(-w, -h, w * 2.0, h * 2.0), Color(0.55, 0.35, 0.16))
			draw_rect(Rect2(-w, -h * 0.25, w * 2.0, h * 0.5), Color(1.0, 0.82, 0.3))
			draw_circle(Vector2.ZERO, 5.0 * s, Color(0.3, 0.2, 0.1))
