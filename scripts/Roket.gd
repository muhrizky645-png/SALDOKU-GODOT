extends Node2D
# Port dari Roket.cs - roket pelacak, meledak (Ledakan area) saat dekat musuh / habis umur.

var _target: Node2D = null
var speed := 800.0
var dmg := 8
var radius := 180.0
var _umur := 4.0
var _arah := Vector2.RIGHT

func setup(target: Node2D, spd: float, d: int, rad: float) -> void:
	_target = target
	speed = spd
	dmg = d
	radius = rad

func _ready() -> void:
	z_index = 45
	if _target != null and is_instance_valid(_target):
		_arah = (_target.global_position - global_position).normalized()
	var body := Polygon2D.new()
	body.polygon = PackedVector2Array([Vector2(-8, 12), Vector2(8, 12), Vector2(8, -10), Vector2(0, -22), Vector2(-8, -10)])
	body.color = Color(0.9, 0.92, 0.96)
	add_child(body)
	var nose := Polygon2D.new()
	nose.polygon = PackedVector2Array([Vector2(-8, -10), Vector2(0, -22), Vector2(8, -10)])
	nose.color = Color(0.86, 0.2, 0.16)
	add_child(nose)

func _process(delta: float) -> void:
	_umur -= delta
	if _umur <= 0.0:
		_meledak()
		return
	if _target == null or not is_instance_valid(_target):
		_target = _musuh_terdekat()
	if _target != null and is_instance_valid(_target):
		var mau := (_target.global_position - global_position).normalized()
		_arah = _arah.lerp(mau, clampf(6.0 * delta, 0.0, 1.0)).normalized()
	global_position += _arah * speed * delta
	rotation = _arah.angle() + PI / 2.0
	for m in get_tree().get_nodes_in_group("musuh"):
		if not is_instance_valid(m):
			continue
		var mm := m as Node2D
		if mm == null:
			continue
		if global_position.distance_to(mm.global_position) <= 50.0:
			_meledak()
			return

func _meledak() -> void:
	var main = get_tree().get_first_node_in_group("main")
	if main != null:
		var led = load("res://scripts/Ledakan.gd").new()
		led.radius = radius
		led.dmg_musuh = dmg
		led.dmg_pemain = 0.0
		led.warna = Color(1.0, 0.6, 0.2, 0.85)
		main.add_child(led)
		led.global_position = global_position
	queue_free()

func _musuh_terdekat() -> Node2D:
	var t: Node2D = null
	var min_d := INF
	for m in get_tree().get_nodes_in_group("musuh"):
		if not is_instance_valid(m):
			continue
		var mm := m as Node2D
		if mm == null:
			continue
		var d := global_position.distance_to(mm.global_position)
		if d < min_d:
			min_d = d
			t = mm
	return t
