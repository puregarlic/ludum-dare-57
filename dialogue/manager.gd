class_name DialogueManager extends Node2D

@onready var speakerLeft: Speaker = $"SpeakerLeft"
@onready var speakerRight: Speaker = $"SpeakerRight"

@onready var successful_match_player = %MatchSuccess
@onready var failed_match_player = %MatchFail
@onready var idea = %Idea

enum State {
	SPEAKING,
	MATCHING
}

enum SpeakerSide {
	LEFT,
	RIGHT
}

var words: Array[String]
var words_length: int
var rng = RandomNumberGenerator.new()

var state = State.SPEAKING
var speaker: SpeakerSide = SpeakerSide.RIGHT

var current_dialogue: Array[Dictionary]
var current_selectable: Array[Dictionary]
var selection_threshold: float = 0.1
var correct_selections: int = 0
var score: int = 0

var dialogue_length: int = 10
var selectable_ratio: float = 0.3
signal failed

func _ready():
	var words_string = FileAccess.get_file_as_string("res://dialogue/dictionary.json")
	var words_dict = JSON.parse_string(words_string)

	for key in words_dict.keys():
		words.push_back(key)

	words_length = len(words)
	next_dialogue()
	
func next_dialogue():
	var dialogue: Array[Dictionary] = []
	var selectable: Array[Dictionary] = []
	var indices = []

	while len(indices) < round(dialogue_length * selectable_ratio):
		var rand = rng.randi_range(0, dialogue_length - 1)
		
		# Ensure no repeats or adjacent selectable words
		if not indices.has(rand) and not indices.has(rand + 1) and not indices.has(rand - 1):
			indices.push_back(rand)
	
	for n in dialogue_length:
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
	# Update state
	state = State.SPEAKING
	idea.play()
	
	# Instruct new speaker to recite dialogue
	match speaker:
		SpeakerSide.LEFT:
			speaker = SpeakerSide.RIGHT
			speakerRight.speak(current_dialogue)
			speakerLeft.hide_dialogue()
		SpeakerSide.RIGHT:
			speaker = SpeakerSide.LEFT
			speakerLeft.speak(current_dialogue)
			speakerRight.hide_dialogue()

func match(word: String):
	var idx = current_selectable.find_custom(func (dict: Dictionary):
		return dict.word == word)
		
	if idx >= 0:
		successful_match_player.play()
		correct_selections += 1
		var dict = current_selectable[idx]
		current_dialogue[dict.index].state = DialogueEnums.SelectionState.SELECTED
		current_selectable.remove_at(idx)
		
		if correct_selections / len(current_selectable) >= selection_threshold:
			score += 1
			correct_selections = 0
			next_dialogue()
	else:
		failed_match_player.play()
		
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
	emit_signal("failed")

func _on_speaker_left_finished_speaking() -> void:
	speakerRight.brainstorm(0.3, 1)

func _on_speaker_right_finished_speaking() -> void:
	speakerLeft.brainstorm(0.3, 1)
