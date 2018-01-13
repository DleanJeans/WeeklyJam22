extends Node2D

signal game_loaded

signal countdown_started

signal game_started
signal game_over

signal game_paused
signal game_resumed

signal joining_screen_opened
signal main_menu_opened

var showing_winners = false
var winners = []

func open_joining_screen():
	emit_signal("joining_screen_opened")

func open_main_menu():
	$MainMenu.open()
	emit_signal("main_menu_opened")

func start_counting_down():
	if $GameTimer.is_counting_down(): return

	emit_signal("countdown_started")

func stop_counting_down():
	$GameTimer.stop()
	$GameTimer.hide()

func start():
	emit_signal("game_started")

func pause():
	emit_signal("game_paused")

func _pause_tree():
	get_tree().set_pause(true)

func resume():
	emit_signal("game_resumed")

func _resume_tree():
	get_tree().set_pause(false)

func end():
	emit_signal("game_over")

func show_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func stop_showing_winners():
	showing_winners = false

func _ready():
	Global.Game = self
	randomize()
	emit_signal("game_loaded")

func _show_winner():
	winners = $PlayerManager.players_with_highest_score()
	
	start_showing_winners()
	_process_winner_gui()
	_keep_winners_jumping()

func start_showing_winners():
	showing_winners = true

func _process_winner_gui():
	for p in winners:
		p.show_winner_label()
		p.hide_button_hint()

func _keep_winners_jumping():
	while showing_winners:
		for p in winners:
			p.force_jump()
		yield(Utility.timer(Const.JUMP_DURATION), "timeout")	

func _process(delta):
	if Input.is_action_just_pressed("reset_controllers"):
		$PlayerManager.reset_controllers()

func _unfreeze_if_in_game():
	if $GameTimer.in_round_mode():
		$PlayerManager.unfreeze_players()

func joypad_connected():
	return Input.get_connected_joypads().size() > 0