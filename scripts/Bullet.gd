extends Area2D
# Port dari Bullet.cs - shuriken lurus + berputar.

var speed := 650.0
var direction := Vector2.RIGHT
var life := 3.0
var putaran := deg_to_rad(720.0)
var damage := 1

func setup(tex: Texture2D, dir: Vector2) -> void:
	direction = dir
	var cs := CollisionShape2D.new()
	var c := CircleShape2D.new()
	c.radius = 12.0
	cs.shape = c
	add_child(cs)
	if tex != null:
		var s := Sprite2D.new()
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(0.5, 0.5)
		add_child(s)
	else:
		var p := Polygon2D.new()
		p.polygon = PackedVector2Array([Vector2(-8, -8), Vector2(8, -8), Vector2(8, 8), Vector2(-8, 8)])
		p.color = Color(1, 0.95, 0.4)
		add_child(p)

func _ready() -> void:
	add_to_group("peluru")
	area_entered.connect(_on_hit)
	get_tree().create_timer(life).timeout.connect(queue_free)

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	rotation += putaran * delta

func _on_hit(a: Area2D) -> void:
	if a.is_in_group("musuh"):
		if a.has_method("kena"):
			a.kena(damage)
		queue_free()
