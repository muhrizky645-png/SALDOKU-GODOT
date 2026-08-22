extends Node2D
## Pemain sederhana untuk menguji pipeline build.
## Bergerak menuju titik sentuh / klik. Ini fondasi; nanti diganti
## dengan gerak + tembak penuh saat porting berlanjut.

@export var speed: float = 500.0
var target: Vector2

func _ready() -> void:
	target = global_position

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target = get_global_mouse_position()
	global_position = global_position.move_toward(target, speed * delta)
