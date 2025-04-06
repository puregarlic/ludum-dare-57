@tool
extends Node3D

@export var target_spin_speed: float = 25.0 
@export var spin_duration: float = 5.0
@export var wiggle_base_amplitude_deg: float = 1.0
@export var wiggle_peak_amplitude_deg: float = 4.0
@export var wiggle_frequency: float = 0.1
@export var wiggle_amplitude_mod_freq: float = 0.05
@onready var camera: Camera3D = %Camera3D

var current_spin_speed: float = 0.0
var current_wiggle_amplitude: float = 0.0
var spin_tween: Tween
var amplitude_tween: Tween
var wiggle_time: float = 0.0
var wiggle_active: bool = false

func _ready():
	current_spin_speed = 0.0
	current_wiggle_amplitude = 0.0
	wiggle_time = 0.0
	wiggle_active = false
	camera.rotation = Vector3.ZERO

	await get_tree().create_timer(15.0).timeout

	spin_tween = create_tween()
	spin_tween.tween_property(self, "current_spin_speed", target_spin_speed, spin_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	amplitude_tween = create_tween()
	amplitude_tween.tween_property(self, "current_wiggle_amplitude", 1.0, spin_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	wiggle_active = true

func _process(delta):
	if wiggle_active:
		wiggle_time += delta
		var base_amp = lerp(wiggle_base_amplitude_deg, wiggle_peak_amplitude_deg, (sin(wiggle_time * TAU * wiggle_amplitude_mod_freq) * 0.5 + 0.5))
		var amp = base_amp * current_wiggle_amplitude

		var wiggle_x = deg_to_rad(amp * sin(wiggle_time * TAU * wiggle_frequency))
		var wiggle_y = deg_to_rad(amp * cos(wiggle_time * TAU * wiggle_frequency + PI / 3))

		camera.rotation.x = wiggle_x
		camera.rotation.y = wiggle_y

	if current_spin_speed > 0.0:
		camera.rotate_z(deg_to_rad(current_spin_speed * delta))
