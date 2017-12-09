extends Node2D

func _ready():
	randomize()
	_choose_random_crocodile()

func _choose_random_crocodile():
	var players = get_tree().get_nodes_in_group("Players")
	var random_player_index = randi() % players.size()
	var random_player = players[random_player_index]
	random_player.turn_crocodile()