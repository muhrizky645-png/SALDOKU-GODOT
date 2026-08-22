extends Node2D
# Port dari PisauOrbit.cs - bilah berputar melukai musuh (jeda per musuh).

var dmg := 2
var jarak_kena := 50.0
var jeda_per_musuh := 0.4

var _kena_terakhir := {}

func _ready() -> void:
	z_index = 44
	var K = get_node_or_null("/root/Karakter")
	var tex: Texture2D = null
	if K != null:
		tex = K.tekstur(K.dipilih, "Weapon")
	if tex != null:
		var s := Sprite2D.new()
		s.texture = tex
		s.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		s.scale = Vector2(1.6, 1.6)
		add_child(s)
	else:
		var p := Polygon2D.new()
		var pts := PackedVector2Array()
		for i in 8:
			var a := TAU * float(i) / 8.0
			var rr: float = 22.0 if i % 2 == 0 else 10.0
			pts.append(Vector2(cos(a), sin(a)) * rr)
		p.polygon = pts
		p.color = Color(0.85, 0.95, 1.0)
		add_child(p)

func _process(delta: float) -> void:
	rotation += TAU * delta
	var now := float(Time.get_ticks_msec()) / 1000.0
	for m in get_tree().get_nodes_in_group("musuh"):
		if not is_instance_valid(m):
			continue
		var mm := m as Node2D
		if mm == null:
			continue
		if global_position.distance_to(mm.global_position) > jarak_kena:
			continue
		var id := mm.get_instance_id()
		var last := float(_kena_terakhir.get(id, -999.0))
		if now - last < jeda_per_musuh:
			continue
		_kena_terakhir[id] = now
		if m.has_method("kena"):
			m.kena(dmg)
