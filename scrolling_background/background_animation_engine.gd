@tool
class_name BackgroundAnimationEngine
extends Node

var curves = {
	"100": preload("res://scrolling_background/acceleration_curves/100.tres"),
	"150": preload("res://scrolling_background/acceleration_curves/150.tres"),
	"ramp_from_100_to_150": preload("res://scrolling_background/acceleration_curves/ramp_from_100_to_150.tres"),
	"ramp_from_150_to_100": preload("res://scrolling_background/acceleration_curves/ramp_from_150_to_100.tres")
}

var current_background: Background
var animation_queue = []

func set_managed_background(background: Background):
	current_background = background
	current_background.anim_finished.connect(_animation_resolved_callback)
	
func remove_managed_background(background: Background):
	animation_queue = []
	current_background = null
	
func _add_animation_to_queue(curve_name: String, transition_length: float):
	if len(animation_queue) == 0:
		current_background.transition_speed_with_curve(curves[curve_name], transition_length)
	animation_queue.append({ "name": curve_name, "transition_length": transition_length })
	
func _animation_resolved_callback():
	animation_queue.pop_front()
	if len(animation_queue) > 0:
		current_background.transition_speed_with_curve(curves[animation_queue.front()["name"]], animation_queue.front()["transition_length"])

# Animation functions
func speed_up_slow_down(animation_length_in_seconds: float):
	var transition_length := animation_length_in_seconds / 3
	_add_animation_to_queue("ramp_from_100_to_150", transition_length)
	_add_animation_to_queue("150", transition_length)
	_add_animation_to_queue("ramp_from_150_to_100", transition_length)
	_add_animation_to_queue("100", 0.0)
