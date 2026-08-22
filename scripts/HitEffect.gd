extends Node2D
# Port dari HitEffect.cs - lingkaran kuning membesar lalu memudar saat musuh mati.

var ukuran_max := 42.0
var _t := 0.0
var _durasi := 0.25

func _ready() -> void:
	z_index = 50

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= _durasi:
		queue_free()

func _draw() -> void:
	var p := clampf(_t / _durasi, 0.0, 1.0)
	var r := lerpf(ukuran_max * 0.2, ukuran_max * 1.2, p)
	var a := lerpf(0.85, 0.0, p)
	draw_circle(Vector2.ZERO, r, Color(1.0, 0.9, 0.4, a))
