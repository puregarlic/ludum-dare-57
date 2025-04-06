@tool
class_name BackgroundTransitionManager
extends Node3D

@export var current_state: Globals.BackgroundStates = Globals.BackgroundStates.ROMAN_COLUMN_YARD
var target_state: Globals.BackgroundStates = Globals.BackgroundStates.NONE

var backgrounds = {
	Globals.BackgroundStates.ROMAN_COLUMN_YARD: preload("res://scrolling_background/backgrounds/roman_column_yard/roman_column_yard.tscn"),
	Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE: preload("res://scrolling_background/backgrounds/roman_column_yard_big_hole_transition/roman_column_yard_big_hole_transition.tscn"),
	Globals.BackgroundStates.BIG_HOLE: preload("res://scrolling_background/backgrounds/big_hole/big_hole.tscn")
}
var current_background: Background = null

func _ready() -> void:
	_instantiate_current_background()
	
func _instantiate_current_background():
	if current_background:
		self.remove_child(current_background)
		$BackgroundAnimationEngine.remove_managed_background()
		current_background.queue_free()
	current_background = backgrounds[current_state].instantiate()
	self.add_child(current_background)
	$BackgroundAnimationEngine.set_managed_background(current_state, current_background)
	
func transition_to_next():
	target_state = _get_next_state(current_state)
	if target_state != Globals.BackgroundStates.NONE:
		current_background.tile_loop_finished.connect(_on_tile_loop_resolved)
	
func _get_next_state(state: Globals.BackgroundStates) -> Globals.BackgroundStates:
	match state:
		Globals.BackgroundStates.ROMAN_COLUMN_YARD:
			return Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE
		Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE:
			return Globals.BackgroundStates.BIG_HOLE
		Globals.BackgroundStates.BIG_HOLE:
			return Globals.BackgroundStates.BIG_HOLE
		_:
			return Globals.BackgroundStates.NONE

func _on_tile_loop_resolved():
	current_state = target_state
	target_state = Globals.BackgroundStates.NONE
	_instantiate_current_background()
