tool
extends Node

const COLLISION_NORMAL = 1 + 16
const COLLISION_BLOCKED = 1 + 2 + 16
const COLLISION_AIRBORNE = 16
const COLLISION_PLATFORM = 4

const JUMP_DURATION = 1

var Game
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
var CASHY_GREEN = Color("#0fe408")
var ICY_BLUE = Color("#7fb5e6")

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

func _process(delta):
	if Input.is_action_just_pressed("slo_mo_toggle") and ProjectSettings.get_setting("game/enable_slo_mo") and OS.is_debug_build():
		Engine.set_time_scale(ProjectSettings.get_setting("game/slo_mo_scale") if Engine.get_time_scale() == 1 else 1)
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	OS.set_window_fullscreen(not OS.is_window_fullscreen())

func timer(sec):
	return get_tree().create_timer(sec)