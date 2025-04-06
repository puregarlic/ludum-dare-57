extends Node2D

@export var viewport_x_div: float
@export var viewport_y_div: float
@export var x_offset: float = 0.0

var sway_amplitude = 20
var sway_speed = 1.0
var tilt_amplitude = 0.1
var tilt_lerp_speed = 5.0

var time := 0.0
var base_position := Vector2.ZERO

func _ready():
	var viewport_size = get_viewport_rect().size
	base_position = Vector2(viewport_size.x / viewport_x_div + x_offset, viewport_size.y / viewport_y_div)
	position = base_position

func _process(delta):
	time += delta
	var sway_offset = sin(time * sway_speed) * sway_amplitude
	position.x = base_position.x + sway_offset
	var sway_velocity = cos(time * sway_speed) * sway_speed
	var target_rotation = clamp(sway_velocity * tilt_amplitude, -tilt_amplitude, tilt_amplitude)
	rotation = lerp(rotation, target_rotation, delta * tilt_lerp_speed)
