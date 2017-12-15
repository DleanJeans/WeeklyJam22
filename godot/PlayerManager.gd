extends Node2D

onready var players = Global.Players
var positions = []

func _ready():
	_record_positions()

func _record_positions():
	for player in players:
		positions.append(player.position)

func _reset_positions():
	var i = 0
	for player in players:
		player.position = positions[i]
		i += 1

func _reset_controllers():
	for player in players:
		player.controller = "AI"

func _activate_controller(player_num, controller_name):
	var random_player = _find_random_player()
	while random_player.controller != "AI":
		random_player = _find_random_player()
		
	random_player.controller = controller_name
	random_player.set_name_tag( "P%s" % player_num)
	random_player.jump()

func _choose_random_crocodile():
	var random_player = _find_random_player()
	random_player.turn_crocodile()

func _find_random_player():
	var random_player_index = randi() % players.size()
	var random_player = players[random_player_index]
	
	return random_player

func _unfreeze_players():
	for p in players:
		p.toggle_frozen()