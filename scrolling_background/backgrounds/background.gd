@tool
class_name Background
extends Node3D

signal anim_finished
signal tile_loop_finished

@export var rail_follower: PathFollow3D
@export var progress_speed := 5.0
@export var default_curve: Curve
@export var managing_rail: bool = true

var elapsed := 0.0

var active_curve: Curve = null
var animation_duration := 0.0
var animation_time := 0.0
var loop_curve := false

func _ready():
	active_curve = default_curve
	rail_follower.progress_ratio = 0.0

func _process(delta):
	var base_speed := 1.0 / progress_speed
	var speed_multiplier := 1.0

	if active_curve and (loop_curve or animation_time < animation_duration):
		var t := 0.0
		if animation_duration > 0.0:
			t = clamp(animation_time / animation_duration, 0.0, 1.0)
		else:
			t = fmod(animation_time, 1.0)

		speed_multiplier = active_curve.sample(t)
		animation_time += delta

		if !loop_curve and animation_time >= animation_duration:
			active_curve = default_curve
			emit_signal("anim_finished")

	elapsed += delta * base_speed * speed_multiplier
	if elapsed >= 1.0:
		elapsed = fmod(elapsed, 1.0)
		emit_signal("tile_loop_finished")

	if managing_rail:
		rail_follower.progress_ratio = clamp(elapsed, 0.0, 1.0)

func transition_speed_with_curve(curve: Curve, duration: float):
	active_curve = curve
	animation_time = 0.0
	animation_duration = duration
	loop_curve = (duration == 0.0)
