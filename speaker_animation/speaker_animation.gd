class_name Bust extends AnimatedSprite2D

enum SpeakerAnimationStates { 
	MATCHING, 
	NERVOUS, 
	TALK_IDLE, 
	TALK 
	}

enum Philosopher { 
	PIUS, 
	CAESAR 
}

@export var current_state: SpeakerAnimationStates = SpeakerAnimationStates.MATCHING:
	set(value):
		current_state = value
		match current_state:
			SpeakerAnimationStates.MATCHING:
				matching()
			SpeakerAnimationStates.NERVOUS:
				nervous()
			SpeakerAnimationStates.TALK_IDLE:
				prepare_talk()
			SpeakerAnimationStates.TALK:
				talk()
			
		
@export var intensity: int = 0
@export var philosopher: Philosopher = Philosopher.PIUS:
	set(value):
		philosopher = value
		load_philosopher()
		
# Chance that on a higher intensity the speaker will play an animation from a lower intensity
@export var intensity_switch_chance := 0.3

var pius_resource := preload("res://speaker_animation/pius.tres")
var caesar_resource := preload("res://speaker_animation/caesar.tres")
var rng = RandomNumberGenerator.new()

var temp := 0.0
var target_temp := 0.2

func _ready() -> void:
	intensity = 0
	
	load_philosopher()
	current_state = SpeakerAnimationStates.MATCHING

## Dummy function to test out speaking animation
#func _process(delta: float) -> void:
	#temp += delta
	#
	#if temp > target_temp:
		#temp = 0.0
		#target_temp = rng.randf_range(0.1, 0.4)
		#talk()

# On a broad scale, call listening when the speaker is not talking anymore and call prepare_talk 
# when the speaker is in the talking phase

func matching():
	play("idle")
	
func prepare_talk():
	play("talk_idle")

# When in the respective phase, call these functions to start the specific animations
func nervous():
	play("nervous")
	
func talk():
	var target_intensity := intensity
	if rng.randf() < intensity_switch_chance:
		target_intensity = rng.randi_range(0, 2)
	
	play("talk_idle")
	match target_intensity:
		2:
			play("talk3")
		1:
			play("talk2")
		_:
			play("talk1")
			
	await animation_finished
	if current_state == SpeakerAnimationStates.TALK:
		current_state = SpeakerAnimationStates.TALK_IDLE

# Internal functions don't use
func load_philosopher():
	match philosopher:
		Philosopher.PIUS:
			sprite_frames = pius_resource
		Philosopher.CAESAR:
			sprite_frames = caesar_resource
	
	match current_state:
		SpeakerAnimationStates.MATCHING:
			matching()
		SpeakerAnimationStates.NERVOUS:
			nervous()
		SpeakerAnimationStates.TALK_IDLE, SpeakerAnimationStates.TALK:
			prepare_talk()
