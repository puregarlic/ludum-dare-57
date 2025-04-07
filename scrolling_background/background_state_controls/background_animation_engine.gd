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
	"ramp_from_100_to_50": preload("res://scrolling_background/acceleration_curves/ramp_from_100_to_50.tres"),
	"veryslow": preload("res://scrolling_background/acceleration_curves/veryslow.tres"),
	"veryslow_to_100": preload("res://scrolling_background/acceleration_curves/veryslow_to_100.tres")
}

var current_background: Background
var game_state: Globals.BackgroundStates
var animation_queue = []
var end_tiles := 0
var in_end := false
signal untransition_in_end
signal end_anim_complete
signal set_end_state

func set_managed_background(state: Globals.BackgroundStates, background: Background):
	current_background = background
	current_background.anim_finished.connect(_on_animation_resolved)
	game_state = state
	
	if !in_end:
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
	
func anim_mainmenu_speedup():
	animation_queue.pop_front()
	_add_animation_to_queue("veryslow_to_100", 5.0)
	_add_animation_to_queue("100", 0.0)
	
func anim_mainmenu_slow():
	_add_animation_to_queue("veryslow", 0.0)
	
func anim_hyperspeed_perma():
	emit_signal("set_end_state")
	in_end = true
	current_background.tile_loop_finished.connect(_count_tiles_for_end_sequence)
	current_background.dir_multiplier = -1
	animation_queue = []
	_add_animation_to_queue("ramp_from_100_to_1000", 3)
	_add_animation_to_queue("1000", 0.0)
	
func anim_hyperspeed_perma_nostatemanage():
	emit_signal("set_end_state")
	in_end = true
	current_background.tile_loop_finished.connect(_count_tiles_for_end_sequence)
	current_background.dir_multiplier = -1
	animation_queue = []
	_add_animation_to_queue("1000", 0.0)

func _count_tiles_for_end_sequence():
	end_tiles += 1
	
	if game_state == Globals.BackgroundStates.BIG_HOLE:
		if end_tiles >= 10:
			emit_signal("untransition_in_end")
	elif game_state == Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE:
		emit_signal("untransition_in_end")
	elif game_state == Globals.BackgroundStates.ROMAN_COLUMN_YARD:
		if end_tiles >= 10:
			current_background.progress_speed = 0.0
			emit_signal("end_anim_complete")
