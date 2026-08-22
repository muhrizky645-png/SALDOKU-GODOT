extends Node2D
# Port dari Ledakan.cs - ledakan area: damage sekali ke musuh/pemain dalam radius,
# lalu lingkaran membesar & memudar. Semua lewat kode.

var radius := 180.0
var dmg_musuh := 0
var dmg_pemain := 0.0
var warna := Color(1.0, 0.6, 0.2, 0.85)
var _t := 0.0
var _durasi := 0.35

func _ready() -> void:
	z_index = 55
	if dmg_musuh > 0:
		for m in get_tree().get_nodes_in_group("musuh"):
			if not is_instance_valid(m):
				continue
			var mm := m as Node2D
			if mm == null:
				continue
			if global_position.distance_to(mm.global_position) <= radius:
				if m.has_method("kena"):
					m.kena(dmg_musuh)
	if dmg_pemain > 0.0:
		var dw = get_node_or_null("/root/Dewa")
		var kebal: bool = dw != null and dw.aktif
		if not kebal:
			var p = get_tree().get_first_node_in_group("player")
			if p != null and is_instance_valid(p):
				var pm := p as Node2D
				if pm != null and global_position.distance_to(pm.global_position) <= radius:
					p.hp -= dmg_pemain

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= _durasi:
		queue_free()

func _draw() -> void:
	var p := clampf(_t / _durasi, 0.0, 1.0)
	var r := lerpf(radius * 0.4, radius, p)
	var a := lerpf(warna.a, 0.0, p)
	draw_circle(Vector2.ZERO, r, Color(warna.r, warna.g, warna.b, a))
