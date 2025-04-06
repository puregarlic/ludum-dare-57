class_name DialogueManager extends Node2D

@onready var speakerLeft = $"SpeakerLeft"
@onready var speakerRight = $"SpeakerRight"

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
var speaker = Speaker.LEFT

var current_dialogue: Array[Dictionary]
var current_selectable: Array[Dictionary]
var selected_word: String
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
			"word": words[rand]
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
		Speaker.RIGHT:
			speakerRight.speak(current_dialogue)

func select_word(word: String):
	if selected_word == "":
		selected_word = word
	elif selected_word == word:
		# Good match
		selected_word = ""
	else:
		# Failed match
		selected_word = ""
		print("nope")

func fail():
	print("you lose")
