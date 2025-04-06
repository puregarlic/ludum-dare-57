@tool
extends TextureProgressBar

enum GearStates {
	DISABLED,
	NORMAL,
	LOW_ON_TIME
}

var current_state: GearStates = GearStates.NORMAL
var pulse_timer: float = 0.0

@export var enabled: bool = false:
	set(value):
		enabled = value
		visible = enabled
		
		match current_state:
			GearStates.DISABLED:
				if enabled:
					if time_left < 0.5:
						low_on_time()
					else:
						normal()
			GearStates.NORMAL:
				if !enabled:
					disabled()
			GearStates.LOW_ON_TIME:
				if !enabled:
					disabled()

# Expressed as percentage of time left from 0.0 to 1.0
@export var time_left: float = 0.0:
	set(value):
		time_left = value
		self.value = time_left * self.max_value
		
		match current_state:
			GearStates.NORMAL:
				if time_left < 0.5:
					low_on_time()
			GearStates.LOW_ON_TIME:
				if time_left >= 0.5:
					normal()

@export var low_on_time_tint: Color = Color.WHITE
@export var default_tint: Color = Color("949494")
@export var low_on_time_rotation_amount: float = 3.0

func _ready() -> void:
	pivot_offset = size / 2

func _process(delta: float) -> void:
	match current_state:
		GearStates.LOW_ON_TIME:
			pulse_timer += delta / (max(time_left, 0.15) ** 2)
			var lerp_amount = (sin(pulse_timer) + 1) / 2
			tint_progress = default_tint.lerp(low_on_time_tint, lerp_amount)
			rotation_degrees = (lerp_amount - 0.5) * low_on_time_rotation_amount
			

# State transitions
func disabled():
	current_state = GearStates.DISABLED
	pulse_timer = 0.0
	tint_progress = default_tint
	rotation_degrees = 0.0
	
func normal():
	current_state = GearStates.NORMAL
	pulse_timer = 0.0
	tint_progress = default_tint
	rotation_degrees = 0.0
	
func low_on_time():
	current_state = GearStates.LOW_ON_TIME
	pulse_timer = 0.0
