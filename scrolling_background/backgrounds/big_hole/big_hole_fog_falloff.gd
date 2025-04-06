@tool
extends Node3D

var env: Environment
var tween: Tween

@onready var world_env: WorldEnvironment = $WorldEnvironment

func _ready():
	env = world_env.environment
	env.volumetric_fog_density = 1.0

	tween = create_tween()
	tween.tween_method(_set_density_curve, 0.0, 1.0, 10.0)

func _set_density_curve(t: float):
	var eased_t = smoothstep(0.0, 1.0, pow(t, 1.8))
	var density = lerp(1.0, 0.06, eased_t)
	env.volumetric_fog_density = density
