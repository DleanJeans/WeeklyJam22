extends Node2D

signal game_loaded
signal countdown_started
signal game_started
signal game_over

func start_counting_down():
	_reset_players()
	emit_signal("countdown_started")

func start():
	emit_signal("game_started")

func _reset_players():
	for p in Global.Players:
		p.reset()

func end():
	emit_signal("game_over")

func _ready():
	randomize()
	emit_signal("game_loaded")

func _choose_random_crocodile():
	pass # replace with function body


func _unfreeze_players():
	pass # replace with function body
