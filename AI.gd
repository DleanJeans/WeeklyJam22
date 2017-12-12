extends Node2D

onready var player = get_parent()

func _process(delta):
	if player.controller != "AI": return 
	
	if player.is_crocodile():
		var target_position = _find_nearest_player_position()
		var vector_to_nearest = target_position - player.position
		
		player.velocity += _get_max_velocity_vector(vector_to_nearest)
		player.clamp_velocity()
	else:
		var crocodile_position = _find_crocodile_position()
		var platform_position = _find_nearest_platform_position()
		
		var distance_to_crocodile = player.position.distance_to(crocodile_position)
		var vector_away_from_crocodile = player.position - crocodile_position
		var vector_to_platform = platform_position - player.position
		var vector_away_from_platform = -vector_to_platform
		
		if not player.on_platform:
			player.velocity += _get_max_velocity_vector(vector_away_from_crocodile)
			player.velocity += _get_max_velocity_vector(vector_to_platform) * 2
			player.clamp_velocity()
		elif distance_to_crocodile > 200:
			player.velocity += _get_max_velocity_vector(vector_away_from_platform)
			player.clamp_velocity()

func _get_max_velocity_vector(vector):
	return vector.normalized() * player.max_velocity

func _find_nearest_platform_position():
	var nearest = player.position
	var nearest_distance = INF
	
	for plat in Global.Platforms:
		if plat == player.last_visited_platform: continue
		
		var distance_to_platform = player.position.distance_to(plat.position)
		if distance_to_platform < nearest_distance:
			nearest = plat
			nearest_distance = distance_to_platform
	
	return nearest.position

func _find_crocodile_position():
	var players = Global.Players
	
	for p in players:
		if p.is_crocodile():
			return p.position
	return Vector2()

func _find_nearest_player_position():
	var nearest_distance = INF
	var nearest = player.position
	
	for p in Global.Players:
		if p == player or p.on_platform: continue
		
		var distance_to_player = player.position.distance_to(p.position)
		if distance_to_player < nearest_distance:
			nearest_distance = distance_to_player
			nearest = p.position
	
	return nearest