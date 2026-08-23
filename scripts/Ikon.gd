extends Node
# Port dari Ikon.cs - ikon prosedural (tanpa file gambar), dibuat lewat Image.
# Ikon grayscale (skill) diberi warna via _tint. Ikon item (bom/magnet/peti) berwarna.

var _cache := {}

const _PALET_BOM := [
	Color(0.17, 0.18, 0.22),
	Color(0.50, 0.54, 0.62),
	Color(0.55, 0.38, 0.18),
	Color(1.00, 0.75, 0.20),
]
const _PALET_PETI := [
	Color(0.58, 0.37, 0.17),
	Color(0.43, 0.26, 0.11),
	Color(0.95, 0.75, 0.22),
	Color(1.00, 0.86, 0.38),
]

# ====== primitif bantu (ruang -1..1, y ke atas) ======
func _disc(x, y, cx, cy, r) -> bool:
	var dx = x - cx
	var dy = y - cy
	return dx * dx + dy * dy <= r * r

func _kotak(x, y, x0, y0, x1, y1) -> bool:
	return x >= x0 and x <= x1 and y >= y0 and y <= y1

func _cincin(x, y, r0, r1) -> bool:
	var d = x * x + y * y
	return d >= r0 * r0 and d <= r1 * r1

func _garis(x, y, ax, ay, bx, by, w) -> bool:
	var vx = bx - ax
	var vy = by - ay
	var wx = x - ax
	var wy = y - ay
	var panjang = vx * vx + vy * vy
	var t = 0.0
	if panjang > 0.0:
		t = clampf((wx * vx + wy * vy) / panjang, 0.0, 1.0)
	var px = ax + vx * t
	var py = ay + vy * t
	var dx = x - px
	var dy = y - py
	return dx * dx + dy * dy <= w * w

# ====== bentuk grayscale ======
func _f_bintang(x, y) -> bool:
	var r = sqrt(x * x + y * y)
	var ang = atan2(y, x)
	var step = PI * 2.0 / 5.0
	var a = fposmod(ang - PI / 2.0, step)
	var tt = a / (step / 2.0)
	if tt > 1.0:
		tt = 2.0 - tt
	var radius = lerpf(0.96, 0.42, tt)
	return r <= radius

func _f_petir(x, y) -> bool:
	var w = 0.17
	return _garis(x, y, 0.15, 0.92, -0.38, 0.08, w) or _garis(x, y, -0.38, 0.08, 0.12, 0.08, w) or _garis(x, y, 0.12, 0.08, -0.18, -0.92, w)

func _f_peluru(x, y) -> bool:
	for i in range(-1, 2):
		var cx = i * 0.5
		if _kotak(x, y, cx - 0.14, -0.55, cx + 0.14, 0.35):
			return true
		if _disc(x, y, cx, 0.35, 0.14):
			return true
	return false

func _f_target(x, y) -> bool:
	return _cincin(x, y, 0.72, 0.96) or _cincin(x, y, 0.30, 0.52) or _disc(x, y, 0.0, 0.0, 0.13) or _garis(x, y, -0.98, 0.0, 0.98, 0.0, 0.05) or _garis(x, y, 0.0, -0.98, 0.0, 0.98, 0.05)

func _f_chevron(x, y) -> bool:
	var w = 0.15
	return _garis(x, y, -0.35, 0.6, 0.15, 0.0, w) or _garis(x, y, 0.15, 0.0, -0.35, -0.6, w) or _garis(x, y, 0.15, 0.6, 0.65, 0.0, w) or _garis(x, y, 0.65, 0.0, 0.15, -0.6, w)

func _f_hati(x, y) -> bool:
	var bx = x / 0.92
	var by = (y - 0.15) / 0.92
	var a = bx * bx + by * by - 1.0
	return a * a * a - bx * bx * by * by * by <= 0.0

func _f_berlian(x, y) -> bool:
	return abs(x) + abs(y) <= 0.92

func _f_tengkorak(x, y) -> bool:
	var kepala = _disc(x, y, 0.0, 0.15, 0.72)
	var rahang = _kotak(x, y, -0.35, -0.75, 0.35, 0.05)
	if not (kepala or rahang):
		return false
	if _disc(x, y, -0.28, 0.20, 0.20):
		return false
	if _disc(x, y, 0.28, 0.20, 0.20):
		return false
	if _disc(x, y, 0.0, -0.05, 0.10):
		return false
	if _kotak(x, y, -0.08, -0.75, 0.08, -0.20):
		return false
	return true

func _f_aura(x, y) -> bool:
	return _cincin(x, y, 0.78, 0.96) or _cincin(x, y, 0.40, 0.56) or _disc(x, y, 0.0, 0.0, 0.14)

func _f_roket(x, y) -> bool:
	var ax = abs(x)
	var inside = false
	var t = 0.0
	if y >= -0.48 and y <= 0.45 and ax <= 0.22:
		inside = true
	if y > 0.45 and y <= 0.92:
		t = (y - 0.45) / 0.47
		if ax <= lerpf(0.22, 0.0, t):
			inside = true
	if y >= -0.74 and y <= -0.30:
		t = (y + 0.74) / 0.44
		var outer = lerpf(0.55, 0.22, t)
		if ax >= 0.20 and ax <= outer:
			inside = true
	if y >= -0.98 and y < -0.74:
		t = (y + 0.98) / 0.24
		if ax <= lerpf(0.04, 0.15, t):
			inside = true
	if inside and _disc(x, y, 0.0, 0.12, 0.11):
		return false
	return inside

func _f_pisau(x, y) -> bool:
	var r = sqrt(x * x + y * y)
	var ang = atan2(y, x)
	var step = PI * 2.0 / 4.0
	var a = fposmod(ang, step)
	var tt = a / (step / 2.0)
	if tt > 1.0:
		tt = 2.0 - tt
	var radius = lerpf(0.98, 0.28, tt)
	if _disc(x, y, 0.0, 0.0, 0.16):
		return false
	return r <= radius

# ====== kelas berwarna ======
func _bom_kelas(x, y) -> int:
	if _disc(x, y, 0.5, 0.90, 0.14):
		return 4
	if _garis(x, y, 0.25, 0.45, 0.38, 0.72, 0.075) or _garis(x, y, 0.38, 0.72, 0.50, 0.86, 0.07):
		return 3
	if _disc(x, y, 0.0, -0.15, 0.62):
		if _disc(x, y, -0.22, 0.08, 0.16):
			return 2
		return 1
	return 0

func _magnet_kelas(x, y) -> int:
	var ax = abs(x)
	if y < -0.52 and y >= -0.84 and ax >= 0.40 and ax <= 0.86:
		return 2
	if _cincin(x, y, 0.44, 0.82) and y >= -0.05:
		return 1
	if y < -0.05 and y >= -0.52 and ax >= 0.44 and ax <= 0.82:
		return 1
	return 0

func _peti_kelas(x, y) -> int:
	var ax = abs(x)
	var basis = _kotak(x, y, -0.75, -0.65, 0.75, 0.24)
	var tutup = _kotak(x, y, -0.80, 0.24, 0.80, 0.58)
	if not (basis or tutup):
		return 0
	if _disc(x, y, 0.0, 0.20, 0.12):
		return 4
	if ax <= 0.12:
		return 3
	if y >= 0.18 and y <= 0.30:
		return 3
	if tutup and y >= 0.50:
		return 3
	if tutup:
		return 2
	return 1

# ====== render ======
func _buat(f: Callable, size: int) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in size:
		var ny = 1.0 - (float(y) + 0.5) / float(size) * 2.0
		var g = 0.70 + 0.30 * ((ny + 1.0) * 0.5)
		for x in size:
			var hit = 0
			for sy in 2:
				for sx in 2:
					var nx = (float(x) + (float(sx) + 0.5) / 2.0) / float(size) * 2.0 - 1.0
					var my = 1.0 - (float(y) + (float(sy) + 0.5) / 2.0) / float(size) * 2.0
					if f.call(nx, my):
						hit += 1
			img.set_pixel(x, y, Color(g, g, g, float(hit) / 4.0))
	return ImageTexture.create_from_image(img)

func _buat_warna(kelas: Callable, palet: Array, size: int) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var n = palet.size() + 1
	for y in size:
		var ny = 1.0 - (float(y) + 0.5) / float(size) * 2.0
		var g = 0.84 + 0.16 * ((ny + 1.0) * 0.5)
		for x in size:
			var hitung = []
			hitung.resize(n)
			for i in n:
				hitung[i] = 0
			var total = 0
			for sy in 2:
				for sx in 2:
					var nx = (float(x) + (float(sx) + 0.5) / 2.0) / float(size) * 2.0 - 1.0
					var my = 1.0 - (float(y) + (float(sy) + 0.5) / 2.0) / float(size) * 2.0
					var k = kelas.call(nx, my)
					if k > 0:
						hitung[k] += 1
						total += 1
			if total == 0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var best = 1
			for i in range(2, n):
				if hitung[i] > hitung[best]:
					best = i
			var c: Color = palet[best - 1]
			img.set_pixel(x, y, Color(c.r * g, c.g * g, c.b * g, float(total) / 4.0))
	return ImageTexture.create_from_image(img)

func _buat_magnet(size: int) -> ImageTexture:
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var merah = Color(0.90, 0.17, 0.16)
	var merah_gelap = Color(0.52, 0.06, 0.06)
	var perak = Color(0.90, 0.92, 0.97)
	for y in size:
		var ny = 1.0 - (float(y) + 0.5) / float(size) * 2.0
		for x in size:
			var badan = 0
			var kutub = 0
			for sy in 2:
				for sx in 2:
					var nx = (float(x) + (float(sx) + 0.5) / 2.0) / float(size) * 2.0 - 1.0
					var my = 1.0 - (float(y) + (float(sy) + 0.5) / 2.0) / float(size) * 2.0
					var k = _magnet_kelas(nx, my)
					if k == 1:
						badan += 1
					elif k == 2:
						kutub += 1
			var hit = badan + kutub
			if hit == 0:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
				continue
			var isi: Color
			if kutub >= badan:
				isi = perak
			else:
				isi = merah_gelap.lerp(merah, (ny + 1.0) * 0.5)
			img.set_pixel(x, y, Color(isi.r, isi.g, isi.b, float(hit) / 4.0))
	return ImageTexture.create_from_image(img)

func _tint(tex: ImageTexture, w: Color) -> ImageTexture:
	var img = tex.get_image()
	var lx = img.get_width()
	var ly = img.get_height()
	var out = Image.create(lx, ly, false, Image.FORMAT_RGBA8)
	for y in ly:
		for x in lx:
			var c = img.get_pixel(x, y)
			out.set_pixel(x, y, Color(c.r * w.r, c.g * w.g, c.b * w.b, c.a))
	return ImageTexture.create_from_image(out)

func _dapat(nama: String) -> ImageTexture:
	if _cache.has(nama):
		return _cache[nama]
	var t: ImageTexture = null
	match nama:
		"bintang":
			t = _buat(_f_bintang, 72)
		"petir":
			t = _buat(_f_petir, 72)
		"peluru":
			t = _buat(_f_peluru, 72)
		"target":
			t = _buat(_f_target, 72)
		"chevron":
			t = _buat(_f_chevron, 72)
		"hati":
			t = _buat(_f_hati, 72)
		"berlian":
			t = _buat(_f_berlian, 72)
		"tengkorak":
			t = _buat(_f_tengkorak, 72)
		"aura":
			t = _buat(_f_aura, 72)
		"roket":
			t = _buat(_f_roket, 72)
		"pisau":
			t = _buat(_f_pisau, 72)
		"bom":
			t = _buat_warna(_bom_kelas, _PALET_BOM, 72)
		"magnet":
			t = _buat_magnet(72)
		"peti":
			t = _buat_warna(_peti_kelas, _PALET_PETI, 72)
	_cache[nama] = t
	return t

func _nama_ikon_skill(id: String) -> String:
	match id:
		"cepat_tembak":
			return "petir"
		"tambah_peluru":
			return "peluru"
		"jangkauan":
			return "target"
		"kaki_cepat":
			return "chevron"
		"badan_kuat":
			return "hati"
		"magnet":
			return "berlian"
		"orbit":
			return "pisau"
		"aura":
			return "aura"
		"roket":
			return "roket"
	return "bintang"

func warna_skill(id: String) -> Color:
	match id:
		"cepat_tembak":
			return Color(1.0, 0.85, 0.30)
		"tambah_peluru":
			return Color(1.0, 0.80, 0.40)
		"jangkauan":
			return Color(0.70, 0.90, 1.0)
		"kaki_cepat":
			return Color(0.65, 1.0, 0.70)
		"badan_kuat":
			return Color(1.0, 0.45, 0.45)
		"magnet":
			return Color(0.70, 0.90, 1.0)
		"orbit":
			return Color(0.92, 0.94, 1.0)
		"aura":
			return Color(0.80, 0.65, 1.0)
		"roket":
			return Color(1.0, 0.60, 0.35)
	return Color(1.0, 0.85, 0.35)

func untuk_skill(id: String) -> ImageTexture:
	var key = "skill_" + id
	if _cache.has(key):
		return _cache[key]
	var dasar = _dapat(_nama_ikon_skill(id))
	if dasar == null:
		return null
	var t = _tint(dasar, warna_skill(id))
	_cache[key] = t
	return t

func untuk_item(id: String) -> ImageTexture:
	match id:
		"bom":
			return _dapat("bom")
		"magnet":
			return _dapat("magnet")
		"peti":
			return _dapat("peti")
	return _dapat("peti")
