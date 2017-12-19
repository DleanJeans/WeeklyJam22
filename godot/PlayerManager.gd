extends Node2D

var positions = []

func _ready():
	record_positions()

func record_positions():
	positions.clear()
	for player in Global.Players:
		positions.append(player.position)

func reset_positions():
	var i = 0
	for player in Global.Players:
		player.position = positions[i]
		i += 1

func reset_controllers():
	for player in Global.Players:
		player.controller = "AI"

func activate_controller(player_num, controller_name):
	var random_player = _find_random_player()
	while random_player.controller != "AI":
		random_player = _find_random_player()
		
	random_player.controller = controller_name
	random_player.set_name_tag( "P%s" % player_num)
	random_player.jump()

func choose_crocodile_randomly():
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
	for p in Global.Players:
		p.reset()
