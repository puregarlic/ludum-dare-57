extends Node3D

var delta_accum: float = 0.0

func example_background_animation():
	$ScrollingBackground/BackgroundAnimationEngine.gentle_speed_up_slow_down(7)

func _process(delta):
	if delta_accum >= 0:
		delta_accum += delta
	
	if delta_accum >= 4.0 and delta_accum >= 0.0:
		example_background_animation()
		delta_accum = -1
