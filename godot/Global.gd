extends Node

onready var Players = get_tree().get_nodes_in_group("Players")
onready var Platforms = get_tree().get_nodes_in_group("Platforms")
var Coins setget , _get_coins

var crocodile

var UP = Vector2(0, -1)
var DOWN = Vector2(0, 1)
var LEFT = Vector2(-1, 0)
var RIGHT = Vector2(1, 0)

var WHITE = Color("#ffffff")
var CROCODILE_GREEN = Color("#14840e")

var PLAYERS_GROUP = "Players"
var PLATFORMS_GROUP = "Platforms"

func _get_coins():
	return get_tree().get_nodes_in_group("Coins")