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
# Taruh file TTF di salah satu path ini; kalau tidak ada, pakai font bawaan Godot.
var _font: Font = null
var _font_dicari := false

func font_utama() -> Font:
	if not _font_dicari:
		_font_dicari = true
		for p in ["res://Assets/fonts/ThaleahFat.ttf", "res://Assets/fonts/ThaleahPixel.ttf", "res://assets/fonts/ThaleahFat.ttf", "res://fonts/ThaleahFat.ttf", "res://ThaleahFat.ttf"]:
			if ResourceLoader.exists(p):
				var r = load(p)
				if r is Font:
					_font = r
					break
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
