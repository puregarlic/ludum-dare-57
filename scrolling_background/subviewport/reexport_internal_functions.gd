@tool
extends SubViewportContainer

@onready var deep_node := $SubViewport/BackgroundState/BackgroundAnimationEngine
var anim_methods := {}
signal loss_anim_complete

func _ready():
	for method_info in deep_node.get_method_list():
		var method_name = method_info.name
		if method_name.begins_with("anim_") and deep_node.has_method(method_name):
			anim_methods[method_name] = {
				"callable": Callable(deep_node, method_name),
				"argument_count": method_info.args.size(),
				"argument_names": method_info.args
			}

func call_anim(method_name: String, args: Array = []):
	var full_name = method_name
	if full_name in anim_methods:
		return anim_methods[full_name]["callable"].callv(args)
	else:
		push_error("Animation method '%s' not found." % full_name)

func list_anim_methods() -> Array:
	var methods = []
	for method_name in anim_methods.keys():
		var info = anim_methods[method_name]
		methods.append({
			"name": method_name,
			"argument_count": info.argument_count,
			"argument_names": info.argument_names
		})
	return methods

func try_call_set_severity(v: float) -> bool:
	for child in get_tree().get_nodes_in_group("AngeryCamera"):
		if child is AngeryCamera:
			child.set_shake_severity(v)
			return true
	return false
	
func transition_to_next():
	$SubViewport/BackgroundState.transition_to_next()
	
func end_it():
	deep_node.anim_hyperspeed_perma()
	deep_node.end_anim_complete.connect(_the_game_is_over)

func _the_game_is_over():
	emit_signal("loss_anim_complete")
