extends Node
# Autoload "Skill" - port dari SkillManager.cs.
# Tawarkan 3 kartu skill acak tiap naik level, game pause saat memilih.
# Tampilan kartu dibuat SAMA dengan Unity (OnGUI): 3 kartu persegi berjejar,
# strip aksen army di atas, ikon di tengah-atas, keterangan level (amber),
# nama (army) + deskripsi (tulang), efek hover, font pixel Thaleah.

const W := 1080.0
const H := 1920.0

const C_OVERLAY := Color(0.02, 0.03, 0.02, 0.86)
const C_PANEL := Color(0.11, 0.12, 0.09, 0.96)
const C_PANEL_TERANG := Color(0.19, 0.21, 0.15, 0.98)
const C_GARIS := Color(0.52, 0.60, 0.28, 1.0)
const C_ARMY := Color(0.66, 0.85, 0.38, 1.0)
const C_AMBER := Color(1.0, 0.80, 0.22, 1.0)
const C_DARAH := Color(0.82, 0.17, 0.13, 1.0)
const C_TULANG := Color(0.95, 0.94, 0.87, 1.0)

var magnet_mult := 1.0
var aktif_memilih := false

var _level_terakhir := 1
var _tingkat := {}
var _semua := []
var _layer: CanvasLayer = null
var _font: Font = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var tf = get_node_or_null("/root/Tema")
	if tf != null and tf.has_method("font_utama"):
		_font = tf.font_utama()
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

func _klabel(parent: Node, x: float, y: float, w: float, h: float, sz: int, warna: Color, teks: String, tengah_v: bool, wrap: bool) -> Label:
	var l := Label.new()
	l.text = teks
	l.position = Vector2(x, y)
	l.size = Vector2(w, h)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER if tengah_v else VERTICAL_ALIGNMENT_TOP
	if wrap:
		l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", sz)
	l.add_theme_color_override("font_color", warna)
	l.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	l.add_theme_constant_override("shadow_offset_x", 2)
	l.add_theme_constant_override("shadow_offset_y", 2)
	if _font != null:
		l.add_theme_font_override("font", _font)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l

func _panel9(bg: Color, border: Color, tebal: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(tebal)
	sb.set_corner_radius_all(0)
	return sb

func _tampilkan(pilihan: Array) -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)

	var bg := ColorRect.new()
	bg.color = C_OVERLAY
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	_layer.add_child(bg)

	# ukuran kartu (ikut Unity): 3 kartu persegi berjejar di tengah
	var margin := W * 0.05
	var gap := W * 0.03
	var total_w := W - margin * 2.0
	var card_w := (total_w - gap * 2.0) / 3.0
	var card_h := card_w * 1.32
	var cy := (H - card_h) / 2.0

	# header LEVEL UP! + PILIH SKILL
	var f_big := int(round(H * 0.055))
	var f_sub := int(round(H * 0.032))
	var head_y := cy - H * 0.22
	_klabel(_layer, 0.0, head_y, W, float(f_big) * 1.4, f_big, C_DARAH, "LEVEL UP!", true, false)
	_klabel(_layer, 0.0, head_y + float(f_big) * 1.25, W, float(f_sub) * 1.6, f_sub, C_ARMY, "PILIH SKILL", true, false)

	var f_nama := int(round(card_w * 0.11))
	var f_desk := int(round(card_w * 0.088))
	var f_level := int(round(card_w * 0.095))
	var tebal: int = maxi(2, int(round(card_w * 0.02)))
	var ikon = get_node_or_null("/root/Ikon")

	for i in pilihan.size():
		var s = pilihan[i]
		var cx := margin + float(i) * (card_w + gap)

		var btn := Button.new()
		btn.position = Vector2(cx, cy)
		btn.size = Vector2(card_w, card_h)
		btn.text = ""
		btn.clip_contents = true
		btn.add_theme_stylebox_override("normal", _panel9(C_PANEL, C_GARIS, tebal))
		btn.add_theme_stylebox_override("hover", _panel9(C_PANEL_TERANG, C_ARMY, tebal))
		btn.add_theme_stylebox_override("pressed", _panel9(C_PANEL_TERANG, C_ARMY, tebal))
		btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		_layer.add_child(btn)

		# strip aksen di atas
		var strip := ColorRect.new()
		strip.color = C_ARMY
		strip.position = Vector2(0.0, 0.0)
		strip.size = Vector2(card_w, card_h * 0.045)
		strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(strip)

		# ikon skill (dibuat lewat kode di Ikon.gd)
		var isz := card_h * 0.26
		if ikon != null:
			var tex = ikon.untuk_skill(s["id"])
			if tex != null:
				var ic := TextureRect.new()
				ic.texture = tex
				ic.position = Vector2((card_w - isz) / 2.0, card_h * 0.07)
				ic.size = Vector2(isz, isz)
				ic.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				ic.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				ic.modulate = C_ARMY
				ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
				btn.add_child(ic)

		# keterangan level skill
		var cur: int = int(_tingkat.get(s["nama"], 0))
		var tk := ""
		if s["maks"] > 0 and cur >= s["maks"]:
			tk = "Lv MAKS (%d)" % s["maks"]
		elif cur == 0:
			tk = "BARU  >  Lv 1"
		else:
			tk = "Lv %d  >  %d" % [cur, cur + 1]
		_klabel(btn, 4.0, card_h * 0.35, card_w - 8.0, card_h * 0.09, f_level, C_AMBER, tk, true, false)
		_klabel(btn, 6.0, card_h * 0.45, card_w - 12.0, card_h * 0.22, f_nama, C_ARMY, s["nama"], true, true)
		_klabel(btn, 6.0, card_h * 0.68, card_w - 12.0, card_h * 0.30, f_desk, C_TULANG, s["deskripsi"], true, true)

		btn.pressed.connect(_pilih.bind(s))

func _pilih(s: Dictionary) -> void:
	_terapkan(s["id"])
	var cur: int = int(_tingkat.get(s["nama"], 0))
	var baru: int = cur + 1
	if s["maks"] > 0:
		baru = mini(baru, s["maks"])
	_tingkat[s["nama"]] = baru
	var snd = get_node_or_null("/root/Sound")
	if snd != null and snd.has_method("level_up"):
		snd.level_up()
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
