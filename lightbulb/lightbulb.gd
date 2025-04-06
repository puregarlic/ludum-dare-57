@tool
extends TextureProgressBar

@export var enabled: bool = false:
	set(value):
		enabled = value
		if enabled:
			visible = true
		else:
			visible = false

@export var fill: float = 0.0:
	set(value):
		fill = value
		self.value = fill * self.max_value

func _ready():
	pass
	
func change_fill(amount: float):
	pass
