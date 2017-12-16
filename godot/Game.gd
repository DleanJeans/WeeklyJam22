extends Node2D

signal game_loaded
signal countdown_started
signal game_started
signal game_over

var showing_winner = false
var winners

func start_counting_down():
	_reset_players()
	_reset_platforms()
	emit_signal("countdown_started")
	showing_winner = false

func start():
	emit_signal("game_started")

func _reset_players():
	for p in Global.Players:
		p.reset()

func _reset_platforms():
	for p in Global.Platforms:
		p.reset()

func end():
	emit_signal("game_over")

func _ready():
	randomize()
	emit_signal("game_loaded")

func _show_winner():
	$PlayerManager._freeze_players()
	Global.crocodile.get_node("FreezeTimer").stop()
	showing_winner = true
	winners = _players_with_highest_score()

func _players_with_highest_score():
	var winner
	var winner2
	var highest_score = -INF
	
	for p in Global.Players:
		if p.is_crocodile(): continue
		if p.coins > highest_score:
			winner = p
			winner2 = null
			highest_score = p.coins
		elif p.coins == highest_score:
			winner2 = p
	
	if winner2 == null:
		return [winner]
	else: return [winner, winner2]

func _process(delta):
	if showing_winner:
		for p in winners:
			p.get_node("WinnerLabel").show()
			p.jump()
	
	if Input.is_action_just_pressed("slo_mo_toggle"):
		Engine.set_time_scale(ProjectSettings.get_setting("game/slo_mo_scale") if Engine.get_time_scale() == 1 else 1)