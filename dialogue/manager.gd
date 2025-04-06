class_name DialogueManager extends Node2D

@onready var speakerLeft: Speaker = $"SpeakerLeft"
@onready var speakerRight: Speaker = $"SpeakerRight"

enum State {
	SPEAKING,
	MATCHING
}

enum Speaker {
	LEFT,
	RIGHT
}

var words: Array[String]
var words_length: int
var rng = RandomNumberGenerator.new()

var state = State.SPEAKING
@export var speaker = Speaker.LEFT

var current_dialogue: Array[Dictionary]
var current_selectable: Array[Dictionary]
var threshold: float

func _ready():
	var words_string = FileAccess.get_file_as_string("res://dialogue/dictionary.json")
	var words_dict = JSON.parse_string(words_string)

	for key in words_dict.keys():
		words.push_back(key)

	words_length = len(words)
	next_dialogue(10, 0.3)
	
func next_dialogue(length: int, ratio: float):
	var dialogue: Array[Dictionary] = []
	var selectable: Array[Dictionary] = []
	var indices = []

	while len(indices) < round(length * ratio):
		var rand = rng.randi_range(0, length - 1)
		
		# Ensure no repeats or adjacent selectable words
		if not indices.has(rand) and not indices.has(rand + 1) and not indices.has(rand - 1):
			indices.push_back(rand)
	
	for n in length:
		var rand = rng.randi_range(0, words_length - 1)
		var word = {
			"index": n,
			"word": words[rand],
		}
		
		if indices.has(n):
			word.state = DialogueEnums.SelectionState.SELECTABLE
			selectable.push_back(word)
		else:
			word.state = DialogueEnums.SelectionState.AESTHETIC
			
		dialogue.push_back(word)

	current_dialogue = dialogue
	current_selectable = selectable
	
	speak_dialogue()

func speak_dialogue():
	# Swap current speaker
	if speaker == Speaker.LEFT:
		speaker == Speaker.RIGHT
	else:
		speaker == Speaker.LEFT
		
	# Update state
	state = State.SPEAKING
	
	# Instruct new speaker to recite dialogue
	match speaker:
		Speaker.LEFT:
			speakerLeft.speak(current_dialogue)
			speakerRight.hide_dialogue()
		Speaker.RIGHT:
			speakerRight.speak(current_dialogue)
			speakerLeft.hide_dialogue()

func select_word(word: String):
	print("nope")

func get_random_word() -> String:
		var rand = rng.randi_range(0, words_length - 1)
		return words[rand]
		
func get_random_selectable_word() -> String:
		var rand = rng.randi_range(0, len(current_selectable) - 1)
		return current_selectable[rand].word

func get_weighted_selectable_word(weight: float) -> String:
	var correct_or_not = rng.rand_weighted(PackedFloat32Array([weight, 1]))
	
	match correct_or_not:
		0:
			return get_random_selectable_word()
		_:
			return get_random_word()

func fail():
	print("you lose")

func _on_speaker_left_finished_speaking() -> void:
	speakerRight.brainstorm(0.3, 1)

func _on_speaker_right_finished_speaking() -> void:
	speakerLeft.brainstorm(0.3, 1)
