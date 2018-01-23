extends Container

onready var MainMenu = Screens.MainMenu
onready var GameOverScreen = $"/root/Game/UI/GameOverScreen"
onready var game = Global.Game

func _process(delta):
	if Input.is_action_just_pressed("ui_start") and _is_pause_allowed():
		$SelectSound.play()
		if visible:
			_resume_game()
		else:
			_pause_game()

func _is_pause_allowed():
	var allowed = not (MainMenu.opened or GameOverScreen.showing or game.game_over)
	return allowed

func _pause_game():
	$ResumeButton.grab_focus()
	game.pause()
	show()

func _resume_game():
	game.resume()
	hide()

func _open_main_menu():
	_resume_game()
	game.open_main_menu()