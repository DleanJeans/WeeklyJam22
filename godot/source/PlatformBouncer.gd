extends Node2D

onready var platform = get_parent()

func bounce_other_players_off(newcomer):
	var players = _get_affected_players(newcomer)
	
	_bounce_players_off(players)

func _get_affected_players(newcomer):
	var players = platform.get_players_fully_inside()
	players.erase(newcomer)
	
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
	var to_player = Utility.unit_vector_from(platform, player)
	var displacement = platform.compute_average_radius() * 0.75
	
	var landing_point = platform.position + to_player * displacement
	return landing_point