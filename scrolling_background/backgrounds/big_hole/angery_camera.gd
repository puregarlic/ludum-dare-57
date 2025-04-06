class_name AngeryCamera
extends Node3D

@export var max_shake_amount: float = 0.3
@export var light_node_path: NodePath
@export var max_light_intensity_multiplier: float = 2.0

var shake_intensity: float = 0.0
var original_light_color: Color
var original_light_energy: float
var light_node: DirectionalLight3D
var time_accumulator := 0.0
var severity := 0.0

func _ready():
	add_to_group("AngeryCamera")
	light_node = get_node(light_node_path)
	if light_node:
		original_light_color = light_node.light_color
		original_light_energy = light_node.light_energy

func set_shake_severity(v: float):
	severity = v
	
func shake_and_tint(severity: float):
	shake_intensity = clamp(severity, 0.0, 1.0)

	var offset = Vector3(
		randf_range(-1, 1),
		randf_range(-1, 1),
		randf_range(-1, 1)
	) * max_shake_amount * shake_intensity
	transform.origin = offset

	if light_node:
		var red = Color(1.0, 0.0, 0.0)
		var blended_color = original_light_color.lerp(red, shake_intensity)
		light_node.light_color = blended_color

		var intensity = original_light_energy * lerp(1.0, max_light_intensity_multiplier, shake_intensity)
		light_node.light_energy = intensity

func _process(_delta):
	shake_and_tint(severity)
