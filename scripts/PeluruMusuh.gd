extends Node2D
# Port dari PeluruMusuh.cs - bola api yang ditembakkan musuh Penembak ke pemain.

var arah := Vector2.RIGHT
var speed := 450.0
var dmg := 7.0
var _umur := 4.0
var _t := 0.0
var _player: Node2D = null

func setup(a: Vector2, spd: float, d: float) -> void:
	arah = a.normalized()
	speed = spd
	dmg = d

func _ready() -> void:
	z_index = 45
	_player = get_tree().get_first_node_in_group("player") as Node2D

func _process(delta: float) -> void:
	_umur -= delta
	if _umur <= 0.0:
		queue_free()
		return
	global_position += arah * speed * delta
	_t += delta
	queue_redraw()
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return
	if global_position.distance_to(_player.global_position) <= 45.0:
		var dw = get_node_or_null("/root/Dewa")
		var kebal: bool = dw != null and dw.aktif
		if not kebal:
			_player.hp -= dmg
		queue_free()

func _draw() -> void:
	var k := 1.0 + 0.12 * sin(_t * 18.0)
	var r := 15.0 * k
	draw_circle(Vector2.ZERO, r * 1.3, Color(0.75, 0.12, 0.05, 0.3))
	draw_circle(Vector2.ZERO, r, Color(0.75, 0.12, 0.05, 1.0))
	draw_circle(Vector2.ZERO, r * 0.62, Color(1.0, 0.55, 0.16, 1.0))
	draw_circle(Vector2.ZERO, r * 0.3, Color(1.0, 0.96, 0.70, 1.0))
