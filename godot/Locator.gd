tool
extends Node2D

export(int) var vicinity = 100 setget _set_vicinity

func find_most_desired_player(me):
	return _find_max(me, Global.Players, "_filter_player", "_player_desirability")

func _filter_player(me, player):
	return player == me or player.on_platform

func _player_desirability(me, player):
	var distance = distance_squared(player, me)
	var distance_to_peers = _total_distance_to_peers(player)
	var coins_collected = player.coins / 10
	
	var good = coins_collected
	var bad = distance * distance_to_peers + 1
	
	var desirability = good / bad
	
	return desirability

func _total_distance_to_peers(me):
	var distance = 0
	for player in Global.Players:
		if player == me or player.is_crocodile(): continue
		distance += distance_squared(player, me)
	return distance

func distance(node1, node2):
	return node1.position.distance_to(node2.position)

func distance_squared(node1, node2):
	return node1.position.distance_squared_to(node2.position)

func find_most_desired_platform(me):
	return _find_max(me, Global.Platforms, "_filter_platform", "_platform_desirability")

func _filter_platform(me, platform):
	return platform.occupied

func _platform_desirability(me, platform):
	var distance = distance_squared(me, platform)
	var distance_to_crocodile = distance_squared(platform, Global.crocodile)
	var crocodile_relative_direction = _relative_direction(me.position, platform.position, Global.crocodile.position)
	
	var good = distance_to_crocodile
	var bad = (1 + crocodile_relative_direction) + distance
	
	var desirability = good / bad
	
	return desirability

func _relative_direction(origin, position1, position2):
	var to_position1 = (position1 - origin).normalized()
	var to_position2 = (position2 - origin).normalized()
	var dot = to_position1.dot(to_position2)
	var relative_direction = acos(dot)
	
	return relative_direction

func find_most_desired_coin(me):
	return _find_max(me, Global.Coins, "_filter_coin", "_coin_desirability")

func _filter_coin(me, coin):
	if coin.collected:
		return coin.collected
	
	for player in Global.Players:
		if player == me: continue

		var their_distance_to_coin = distance(player, coin)
		var my_distance_to_coin = distance(me, coin)

		var their_duration_to_coin = their_distance_to_coin / (player.velocity.length() + 1)
		var my_duration_to_coin = my_distance_to_coin / player.max_velocity

		if their_distance_to_coin < my_duration_to_coin:
			return true
	
	return false

func _coin_desirability(me, coin):
	var distance_to_peers = _distance_to_peers(me, coin)
	var distance_to_crocodile = distance_squared(coin, Global.crocodile)
	var distance = distance_squared(me, coin)
	var distance_to_other_coins = _distance_to_other_coins(me, coin)
	
	var good = distance_to_peers * distance_to_crocodile
	var bad = distance * distance_to_other_coins + 1
	
	return good / bad

func _distance_to_peers(me, coin):
	var total_distance = 0
	
	for player in Global.Players:
		if player == me or player.is_crocodile(): continue
		
		var distance = distance_squared(player, coin)
		total_distance += distance
	
	return total_distance

func _distance_to_other_coins(me, coin):
	var total_distance = 0
	
	for c in Global.Coins:
		if c == coin or c.collected: continue
		
		var distance = distance_squared(c, coin)
		total_distance += distance
	
	return total_distance

func find_closest_coin(me):
	return _find_min(me, Global.Coins, "_filter_coin", "distance_squared")

func find_closest_platform(me):
	return _find_min(me, Global.Platforms, "_filter_platform", "distance_squared")

func _find_max(me, objects, filter, calculate_points):
	var highest_points = -INF
	var best_candidate
	
	for object in objects:
		if call(filter, me, object): continue
		
		var points = call(calculate_points, me, object)
		if points > highest_points:
			highest_points = points
			best_candidate = object
	
	return best_candidate

func _find_min(me, objects, filter, calculate_points):
	var lowest_points = INF
	var best_candidate
	
	for object in objects:
		if call(filter, me, object): continue
		
		var points = call(calculate_points, me, object)
		if points < lowest_points:
			lowest_points = points
			best_candidate = object
	
	return best_candidate

func _set_vicinity(value):
	vicinity = value
	if has("Vicinity/Shape"):
		$Vicinity/Shape.shape.radius = value / 2