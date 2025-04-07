@tool
class_name BackgroundTransitionManager
extends Node3D

@export var current_state: Globals.BackgroundStates = Globals.BackgroundStates.ROMAN_COLUMN_YARD
var target_state: Globals.BackgroundStates = Globals.BackgroundStates.NONE
var in_end: bool = false

var backgrounds = {
	Globals.BackgroundStates.ROMAN_COLUMN_YARD: preload("res://scrolling_background/backgrounds/roman_column_yard/roman_column_yard.tscn"),
	Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE: preload("res://scrolling_background/backgrounds/roman_column_yard_big_hole_transition/roman_column_yard_big_hole_transition.tscn"),
	Globals.BackgroundStates.BIG_HOLE: preload("res://scrolling_background/backgrounds/big_hole/big_hole.tscn")
}
var current_background: Background = null

func _ready() -> void:
	$BackgroundAnimationEngine.untransition_in_end.connect(_transition_to_previous)
	$BackgroundAnimationEngine.set_end_state.connect(_set_end_state)
	_instantiate_current_background(false)
	
func _instantiate_current_background(set_up_for_end: bool):
	if current_background:
		self.remove_child(current_background)
		$BackgroundAnimationEngine.remove_managed_background()
		current_background.queue_free()
	current_background = backgrounds[current_state].instantiate()
	self.add_child(current_background)
	$BackgroundAnimationEngine.set_managed_background(current_state, current_background)
	
	# Hacky way to get Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE to transition witout
	# an external call to transition_to_next()
	if current_state == Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE and !set_up_for_end:
		transition_to_next()
		
	if set_up_for_end:
		current_background.elapsed = 1.0
		$BackgroundAnimationEngine.anim_hyperspeed_perma_nostatemanage()

func transition_to_next():
	if in_end:
		return
		
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
			
func _get_previous_state(state: Globals.BackgroundStates) -> Globals.BackgroundStates:
	match state:
		Globals.BackgroundStates.ROMAN_COLUMN_YARD:
			return Globals.BackgroundStates.ROMAN_COLUMN_YARD
		Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE:
			return Globals.BackgroundStates.ROMAN_COLUMN_YARD
		Globals.BackgroundStates.BIG_HOLE:
			return Globals.BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE
		_:
			return Globals.BackgroundStates.NONE

func _on_tile_loop_resolved():
	if in_end:
		return
		
	current_state = target_state
	target_state = Globals.BackgroundStates.NONE
	_instantiate_current_background(false)
	
func _transition_to_previous():
	target_state = _get_previous_state(current_state)
	if target_state != Globals.BackgroundStates.NONE:
		current_state = target_state
		target_state = Globals.BackgroundStates.NONE
		_instantiate_current_background(true)

func _set_end_state():
	in_end = true
