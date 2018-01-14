extends Node2D

signal player_jump(player)
signal player_get_coin(player)

var positions = []

func listen_to_players_collecting_coins():
	for player in Global.Players:
		player.connect("got_coins", self, "emit_signal", ["player_get_coin", player])

func enable_ai():
	for player in Global.Players:
		player.enable_ai()

func disable_ai():
	for player in Global.Players:
		player.disable_ai()

func reset_positions():
	$"../Map".reset_positions()

func reset_controllers():
	for player in Global.Players:
		player.controller = "AI"

func activate_controller(player_num, controller_name):
	if Global.Game.winner_jumping: return
	
	var random_player = _find_random_player()
	while random_player.controller != "AI":
		random_player = _find_random_player()
		
	random_player.controller = controller_name
	random_player.set_name_tag("P%s" % player_num)
	random_player.force_jump()
	emit_signal("player_jump", random_player)

func choose_crocodile_randomly():
	if Global.crocodile != null: return
	
	var random_player = _find_random_player()
	random_player.turn_crocodile()

func _find_random_player():
	var random_player_index = randi() % Global.Players.size()
	var random_player = Global.Players[random_player_index]
	
	return random_player

func freeze_players():
	for p in Global.Players:
		p.frozen = true

func unfreeze_players():
	for p in Global.Players:
		p.frozen = false

func reset():
	Global.crocodile = null
	for p in Global.Players:
		p.reset()

func resume_freeze_timer():
	Global.crocodile.get_node("FreezeTimer").set_paused(false)

func pause_freeze_timer():
	Global.crocodile.get_node("FreezeTimer").set_paused(true)