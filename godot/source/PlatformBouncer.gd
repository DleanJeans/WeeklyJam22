extends Node2D

onready var platform = get_parent()

var _newcomer

func bounce_other_players_off(newcomer):
	_newcomer = newcomer
	var players = _get_affected_players()
	_bounce_players_off(players)

func _get_affected_players():
	var players = platform.get_players_fully_inside()
	players.erase(_newcomer)
	
	for player in players:
		if not player.on_platform:
			players.erase(player)
	
	return players

func _bounce_players_off(players):
	for player in players:
		_bounce_off(player)
	_start_tween()

func _start_tween():
	$Tween.start()

func _bounce_off(player):
	_start_animation(player)
	_set_tween_to_landing_point(player)

func _start_animation(player):
	player.bounce()

func _set_tween_to_landing_point(player):
	var landing_point = _compute_landing_point(player)
	$Tween.interpolate_property(player, "position", player.position, landing_point, Const.BOUNCE_AIRBONE_TIME, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

func _compute_landing_point(player):
	var start_position = _newcomer.position
	
	var newcomer_to_player = Utility.unit_vector_from(_newcomer, player)
	var platform_size = platform.get_size()
	var distance = newcomer_to_player * platform_size
	
	var landing_point = start_position + distance
	
	return landing_point