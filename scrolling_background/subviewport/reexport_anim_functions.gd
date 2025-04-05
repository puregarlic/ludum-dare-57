@tool
extends SubViewportContainer

@onready var deep_node := $SubViewport/ScrollingBackground/BackgroundAnimationEngine
var anim_methods := {}

func _ready():
	for method_info in deep_node.get_method_list():
		var name = method_info.name
		if name.begins_with("anim_") and deep_node.has_method(name):
			anim_methods[name] = {
				"callable": Callable(deep_node, name),
				"argument_count": method_info.args.size(),
				"argument_names": method_info.args
			}

func call_anim(name: String, args: Array = []):
	print("CALLING IN CALL_ANIM")
	var full_name = name
	if full_name in anim_methods:
		return anim_methods[full_name]["callable"].callv(args)
	else:
		push_error("Animation method '%s' not found." % full_name)

func list_anim_methods() -> Array:
	var methods = []
	for name in anim_methods.keys():
		var info = anim_methods[name]
		methods.append({
			"name": name,
			"argument_count": info.argument_count,
			"argument_names": info.argument_names
		})
	return methods
