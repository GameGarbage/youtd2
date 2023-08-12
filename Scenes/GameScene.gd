extends Node


enum GameState {
	PREGAME,
	TUTORIAL,
	PLAYING,
	PAUSED,
}


@onready var map_node: Node2D = $Map
@onready var _pregame_hud: Control = $UI/PregameHUD
@onready var _pause_hud: Control = $UI/PauseHUD
@onready var _wave_spawner: WaveSpawner = $Map/WaveSpawner
@onready var _tutorial_menu: TutorialMenu = $UI/TutorialMenu

var _game_state: GameState


func _ready():
	print_verbose("GameScene has loaded.")

	_game_state = GameState.PREGAME
	get_tree().set_pause(true)

	var show_pregame_settings_menu: bool = Config.show_pregame_settings_menu()

	if show_pregame_settings_menu:
		_pregame_hud.show()
	else:
#		Skip pregame settings menu and load default values
		var default_wave_count: int = Config.default_wave_count()
		var default_game_mode: GameMode.enm = Config.default_game_mode()
		var default_difficulty: Difficulty.enm = Config.default_difficulty()
		var default_tutorial_enabled: bool = Config.default_tutorial_enabled()

		_on_pregame_hud_finished(default_wave_count, default_game_mode, default_difficulty, default_tutorial_enabled)


func _unhandled_input(event: InputEvent):
	var pause_pressed: bool = event.is_action_released("pause")
	
	if pause_pressed:
		match _game_state:
			GameState.PLAYING: _pause_the_game()
			GameState.PAUSED: _unpause_the_game()


func _on_HUD_start_wave(wave_index):
	$Map/CreepSpawner.start(wave_index)


func _on_HUD_stop_wave():
	$Map/CreepSpawner.stop()


# TODO: use game_mode setting
func _on_pregame_hud_finished(wave_count: int, game_mode: GameMode.enm, difficulty: Difficulty.enm, tutorial_enabled: bool):
	get_tree().set_pause(false)
	
	_pregame_hud.hide()

	var difficulty_string: String = Difficulty.convert_to_string(difficulty).to_upper()

	Messages.add_normal("Welcome to youtd 2!")
	Messages.add_normal("Game settings: %d waves, %s difficulty" % [wave_count, difficulty_string])
	Messages.add_normal("You can pause the game by pressing F10")

	_wave_spawner.generate_waves(wave_count, difficulty)
	
	if tutorial_enabled:
		_game_state = GameState.TUTORIAL
		_tutorial_menu.show()
	else:
		_on_tutorial_menu_finished()

	Globals.game_mode = game_mode
	EventBus.game_mode_was_chosen.emit()


func _pause_the_game():
#	Cancel any in progress mouse actions
	BuildTower.cancel()
	ItemMovement.cancel()
	SelectTargetForCast.cancel()

	_game_state = GameState.PAUSED
	get_tree().set_pause(true)
	_pause_hud.show()


func _unpause_the_game():
	_game_state = GameState.PLAYING
	get_tree().set_pause(false)
	_pause_hud.hide()


func _on_pause_hud_resume_pressed():
	_unpause_the_game()


func _on_tutorial_menu_finished():
	_game_state = GameState.PLAYING
	_tutorial_menu.hide()
	_wave_spawner.start_initial_timer()

	Messages.add_normal("The first wave will spawn in 2 minutes.")
	Messages.add_normal("You can start the first wave early by pressing on [color=GOLD]Start next wave[/color].")
