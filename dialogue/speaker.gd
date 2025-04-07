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
@onready var indicators_container = %IndicatorsContainer
@onready var word_spawn_point = %WordSpawnPoint

var correct_word_effect: PackedScene = preload("res://dialogue/correct_word_effect.tscn")
var wrong_word_effect: PackedScene = preload("res://dialogue/wrong_word_effect.tscn")
var active_timer: Timer

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

var selectable_format = "[color=aqua]%s[/color]"
var selected_format = "[color=dark_blue]%s[/color]"
var format = " [font n={font} {args}]{word}[/font]"

func _ready():
	var style_box: StyleBox = preload("res://dialogue/panel_style.tres")
	match alignment:
		Alignment.LEFT:
			bust.philosopher = 0
			dialogue_container.layout_direction = 2
			bust_container.layout_direction = 2
			indicators_container.layout_direction = 2
			%Lightbulb.global_position = %Lightbulb.get_parent().global_position
		Alignment.RIGHT:
			bust.philosopher = 1
			dialogue_container.layout_direction = 3
			bust_container.layout_direction = 3
			indicators_container.layout_direction = 3
			%Lightbulb.global_position = %Lightbulb.get_parent().global_position
			style_box.skew *= -1
			%MurmurPlayer.volume_db *= 0.75

func _process(delta: float) -> void:
	match state:
		State.SPEAKING:
			if label.visible_characters >= label.get_total_character_count() - 1:
				label.visible_ratio = 1
				state = State.FINISHED_SPEAKING
				elapsed = 0.0
				finished_speaking.emit()
				bust.prepare_talk()
				char_delta = 0.0
			else:
				var cps = speech_duration / float(label.get_total_character_count())
				
				if char_delta >= cps:
					label.visible_characters += 1
					var c = label.get_parsed_text()[label.visible_characters - 1]
				
					if c != "" and c != " ":
						player.set_stream(voice_map[c])
						player.play()
						bust.talk()
					char_delta -= cps
					
				char_delta += delta
		State.THINKING:
			%Gear.time_left = active_timer.time_left / manager.brainstorm_duration
			
			if active_timer.time_left < manager.brainstorm_duration * 0.5:
				bust.nervous()
			
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
	var text = "[color=pink]"

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
			DialogueEnums.SelectionState.SELECTABLE:
				format_params.word = selectable_format % word.word
			DialogueEnums.SelectionState.SELECTED:
				format_params.word = selected_format % word.word
		
		text += format.format(format_params)
		
	label.parse_bbcode(text + "[/color]")

func speak(dialogue: Array[Dictionary], duration: int = speech_duration):
	# Display dialog with typewriter effect
	label.clear()
	label.visible_characters = 0
	
	format_dialogue(dialogue)
	
	speech_duration = duration
	dialogue_container.visible = true
	#panel.visible = true 
	state = State.SPEAKING
	%Gear.time_left = 0.0
	%Gear.enabled = false
	%Lightbulb.fill = 0.0
	%Lightbulb.enabled = false
	
func hide_dialogue():
	dialogue_container.visible = false
	bust.matching()
	
func update_speech(dialogue: Array[Dictionary]):
	# Update text in place
	format_dialogue(dialogue)

func brainstorm(rate: float, probability: float, active_timer: Timer) -> void:
	state = State.THINKING
	bust.matching()
	brainstorm_rate = rate
	brainstorm_probabability = probability
	self.active_timer = active_timer
	%Gear.time_left = 1.0
	%Gear.enabled = true
	%Lightbulb.fill = 0.0
	%Lightbulb.enabled = true
	
func _on_word_clicked(word: String, location: Vector2):
	var correct: bool = manager.match(word)
	var effect_scene: Node
	if correct:
		effect_scene = correct_word_effect.instantiate()
	else:
		effect_scene = wrong_word_effect.instantiate()
		
	effect_scene.global_position = location
	add_child(effect_scene)
