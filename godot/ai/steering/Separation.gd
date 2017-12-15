tool
extends "res://ai/steering/SteeringBehavior.gd"

export(int) var separation_range = 50 setget _set_separation_range

func execute():
	return separate() * multiplier

func separate():
	var velocity = Vector2()
	
	for player_in_range in _get_players_in_range():
		var to_me = player.position - player_in_range.position
		velocity += to_me.normalized() / to_me.length() * 100
	
	return velocity

func _get_players_in_range():
	var players = []
	
	for body in $SeparationCircle.get_overlapping_bodies():
		if body is preload("res://Player.gd") and body != player:
			players.append(body)
	
	return players

func _set_separation_range(value):
	separation_range = value
	if has_node("SeparationCircle/Shape"):
		$SeparationCircle/Shape.shape.radius = value