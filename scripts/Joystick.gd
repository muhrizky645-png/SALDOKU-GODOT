extends Control
# Port dari VirtualJoystick.cs - joystick muncul di titik sentuh.

var direction := Vector2.ZERO

var _active := false
var _center := Vector2.ZERO
var _pos := Vector2.ZERO
var _radius := 120.0
var _max := 100.0
var _sens := 1.6

func _ready() -> void:
	add_to_group("joystick")
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_radius = get_viewport_rect().size.y * 0.11
	_max = _radius * 0.9

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_active = true
			_center = event.position
			_pos = event.position
			direction = Vector2.ZERO
		else:
			_active = false
			direction = Vector2.ZERO
		queue_redraw()
	elif event is InputEventScreenDrag and _active:
		_pos = event.position
		var off := (_pos - _center).limit_length(_max)
		direction = (off / _max * _sens).limit_length(1.0)
		queue_redraw()

func _draw() -> void:
	if not _active:
		return
	draw_circle(_center, _radius, Color(1, 1, 1, 0.25))
	var off := (_pos - _center).limit_length(_max)
	draw_circle(_center + off, _radius * 0.5, Color(1, 1, 1, 0.6))
