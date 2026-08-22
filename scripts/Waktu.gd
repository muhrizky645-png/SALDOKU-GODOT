extends Node
# Autoload "Waktu" - port dari GameTimer.cs. Lama bertahan (detik).

var detik := 0.0
var jalan := false

func reset() -> void:
	detik = 0.0
	jalan = true

func _process(delta: float) -> void:
	if jalan:
		detik += delta

func teks() -> String:
	var m := int(detik) / 60
	var s := int(detik) % 60
	return "%02d:%02d" % [m, s]
