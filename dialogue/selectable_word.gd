class_name SelectableWord extends RigidBody2D

@onready var pill: CollisionShape2D = $CollisionShape2D
@onready var label: RichTextLabel = $Label
@onready var timer: Timer = $Timer

@export var hover_tint: Color = Color.WHITE

signal clicked

const scene: PackedScene = preload("res://dialogue/selectable_word.tscn")
const word_format = "[font n={font}]{word}[/font]"

var word: String
var raw_word: String
var lifetime: float = 1.0

func _ready() -> void:
	pill.shape.height = label.get_content_width()
	label.parse_bbcode(word)
	timer.wait_time = lifetime
	timer.start()

static func new_word(word: String, lifetime: float, font: Font) -> SelectableWord:
	var word_scene = scene.instantiate()
	word_scene.raw_word = word
	word_scene.word = word_format.format({ "font": font.resource_path, "word": word })
	word_scene.lifetime = lifetime
	
	return word_scene

func _on_timer_timeout() -> void:
	# Delete self
	queue_free()
	
func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		emit_signal("clicked", raw_word, global_position)
		queue_free()

func _on_mouse_entered() -> void:
	%Label.modulate = hover_tint

func _on_mouse_exited() -> void:
	%Label.modulate = Color.WHITE
