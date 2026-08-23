extends Node
# Autoload "Tema" - port palet & gaya UI dari Tema.cs (gaya militer/army pixel).

const OVERLAY := Color(0.02, 0.03, 0.02, 0.86)
const PANEL := Color(0.11, 0.12, 0.09, 0.96)
const PANEL_TERANG := Color(0.19, 0.21, 0.15, 0.98)
const PLATE := Color(0.05, 0.06, 0.04, 0.78)
const GARIS := Color(0.52, 0.60, 0.28, 1.0)
const GARIS_REDUP := Color(0.38, 0.42, 0.24, 0.9)
const DARAH := Color(0.82, 0.17, 0.13, 1.0)
const TULANG := Color(0.95, 0.94, 0.87, 1.0)
const ARMY := Color(0.66, 0.85, 0.38, 1.0)
const AMBER := Color(1.0, 0.80, 0.22, 1.0)
const REDUP := Color(0.72, 0.74, 0.64, 1.0)

# Flag lintas-reload: kalau true, Main langsung mulai main (dipakai tombol ULANGI).
var langsung_main := false

# ====== FONT PIXEL (Thaleah) ======
# Font pixel WAJIB anti-alias OFF biar tajam seperti Unity. Kita muat file TTF langsung
# jadi FontFile lewat load_dynamic_font + setel crisp, jadi TIDAK tergantung setelan
# import default Godot (yang menyalakan anti-alias -> teks jadi blur/beda).
# Taruh file di salah satu path di bawah; kalau tak ada, pakai font bawaan Godot.
var _font: Font = null
var _font_dicari := false

const _FONT_PATHS := [
	"res://Assets/fonts/ThaleahFat.ttf",
	"res://Assets/fonts/ThaleahPixel.ttf",
	"res://assets/fonts/ThaleahFat.ttf",
	"res://assets/fonts/ThaleahPixel.ttf",
	"res://fonts/ThaleahFat.ttf",
	"res://ThaleahFat.ttf",
	"res://ThaleahPixel.ttf",
]

func _crisp(ff: FontFile) -> void:
	ff.antialiasing = TextServer.FONT_ANTIALIASING_NONE
	ff.hinting = TextServer.HINTING_NONE
	ff.subpixel_positioning = TextServer.SUBPIXEL_POSITIONING_DISABLED
	ff.force_autohinter = false
	ff.multichannel_signed_distance_field = false
	ff.allow_system_fallback = false

func font_utama() -> Font:
	if _font_dicari:
		return _font
	_font_dicari = true
	# 1) Muat langsung dari file TTF (kontrol penuh setelan crisp)
	for p in _FONT_PATHS:
		if FileAccess.file_exists(p):
			var ff := FontFile.new()
			if ff.load_dynamic_font(p) == OK:
				_crisp(ff)
				_font = ff
				return _font
	# 2) Kalau sudah diimpor Godot, pakai itu tapi paksa crisp
	for p in _FONT_PATHS:
		if ResourceLoader.exists(p):
			var r = load(p)
			if r is FontFile:
				_crisp(r)
				_font = r
				return _font
			elif r is Font:
				_font = r
				return _font
	return _font

func unit() -> float:
	return 1080.0

func font(frac: float) -> int:
	return int(round(unit() * frac))

func gaya_panel(bg: Color, border: Color, tebal: int = 3, radius: int = 12) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(tebal)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 22.0
	sb.content_margin_right = 22.0
	sb.content_margin_top = 14.0
	sb.content_margin_bottom = 14.0
	return sb
