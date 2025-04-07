extends Node3D

enum GameState { MAIN_MENU, GAME, LOSS }
var current_game_state: GameState = GameState.MAIN_MENU
var dialogue_manager = preload("res://dialogue/manager.tscn")
var score_screen = preload("res://menu/score_summary.tscn")
var manager
var num_dialogues_completed := 0

func _ready():
	$MainMenu.main_menu_interacted.connect(_on_main_menu_interacted)
	$ScrollingBackgroundEngine.call_anim("anim_mainmenu_slow", [])
	$Timer.timeout.connect(_on_timer_timeout)
	
func transition():
	if current_game_state == GameState.MAIN_MENU:
		current_game_state = GameState.GAME
		$Timer.start()
		%MenuAmbiance.stop()
		%BackGroundMusic.play()
	elif current_game_state == GameState.GAME:
		current_game_state = GameState.LOSS
		num_dialogues_completed = manager.score
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
	var end_screen = score_screen.instantiate()
	end_screen.dialogues_completed = num_dialogues_completed
	end_screen.score_anim_over.connect(_reload_self)
	add_child(end_screen)

func _reload_self():
	get_tree().reload_current_scene()
