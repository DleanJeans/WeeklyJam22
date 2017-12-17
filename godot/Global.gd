tool
extends Node

var Players setget , _get_players 
var Platforms setget, _get_platforms
var Coins setget , _get_coins
var CoinSpawners setget , _get_coin_spawners

var crocodile

var UP = Vector2(0, -1)
var DOWN = Vector2(0, 1)
var LEFT = Vector2(-1, 0)
var RIGHT = Vector2(1, 0)

var WHITE = Color("#ffffff")
var RED = Color("#ce0707")
var GREEN = Color("#007b2a")

var PLAYERS_GROUP = "Players"
var PLATFORMS_GROUP = "Platforms"

func _get_coins():
	return get_tree().get_nodes_in_group("Coins")

func _get_players():
	return get_tree().get_nodes_in_group("Players")

func _get_platforms():
	return get_tree().get_nodes_in_group("Platforms")

func _get_coin_spawners():
	return get_tree().get_nodes_in_group("CoinSpawners")