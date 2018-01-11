tool
extends Node

var Game
var Players setget , _get_players 
var Platforms setget, _get_platforms
var Coins setget , _get_coins
var CoinSpawners setget , _get_coin_spawners

var crocodile

func toggle_fullscreen():
	OS.set_window_fullscreen(not OS.is_window_fullscreen())

func player_blocked_by_platform(player):
	var slide_count = player.get_slide_count()
	if slide_count == 0:
		return false
	
	var collision = player.get_slide_collision(0)
	return collision.collider is Classes.Platform

func _process(delta):
	if Input.is_action_just_pressed("slo_mo_toggle") and ProjectSettings.get_setting("game/enable_slo_mo") and OS.is_debug_build():
		Engine.set_time_scale(ProjectSettings.get_setting("game/slo_mo_scale") if Engine.get_time_scale() == 1 else 1)
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func _get_coins():
	return get_tree().get_nodes_in_group("Coins")

func _get_players():
	return get_tree().get_nodes_in_group("Players")

func _get_platforms():
	return get_tree().get_nodes_in_group("Platforms")

func _get_coin_spawners():
	return get_tree().get_nodes_in_group("CoinSpawners")