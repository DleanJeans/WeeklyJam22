extends Node2D

var player_positions = []

func start():
	$ControllerAssigner.reset()
	for p in Global.Players:
		p.reset()
		p.turn_normal()
	_choose_random_crocodile()
	_reset_player_positions()

func _ready():
	randomize()
	_record_players_position()
	_choose_random_crocodile()

func _record_players_position():
	for player in Global.Players:
		player_positions.append(player.position)

func _reset_player_positions():
	var i = 0
	for player in Global.Players:
		player.position = player_positions[i]
		i += 1

func _choose_random_crocodile():
	var random_player = _find_random_player()
	
	random_player.turn_crocodile()

func _activate_controller(player_num, controller_name):
	var random_player = _find_random_player()
	while random_player.controller != "AI":
		random_player = _find_random_player()
		
	random_player.controller = controller_name
	random_player.get_node("NameTag").text = "P%s" % player_num

func _find_random_player():
	var players = Global.Players
	var random_player_index = randi() % players.size()
	var random_player = players[random_player_index]
	
	return random_player