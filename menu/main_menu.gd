extends Node

@onready var pius = $PiusBounceTarget/Pius
@onready var menu_text = $MenutextBounceTarget/Menutext
@onready var caesar = $CaesarBounceTarget/Caesar
@onready var control_ui = $Control
@onready var root = self

signal main_menu_interacted

var input_received = false

func _input(event):
	if input_received:
		return

	if event is InputEventKey or event is InputEventMouseButton:
		input_received = true
		control_ui.visible = false
		replace_with_falling_body(menu_text)
		replace_with_falling_body(pius)
		replace_with_falling_body(caesar)
		emit_signal("main_menu_interacted")

func replace_with_falling_body(node: Node2D):
	var global_pos = node.global_position

	var body := RigidBody2D.new()
	body.gravity_scale = 1
	body.position = global_pos
	body.global_position = global_pos

	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.extents = Vector2(20, 20)
	shape.shape = rect_shape
	body.add_child(shape)

	var parent = node.get_parent()
	parent.remove_child(node)
	body.add_child(node)
	node.position = Vector2.ZERO
	root.add_child(body)

	var x_force = randf_range(-300.0, 300.0)
	var y_force = randf_range(400.0, -100.0)
	body.apply_impulse(Vector2(x_force, y_force))
