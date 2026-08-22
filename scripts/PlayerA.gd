extends Node2D
# Uji A: hanya variabel anggota.

var speed := 340.0
var bob_amount := 0.08
var bob_speed := 12.0
var goyang_sudut := deg_to_rad(8.0)
var goyang_kecepatan := 12.0
var fire_rate := 1.2
var jumlah_peluru := 1
var sudut_sebar := deg_to_rad(12.0)
var range_tembak := 560.0
var _tembak := 0.5
var hp := 100.0
var hp_maks := 100.0
var sudah_mati := false
var nama := "?"
var parts_loaded := 0
var rig: Node2D = null
var _k := 1.0
var _face := 1.0
var _t := 0.0
var _weapon_tex: Texture2D = null
const TARGET_TINGGI := 210.0

func _ready() -> void:
	pass
