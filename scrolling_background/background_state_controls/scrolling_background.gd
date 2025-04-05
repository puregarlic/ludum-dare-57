@tool
class_name BackgroundProgression
extends Node3D

enum BackgroundStates { ROMAN_COLUMN_YARD, ROMAN_COLUMN_YARD_TO_BIG_HOLE, BIG_HOLE }
@export var current_state: BackgroundStates = BackgroundStates.ROMAN_COLUMN_YARD
var backgrounds = {
	BackgroundStates.ROMAN_COLUMN_YARD: preload("res://scrolling_background/backgrounds/roman_column_yard/roman_column_yard.tscn"),
	BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE: preload("res://scrolling_background/backgrounds/roman_column_yard_big_hole_transition/roman_column_yard_big_hole_transition.tscn"),
	BackgroundStates.BIG_HOLE: preload("res://scrolling_background/backgrounds/big_hole/big_hole.tscn")
}
var current_background: Background = null

func _ready() -> void:
	_instantiate_current_background()
	
func _instantiate_current_background():
	if current_background:
		self.remove_child(current_background)
		$BackgroundAnimationEngine.remove_managed_background(current_background)
		current_background.queue_free()
	current_background = backgrounds[current_state].instantiate()
	self.add_child(current_background)
	
	$BackgroundAnimationEngine.set_managed_background(current_background)
	
func transition_to_next():
	var load_next_state = false
	for state in BackgroundStates:
		if load_next_state == true:
			current_state = state
			return
		elif state == current_state:
			load_next_state = true
