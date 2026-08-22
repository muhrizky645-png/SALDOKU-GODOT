extends Node2D
# Port dari XpGem.cs - permata XP jatuh saat musuh mati, ketarik ke pemain.
# Jarak magnet dipengaruhi skill Magnet + Mode Dewa (magnet semesta).

var nilai := 1
var ukuran := 1.2
var jarak_magnet := 220.0
var jarak_ambil := 46.0
var kecepatan_tarik := 520.0

var _player: Node2D = null
var _t := 0.0
var _kilau := 1.0

func _ready() -> void:
	add_to_group("xp")
	scale = Vector2(ukuran, ukuran)
	z_index = 40
	_player = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	_t += delta
	_kilau = 0.75 + 0.25 * sin(_t * 6.0)
	queue_redraw()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	var d := global_position.distance_to(_player.global_position)
	if d <= jarak_ambil:
		var L = get_node_or_null("/root/Level")
		if L != null:
			L.tambah_xp(nilai)
		queue_free()
		return
	var jm := jarak_magnet
	var kt := kecepatan_tarik
	var Sk = get_node_or_null("/root/Skill")
	if Sk != null:
		jm *= Sk.magnet_mult
	var dw = get_node_or_null("/root/Dewa")
	if dw != null and dw.aktif:
		jm = 99999.0
		kt = maxf(kt, 1400.0)
	if d <= jm:
		global_position = global_position.move_toward(_player.global_position, kt * delta)

func _draw() -> void:
	var c := Color(0.4 * _kilau, 1.0 * _kilau, 1.0, 1.0)
	var r := 16.0
	var pts := PackedVector2Array([Vector2(0, -r), Vector2(r, 0), Vector2(0, r), Vector2(-r, 0)])
	draw_colored_polygon(pts, c)
