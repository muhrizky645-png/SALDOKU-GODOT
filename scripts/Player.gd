extends Node2D
# VERSI MINIMAL untuk isolasi error compile. Sementara.

var speed := 340.0
var hp := 100.0
var nama := "NINJA"
var parts_loaded := 0
var rig: Node2D = null

func _ready() -> void:
	add_to_group("player")
	rig = Node2D.new()
	add_child(rig)
	var b := Polygon2D.new()
	b.polygon = PackedVector2Array([Vector2(-30, -45), Vector2(30, -45), Vector2(30, 45), Vector2(-30, 45)])
	b.color = Color(0.3, 0.65, 1.0)
	rig.add_child(b)
	var head := Polygon2D.new()
	head.polygon = PackedVector2Array([Vector2(-20, -88), Vector2(20, -88), Vector2(20, -50), Vector2(-20, -50)])
	head.color = Color(1.0, 0.85, 0.6)
	rig.add_child(head)

func _process(delta: float) -> void:
	var dir := Vector2.ZERO
	if Input.is_key_pressed(KEY_A):
		dir.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		dir.x += 1.0
	if Input.is_key_pressed(KEY_W):
		dir.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		dir.y += 1.0
	var joy = get_tree().get_first_node_in_group("joystick")
	if joy != null:
		var d: Vector2 = joy.direction
		dir += d
	global_position += dir.limit_length(1.0) * speed * delta
