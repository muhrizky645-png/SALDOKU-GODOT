extends Node
# Autoload "Skor" - port dari ScoreManager.cs. Skor + rekor tersimpan permanen.

var skor := 0
var rekor := 0

const _PATH := "user://saldoku.cfg"

func _ready() -> void:
	_muat_rekor()

func reset() -> void:
	skor = 0

func tambah(n: int) -> void:
	skor += n
	if skor > rekor:
		rekor = skor
		_simpan_rekor()

func _muat_rekor() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(_PATH) == OK:
		rekor = int(cfg.get_value("skor", "rekor", 0))

func _simpan_rekor() -> void:
	var cfg := ConfigFile.new()
	cfg.load(_PATH)
	cfg.set_value("skor", "rekor", rekor)
	cfg.save(_PATH)
