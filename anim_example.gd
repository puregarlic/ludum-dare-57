@tool
extends Node3D

var delta_acc := 0.0

func _ready():
	print($ScrollingBackgroundEngine.list_anim_methods())

func _process(delta: float) -> void:
	if delta_acc >= 0.0:
		delta_acc += delta
	
	if delta_acc >= 3.0:
		delta_acc = -1.0
		#$ScrollingBackgroundEngine.call_anim("anim_gentle_speed_up_slow_down", [7.0])
		$ScrollingBackgroundEngine.transition_to_next()
