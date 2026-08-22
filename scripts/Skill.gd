extends Node
# Autoload "Skill" - port dari SkillManager.cs.
# Tawarkan 3 kartu skill acak tiap naik level, game pause saat memilih.

var magnet_mult := 1.0
var aktif_memilih := false

var _level_terakhir := 1
var _tingkat := {}
var _semua := []
var _layer: CanvasLayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_buat_daftar()

func reset() -> void:
	magnet_mult = 1.0
	aktif_memilih = false
	_level_terakhir = 1
	_tingkat = {}
	if _layer != null:
		_layer.queue_free()
		_layer = null
	get_tree().paused = false

func _buat_daftar() -> void:
	_semua = [
		{"id": "cepat_tembak", "nama": "Serang Lebih Cepat", "deskripsi": "Kecepatan tembak +20%", "maks": 0},
		{"id": "tambah_peluru", "nama": "Peluru Tambahan", "deskripsi": "+1 peluru tiap tembak", "maks": 0},
		{"id": "jangkauan", "nama": "Jangkauan Lebih Jauh", "deskripsi": "Jarak tembak +25%", "maks": 0},
		{"id": "kaki_cepat", "nama": "Kaki Lebih Cepat", "deskripsi": "Kecepatan lari +15%", "maks": 0},
		{"id": "badan_kuat", "nama": "Badan Lebih Kuat", "deskripsi": "Max HP +30 & pulih", "maks": 0},
		{"id": "magnet", "nama": "Magnet Permata", "deskripsi": "Jarak tarik permata +40%", "maks": 0},
		{"id": "orbit", "nama": "Pisau Berputar", "deskripsi": "Bilah berputar. Lv5: evolusi!", "maks": 6},
		{"id": "aura", "nama": "Aura Setrum", "deskripsi": "Medan setrum sekitar. Lv5: evolusi!", "maks": 6},
		{"id": "roket", "nama": "Roket Pelacak", "deskripsi": "Roket = levelnya! Lv5: evolusi", "maks": 6},
	]

func _process(_delta: float) -> void:
	if aktif_memilih:
		return
	var L = get_node_or_null("/root/Level")
	if L == null:
		return
	var lv: int = L.level
	if lv > _level_terakhir:
		_level_terakhir = lv
		_mulai_pilih()

func _mulai_pilih() -> void:
	var kolam := _semua.duplicate()
	kolam.shuffle()
	var pilihan := []
	for i in mini(3, kolam.size()):
		pilihan.append(kolam[i])
	aktif_memilih = true
	get_tree().paused = true
	_tampilkan(pilihan)

func _tampilkan(pilihan: Array) -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.72)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_layer.add_child(bg)
	var judul := Label.new()
	judul.text = "LEVEL UP!\nPILIH SKILL"
	judul.add_theme_font_size_override("font_size", 60)
	judul.add_theme_color_override("font_color", Color(1, 0.4, 0.35))
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.anchor_left = 0.0
	judul.anchor_right = 1.0
	judul.offset_top = 420.0
	judul.offset_bottom = 620.0
	_layer.add_child(judul)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 40)
	vb.anchor_left = 0.5
	vb.anchor_right = 0.5
	vb.anchor_top = 0.5
	vb.anchor_bottom = 0.5
	vb.offset_left = -420.0
	vb.offset_right = 420.0
	vb.offset_top = -280.0
	vb.offset_bottom = 280.0
	_layer.add_child(vb)
	for s in pilihan:
		var btn := Button.new()
		var cur: int = int(_tingkat.get(s["nama"], 0))
		var tk := ""
		if s["maks"] > 0 and cur >= s["maks"]:
			tk = "Lv MAKS"
		elif cur == 0:
			tk = "BARU"
		else:
			tk = "Lv %d > %d" % [cur, cur + 1]
		btn.text = "%s  [%s]\n%s" % [s["nama"], tk, s["deskripsi"]]
		btn.add_theme_font_size_override("font_size", 32)
		btn.custom_minimum_size = Vector2(840, 150)
		btn.pressed.connect(_pilih.bind(s))
		vb.add_child(btn)

func _pilih(s: Dictionary) -> void:
	_terapkan(s["id"])
	var cur: int = int(_tingkat.get(s["nama"], 0))
	var baru: int = cur + 1
	if s["maks"] > 0:
		baru = mini(baru, s["maks"])
	_tingkat[s["nama"]] = baru
	aktif_memilih = false
	get_tree().paused = false
	if _layer != null:
		_layer.queue_free()
		_layer = null

func _terapkan(id: String) -> void:
	var p = get_tree().get_first_node_in_group("player")
	var Sen = get_node_or_null("/root/Senjata")
	match id:
		"cepat_tembak":
			if p != null: p.fire_rate *= 0.80
		"tambah_peluru":
			if p != null: p.jumlah_peluru += 1
		"jangkauan":
			if p != null: p.range_tembak *= 1.25
		"kaki_cepat":
			if p != null: p.speed *= 1.15
		"badan_kuat":
			if p != null:
				p.hp_maks += 30.0
				p.hp = minf(p.hp + 30.0, p.hp_maks)
		"magnet":
			magnet_mult *= 1.4
		"orbit":
			if Sen != null: Sen.tambah_orbit()
		"aura":
			if Sen != null: Sen.tambah_aura()
		"roket":
			if Sen != null: Sen.tambah_roket()
