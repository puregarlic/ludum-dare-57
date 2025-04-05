extends Node3D

var delta_accum: float = 0.0

func example_background_animation():
	$ScrollingBackground/BackgroundAnimationEngine.speed_up_slow_down()

func _process(delta):
	delta_accum += delta
	
	if delta_accum >= 4:
		example_background_animation()
