@tool
extends TextureProgressBar

@export var enabled: bool = false:
	set(value):
		enabled = value
		visible = enabled

@export var fill: float = 0.0:
	set(value):
		fill = value
		self.value = remap(fill, 0.0, 1.0, 25.0, 100.0)
		if fill != 1.0:
			%Ding.play()

func _ready():
	pass
	
func change_fill(amount: float):
	pass
