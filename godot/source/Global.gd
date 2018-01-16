tool
extends Node

signal fullscreen_toggle(fullscreen)

var Game
var Map
var Players setget , _get_players 
var Platforms setget, _get_platforms
var Coins setget , _get_coins
var CoinSpawners setget , _get_coin_spawners

var crocodile

func player_blocked_by_platform(player):
	var slide_count = player.get_slide_count()
	if slide_count == 0:
		return false
	
	var collision = player.get_slide_collision(0)
	return collision.collider is Classes.Platform

func _get_coins():
	return get_tree().get_nodes_in_group("Coins")

func _get_players():
	return get_tree().get_nodes_in_group("Players")

func _get_platforms():
	return get_tree().get_nodes_in_group("Platforms")

func _get_coin_spawners():
	return get_tree().get_nodes_in_group("CoinSpawners")

func _process(delta):
	if _slo_mo_toggle_pressed():
		_switch_time_scale_for_slo_mo()
	elif Input.is_action_just_pressed("toggle_fullscreen"):
		toggle_fullscreen()

func toggle_fullscreen():
	OS.window_fullscreen = not OS.window_fullscreen
	emit_signal("fullscreen_toggle", OS.window_fullscreen)

func _slo_mo_toggle_pressed():
	return Input.is_action_just_pressed("slo_mo_toggle") and Debug.Settings.enable_slo_mo and OS.is_debug_build()

func _switch_time_scale_for_slo_mo():
	Engine.set_time_scale(Debug.Settings.slo_mo_scale if Engine.get_time_scale() == 1 else 1)