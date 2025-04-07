class_name Speaker extends Node2D

@export var match_font: Font
@export var match_font_args: String
@export var block_font: Font
@export var block_font_args: String
@export var manager: DialogueManager
@export var speech_duration = 10.0
@export var alignment: Alignment
@export var voice_map: LetterAudioMap

@onready var bust = %SpeakerAnimation
@onready var player = %MurmurPlayer
@onready var listener = %AudioListener2D
@onready var label = %DialogueLabel
@onready var dialogue_container = %HDialogueContainer
@onready var panel: PanelContainer = %Panel
@onready var bust_container = %HBustContainer
@onready var word_spawn_point = %WordSpawnPoint

enum State {
	SPEAKING,
	FINISHED_SPEAKING,
	THINKING
}

enum Alignment {
	LEFT,
	RIGHT
}

signal finished_speaking

var elapsed = 0.0
var char_delta = 0.0
var brainstorm_rate = 1
var brainstorm_probabability = 0.3
var brainstorm_force = 900
var state = State.FINISHED_SPEAKING
var url_format = "[color=coral]{word}[/color]"
var format = " [font n={font} {args}]{word}[/font]"

func _ready():
	var style_box: StyleBox = preload("res://dialogue/panel_style.tres")
	match alignment:
		Alignment.LEFT:
			bust.philosopher = 0
			dialogue_container.layout_direction = 2
			bust_container.layout_direction = 2
		Alignment.RIGHT:
			bust.philosopher = 1
			dialogue_container.layout_direction = 3
			bust_container.layout_direction = 3
			style_box.skew *= -1

func _process(delta: float) -> void:
	match state:
		State.SPEAKING:
			listener.make_current()
			if elapsed >= speech_duration:
				label.visible_ratio = 1
				state = State.FINISHED_SPEAKING
				elapsed = 0
				finished_speaking.emit()
				bust.matching()
			else:
				var cps = speech_duration / float(label.get_total_character_count())
				
				if char_delta >= cps:
					label.visible_characters += 1
					var c = label.get_parsed_text()[label.visible_characters - 1]
				
					if c != "" and c != " ":
						player.set_stream(voice_map[c])
						player.play()
						bust.talk()
					
					char_delta = 0
				else:
					char_delta += delta
				
				elapsed += delta
		State.THINKING:
			listener.make_current()
			if elapsed >= brainstorm_rate:
				elapsed = 0
				spawn_word(manager.get_weighted_selectable_word(brainstorm_probabability))
			else:
				elapsed += delta
				
func spawn_word(word: String):
	var word_obj = SelectableWord.new_word(word, 3, match_font)
	word_obj.position = word_spawn_point.global_position
	
	var angle = manager.rng.randf_range(-0.5, 0.5)
	var away: Vector2 = Vector2.UP * brainstorm_force

	word_obj.apply_central_impulse(away.rotated(angle))
	
	word_obj.clicked.connect(_on_word_clicked)
	add_child(word_obj)

func format_dialogue(dialogue: Array[Dictionary]):
	# Insert formatted bbCode text into label
	var text = ""

	for word in dialogue:
		var format_params = {
			"word": word.word,
			"font": match_font.resource_path,
			"args": match_font_args
		}
		
		# Update styles depending on word state
		match word.state:
			DialogueEnums.SelectionState.AESTHETIC:
				format_params.font = block_font.resource_path
				format_params.args = block_font_args
				
		# Append bbCode depending on word state
		if word.state == DialogueEnums.SelectionState.SELECTABLE:
			format_params.word = url_format.format({ "payload": word, "word": word.word })
		
		text += format.format(format_params)
		
	label.parse_bbcode(text)

func speak(dialogue: Array[Dictionary], duration: int = speech_duration):
	# Display dialog with typewriter effect
	label.clear()
	label.visible_characters = 0
	
	format_dialogue(dialogue)
	
	speech_duration = duration
	panel.visible = true
	state = State.SPEAKING
	
func hide_dialogue():
	panel.visible = false
	
func update_speech(dialogue: Array[Dictionary]):
	# Update text in place
	format_dialogue(dialogue)

func brainstorm(rate: float, probability: float) -> void:
	state = State.THINKING
	brainstorm_rate = rate
	brainstorm_probabability = probability

func _on_word_clicked(word: String):
	manager.match(word)
	pass
