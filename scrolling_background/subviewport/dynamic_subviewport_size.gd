@tool
extends SubViewport

func _ready() -> void:
	self.size = DisplayServer.window_get_size()
