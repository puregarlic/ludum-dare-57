@tool
class_name Background
extends Node3D

@export var rail_follower: PathFollow3D
@export var travel_duration := 5.0
@export var default_curve: Curve

var elapsed := 0.0
var blend_duration := 1.0
var blend_progress := 0.0
var blending := false

var current_curve: Curve
var target_curve: Curve
var blend_start_speed_curve: Curve

func _ready():
	current_curve = default_curve

func _process(delta):
	if elapsed < travel_duration:
		var t = clamp(elapsed / travel_duration, 0.0, 1.0)
		var speed_curve = _get_blended_speed_curve()
		var speed_scale = speed_curve.sample(t)
		elapsed += delta * speed_scale

		t = clamp(elapsed / travel_duration, 0.0, 1.0)
		rail_follower.progress_ratio = t
	else:
		elapsed = 0

	if blending:
		blend_progress += delta / blend_duration
		if blend_progress >= 1.0:
			current_curve = target_curve
			blending = false

func _get_blended_speed_curve() -> Curve:
	if !blending:
		return current_curve

	var blend: float = clamp(blend_progress, 0.0, 1.0)
	var temp_curve := Curve.new()
	var steps := 32
	for i in steps:
		var x = i / (steps - 1.0)
		var y_a = blend_start_speed_curve.sample(x)
		var y_b = target_curve.sample(x)
		temp_curve.add_point(x, lerp(y_a, y_b, blend))
	return temp_curve

func transition_to_speed_curve(new_curve: Curve, duration := 1.0):
	blend_start_speed_curve = current_curve
	target_curve = new_curve
	blend_progress = 0.0
	blend_duration = duration
	blending = true
