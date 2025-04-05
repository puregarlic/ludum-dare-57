@tool
class_name BackgroundAnimationEngine
extends Node

var current_background: Background
var animation_queue = []

func set_managed_background(background: Background):
	current_background = background
	
func remove_managed_background(background: Background):
	current_background = null

# Animation engine functions
# TODO animation queue with signal callbacks for completion
func speed_up_slow_down():
	pass
