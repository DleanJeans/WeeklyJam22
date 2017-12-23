extends Container

onready var MainMenu = $"../MainMenu"
onready var game = get_parent()

func _process(delta):
	if Input.is_action_just_pressed("ui_start") and not MainMenu.visible:
		$SelectSound.play()
		if visible:
			_resume_game()
		else:
			_pause_game()

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