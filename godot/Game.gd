extends Node2D

signal game_loaded
signal countdown_started
signal game_started
signal game_over
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
	get_tree().set_pause(true)

func resume():
	get_tree().set_pause(false)

func end():
	emit_signal("game_over")

func _ready():
	randomize()
	emit_signal("game_loaded")

func _show_winner():
	showing_winner = true
	winners = $PlayerManager.players_with_highest_score()

func _stop_showing_winner():
	showing_winner = false
#	for p in winners:
#		p.hide_winner_label()

func _process(delta):
	if showing_winner:
		for p in winners:
			p.show_winner_label()
			p.jump()

func _unfreeze_if_in_game():
	if $GameTimer.in_round_mode():
		$PlayerManager.unfreeze_players()