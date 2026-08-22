extends Node
# Port dari KarakterManager.cs (SALDOKU Unity) - autoload "Karakter".

const ID: Array[String] = [
	"Archer_Character_1", "Cave_Man_Character_2", "Clown_Character_3",
	"Monk_Character_4", "Ninja_Character_5", "Pirate_Character_6",
	"Soldier_Character_7", "Warrior_Character_8", "Wizard_Character_9",
]
const NAMA: Array[String] = [
	"PEMANAH", "MANUSIA GUA", "BADUT", "BIKSU", "NINJA",
	"BAJAK LAUT", "TENTARA", "KESATRIA", "PENYIHIR",
]
const BAGIAN: Array[String] = ["Body", "Head", "Left_Foot", "Right_Foot", "Weapon"]
const BAWAAN := 4  # Ninja
const BASE := "res://Assets/Jovial Games/Simple 2D Cute Characters/Characters/"

var dipilih := BAWAAN
var _cache := {}

func _ready() -> void:
	muat()

func jumlah() -> int:
	return ID.size()

func nama_dipilih() -> String:
	return NAMA[clampi(dipilih, 0, NAMA.size() - 1)]

func muat() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://saldoku.cfg") == OK:
		dipilih = clampi(int(cfg.get_value("karakter", "dipilih", BAWAAN)), 0, ID.size() - 1)

func simpan() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("karakter", "dipilih", dipilih)
	cfg.save("user://saldoku.cfg")

func berikutnya() -> void:
	dipilih = (dipilih + 1) % ID.size()
	simpan()

func sebelumnya() -> void:
	dipilih = (dipilih - 1 + ID.size()) % ID.size()
	simpan()

func tekstur(idx: int, bagian: String) -> Texture2D:
	if idx < 0 or idx >= ID.size():
		return null
	var key: String = "%d/%s" % [idx, bagian]
	if _cache.has(key):
		return _cache[key]
	var path: String = BASE + ID[idx] + "/" + bagian + ".png"
	var t: Texture2D = load(path) as Texture2D
	_cache[key] = t
	return t
