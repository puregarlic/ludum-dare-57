@tool
extends ColorRect

func _process(delta):
	var mat := material as ShaderMaterial
	mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
