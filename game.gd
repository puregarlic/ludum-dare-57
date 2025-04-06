extends Node3D

enum GameState { MAIN_MENU, GAME, LOSS }
var current_game_state: GameState = GameState.MAIN_MENU
var dialogue_manager = preload("res://dialogue/manager.tscn")

func _ready():
	$MainMenu.main_menu_interacted.connect(_on_main_menu_interacted)
	$ScrollingBackgroundEngine.call_anim("anim_mainmenu_slow", [])
	
func transition():
	if current_game_state == GameState.MAIN_MENU:
		current_game_state = GameState.GAME
	elif current_game_state == GameState.GAME:
		current_game_state = GameState.LOSS
	elif current_game_state == GameState.LOSS:
		current_game_state = GameState.GAME
		
func _on_main_menu_interacted():
	transition()
	$ScrollingBackgroundEngine.call_anim("anim_mainmenu_speedup", [])
	add_child(dialogue_manager.instantiate())
