extends Node

@onready var dialogues_value_label = $MarginContainer/VBoxContainer/DialoguesContainer/DialoguesValue
@onready var fathoms_value_label = $MarginContainer/VBoxContainer/FathomsContainer/FathomsValue
@onready var grade_value_label = $MarginContainer/VBoxContainer/GradeContainer/GradeValue

@export var dialogues_completed: int = 0
@export var score_sound: AudioStream
@export var rank_sound: AudioStream

signal score_anim_over

const FATHOMS_PER_DIALOGUE = 5621

func _ready():
	dialogues_value_label.text = ""
	fathoms_value_label.text = ""
	grade_value_label.text = ""
	start_score_sequence()

func start_score_sequence():
	await get_tree().create_timer(1.2).timeout
	dialogues_value_label.text = str(dialogues_completed)
	play_sound(score_sound)

	await get_tree().create_timer(1.2).timeout
	var fathoms = dialogues_completed * FATHOMS_PER_DIALOGUE
	fathoms_value_label.text = str(fathoms)
	play_sound(score_sound)

	await get_tree().create_timer(1.9).timeout
	var grade = calculate_grade(dialogues_completed)
	grade_value_label.text = grade
	play_sound(rank_sound)

	await get_tree().create_timer(5.0).timeout

	var tween = create_tween()
	tween.tween_method(
		func(alpha): $ColorRect.color = Color(0, 0, 0, alpha),
		0.0, 1.0, 1.5
	)
	await tween.finished
	await get_tree().create_timer(1.5).timeout

	emit_signal("score_anim_over")
		
func calculate_grade(dialogues: int) -> String:
	if dialogues < 3:
		return "PHLEBOTOMIST"
	elif dialogues < 6:
		return "SCHOLAR"
	elif dialogues < 9:
		return "ORATOR"
	elif dialogues < 12:
		return "PHILOSOPHER"
	elif dialogues < 15:
		return "THE GREAT"
	else:
		return "IMMORTAL PERSUASION!"

func play_sound(stream: AudioStream):
	var player = AudioStreamPlayer.new()
	add_child(player)
	player.stream = stream
	player.play()
	var cleanup_timer = get_tree().create_timer(stream.get_length())
	cleanup_timer.timeout.connect(func(): player.queue_free())
