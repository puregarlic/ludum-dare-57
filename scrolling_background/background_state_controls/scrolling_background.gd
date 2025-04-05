@tool
class_name BackgroundState
extends Node3D

enum BackgroundStates { NONE, ROMAN_COLUMN_YARD, ROMAN_COLUMN_YARD_TO_BIG_HOLE, BIG_HOLE }
@export var current_state: BackgroundStates = BackgroundStates.ROMAN_COLUMN_YARD
var target_state: BackgroundStates = BackgroundStates.NONE

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
	target_state = _get_next_state(current_state)
	if target_state != BackgroundStates.NONE:
		current_background.tile_loop_finished.connect(_on_tile_loop_resolved)
	
func _get_next_state(state: BackgroundStates) -> BackgroundStates:
	match state:
		BackgroundStates.ROMAN_COLUMN_YARD:
			return BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE
		BackgroundStates.ROMAN_COLUMN_YARD_TO_BIG_HOLE:
			return BackgroundStates.BIG_HOLE
		BackgroundStates.BIG_HOLE:
			return BackgroundStates.BIG_HOLE
		_:
			return BackgroundStates.NONE

func _on_tile_loop_resolved():
	current_state = target_state
	target_state = BackgroundStates.NONE
	_instantiate_current_background()
