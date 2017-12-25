extends Node2D

signal game_loaded

signal countdown_started

signal game_started
signal game_over

signal game_paused
signal game_resumed

signal joining_screen_opened
signal main_menu_opened

var showing_winner = false
var winners = []

func open_joining_screen():
	emit_signal("joining_screen_opened")

func open_main_menu():
	$MainMenu.show()
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

func _ready():
	Global.Game = self
	randomize()
	emit_signal("game_loaded")

func _show_winner():
	showing_winner = true
	winners = $PlayerManager.players_with_highest_score()

func _stop_showing_winner():
	showing_winner = false

func _process(delta):
	if showing_winner:
		for p in winners:
			p.show_winner_label()
			p.force_jump()
			p.hide_button_hint()
	if Input.is_action_just_pressed("reset_controllers"):
		$PlayerManager.reset_controllers()

func _unfreeze_if_in_game():
	if $GameTimer.in_round_mode():
		$PlayerManager.unfreeze_players()