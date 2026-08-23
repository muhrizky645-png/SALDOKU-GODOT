extends Node
# Autoload "Level" - port dari LevelSystem.cs. Level & XP pemain.

var level := 1
var xp := 0
var xp_untuk_naik := 5

func reset() -> void:
	level = 1
	xp = 0
	xp_untuk_naik = 5

func tambah_xp(jumlah: int) -> void:
	var lv_lama := level
	xp += jumlah
	while xp >= xp_untuk_naik:
		xp -= xp_untuk_naik
		level += 1
		xp_untuk_naik = int(round(xp_untuk_naik * 1.3)) + 2
	if level > lv_lama:
		var snd = get_node_or_null("/root/Sound")
		if snd != null:
			snd.level_up()

func rasio_xp() -> float:
	if xp_untuk_naik <= 0:
		return 0.0
	return clampf(float(xp) / float(xp_untuk_naik), 0.0, 1.0)
