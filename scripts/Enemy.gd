extends Area2D
# Port ringkas dari EnemyChase.cs (Fase 1).

var speed := 120.0
var hp := 1
var skor := 10
var radius := 30.0

var _player: Node2D = null
var _dead := false
var _flash := 0.0

func setup(player: Node2D, spd: float, life: int, sc: int, rad: float) -> void:
	_player = player
	speed = spd
	hp = life
	skor = sc
	radius = rad

func _ready() -> void:
	add_to_group("musuh")
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = radius
	cs.shape = c
	add_child(cs)

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
	queue_redraw()

func _draw() -> void:
	var col := Color(1, 0.3, 0.3) if _flash > 0.0 else Color(0.45, 0.75, 0.4)
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

func mati() -> void:
	if _dead:
		return
	_dead = true
	var main = get_tree().get_first_node_in_group("main")
	if main != null and main.has_method("tambah_skor"):
		main.tambah_skor(skor)
	queue_free()
