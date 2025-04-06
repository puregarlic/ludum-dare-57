class_name Speaker extends Node2D

@export var match_font: Font
@export var match_font_args: String
@export var block_font: Font
@export var block_font_args: String
@export var manager: DialogueManager
@export var speech_duration = 10.0
@export var alignment: Alignment
@export var voice_map: LetterAudioMap

@onready var player = %AudioStreamPlayer2D
@onready var label = %DialogueLabel
@onready var container = %HBoxContainer

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
var state = State.FINISHED_SPEAKING
var url_format = "[url={payload}]{word}[/url]"
var format = " [font n={font} {args}]{word}[/font]"

func _ready():
	match alignment:
		Alignment.LEFT:
			container.layout_direction = 2
		Alignment.RIGHT:
			container.layout_direction = 3

func _process(delta: float) -> void:
	match state:
		State.SPEAKING:
			if elapsed >= speech_duration:
				label.visible_ratio = 1
				state = State.FINISHED_SPEAKING
				elapsed = 0
				finished_speaking.emit()
			else:
				var cps = speech_duration / float(label.get_total_character_count())
				
				if char_delta >= cps:
					label.visible_characters += 1
					var c = label.get_parsed_text()[label.visible_characters - 1]
				
					if c != "" and c != " ":
						player.set_stream(voice_map[c])
						player.play()
					
					char_delta = 0
				else:
					char_delta += delta
				
				elapsed += delta

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
	state = State.SPEAKING
	
func update_speech(dialogue: Array[Dictionary]):
	# Update text in place
	format_dialogue(dialogue)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	# Word has been selected. Notify manager
	print(meta)
