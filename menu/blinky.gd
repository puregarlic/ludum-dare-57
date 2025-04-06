extends Label

@export var blink_speed := 0.5
var _timer := 0.0
var _visible := true

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= blink_speed:
		_visible = !_visible
		visible = _visible
		_timer = 0.0
