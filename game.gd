extends Node3D

enum GameState { MAIN_MENU, GAME, LOSS }
var current_game_state: GameState = GameState.MAIN_MENU
var dialogue_manager = preload("res://dialogue/manager.tscn")
var score_screen = preload("res://menu/score_summary.tscn")
var manager

func _ready():
	$MainMenu.main_menu_interacted.connect(_on_main_menu_interacted)
	$ScrollingBackgroundEngine.call_anim("anim_mainmenu_slow", [])
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer2.timeout.connect(transition)
	
func transition():
	if current_game_state == GameState.MAIN_MENU:
		current_game_state = GameState.GAME
		$Timer.start()
		$Timer2.start()
		%MenuAmbiance.stop()
		%BackGroundMusic.play()
	elif current_game_state == GameState.GAME:
		current_game_state = GameState.LOSS
		manager.queue_free()
		$Timer.stop()
		%BackGroundMusic.stop()
		%TheEndSound.play()
		$ScrollingBackgroundEngine.end_it()
		$ScrollingBackgroundEngine.loss_anim_complete.connect(_my_final_message)
	elif current_game_state == GameState.LOSS:
		current_game_state = GameState.GAME
		$Timer.start()
		%MenuAmbiance.stop()
		%BackGroundMusic.play()
		
func _on_main_menu_interacted():
	transition()
	$ScrollingBackgroundEngine.call_anim("anim_mainmenu_speedup", [])
	manager = dialogue_manager.instantiate()
	add_child(manager)
	manager.failed.connect(_on_loss)

func _on_timer_timeout():
	$ScrollingBackgroundEngine.transition_to_next()
	
func _on_loss():
	transition()

func _my_final_message():
	%TheEndSound.stop()
	await get_tree().create_timer(2.0).timeout
	add_child(score_screen.instantiate())
