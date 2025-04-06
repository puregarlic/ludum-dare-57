@tool
class_name BackgroundAnimationEngine
extends Node

var curves = {
	"50": preload("res://scrolling_background/acceleration_curves/50.tres"),
	"100": preload("res://scrolling_background/acceleration_curves/100.tres"),
	"150": preload("res://scrolling_background/acceleration_curves/150.tres"),
	"1000": preload("res://scrolling_background/acceleration_curves/1000.tres"),
	"ramp_from_100_to_150": preload("res://scrolling_background/acceleration_curves/ramp_from_100_to_150.tres"),
	"ramp_from_150_to_100": preload("res://scrolling_background/acceleration_curves/ramp_from_150_to_100.tres"),
	"ramp_from_100_to_1000": preload("res://scrolling_background/acceleration_curves/ramp_from_100_to_1000.tres"),
	"ramp_from_1000_to_100": preload("res://scrolling_background/acceleration_curves/ramp_from_1000_to_100.tres"),
	"ramp_from_100_to_50": preload("res://scrolling_background/acceleration_curves/ramp_from_100_to_50.tres")
}

var current_background: Background
var animation_queue = []

func set_managed_background(state: Globals.BackgroundStates, background: Background):
	current_background = background
	current_background.anim_finished.connect(_on_animation_resolved)
	_play_initial_animations(state)
	
func remove_managed_background():
	animation_queue = []
	current_background = null
	
func _add_animation_to_queue(curve_name: String, transition_length: float):
	if len(animation_queue) == 0:
		current_background.transition_speed_with_curve(curves[curve_name], transition_length)
	animation_queue.append({ "name": curve_name, "transition_length": transition_length })
	
func _on_animation_resolved():
	animation_queue.pop_front()
	if len(animation_queue) > 0:
		current_background.transition_speed_with_curve(curves[animation_queue.front()["name"]], animation_queue.front()["transition_length"])

# Hacky, this shouldn't be centralized here imo
func _play_initial_animations(state):
	if state == Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE:
		anim_hyperspeed()
		pass
	
# Animation functions
func anim_gentle_speed_up_slow_down(animation_length_in_seconds: float):
	var transition_length := animation_length_in_seconds / 3
	_add_animation_to_queue("ramp_from_100_to_150", transition_length)
	_add_animation_to_queue("150", transition_length)
	_add_animation_to_queue("ramp_from_150_to_100", transition_length)
	_add_animation_to_queue("100", 0.0)
	
func anim_hyperspeed():
	_add_animation_to_queue("ramp_from_100_to_1000", 5.5)
	_add_animation_to_queue("1000", 1)
	_add_animation_to_queue("ramp_from_1000_to_100", 2.3)
	_add_animation_to_queue("ramp_from_100_to_50", 1)
	_add_animation_to_queue("50", 0.0)
