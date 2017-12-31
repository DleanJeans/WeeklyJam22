tool
extends Node2D

func find_most_desired_player(me):
	var compute_player_desirability = funcref(self, "_player_desirability")
	var filter_player = funcref(self, "_filter_player")
	
	return Utility.find_max(me, Global.Players, compute_player_desirability, filter_player)

func _filter_player(me, player):
	return player == me

func _player_desirability(me, player):
	var distance = Utility.distance_squared(player, me)
	var distance_to_peers = _total_distance_to_peers(player) * 0.5
	var coins_collected = pow(player.coins, 3) + 100
	var base = 0.85 if player.on_platform else 1
	
	var good = coins_collected * base
	var bad = distance + distance_to_peers
	var desirability = good / bad
	
	return desirability

func _total_distance_to_peers(me):
	var distance = 0
	for player in Global.Players:
		if player == me or player.is_crocodile(): continue
		distance += Utility.distance_squared(player, me)
	return distance

func find_most_desired_platform(me):
	var compute_platform_desirability = funcref(self, "_platform_desirability")
	var filter_platform = funcref(self, "_filter_platform")
	
	return Utility.find_max(me, Global.Platforms, compute_platform_desirability, filter_platform)

func _filter_platform(me, platform):
	if Global.crocodile == null:
		return false
	
	var platform_dipped = platform.dipped()
	
	return platform_dipped

func _platform_desirability(me, platform):
	var distance_squared = Utility.distance_squared(me, platform)
	var distance_to_crocodile = 0 if Global.crocodile.frozen else Utility.distance_squared(platform, Global.crocodile)
	var crocodile_relative_dot = Utility.relative_dot_to(me, platform, Global.crocodile)
	var distance_to_peers = _platform_distance_to_peers(me, platform) * 10
	
	var good = distance_to_crocodile + distance_to_peers
	var bad = (crocodile_relative_dot + 1) * distance_squared + 1
	var desirability = good / bad
	
	return desirability

func _platform_distance_to_peers(me, platform):
	var distance = 0
	for player in Global.Players:
		if player == me or player.is_crocodile(): continue
		distance += Utility.distance_squared(player, platform)
	return distance

func find_most_desired_coin(me):
	var compute_coin_desirability = funcref(self, "_coin_desirability")
	var filter_coin = funcref(self, "_filter_coin")
	
	return Utility.find_max(me, Global.Coins, compute_coin_desirability, filter_coin)

func _filter_coin(me, coin):
	return coin.collected or Global.crocodile == null

func _coin_desirability(me, coin):
	var distance_to_peers = _distance_to_peers(me, coin)
	var distance_to_crocodile = Utility.distance_squared(coin, Global.crocodile)
	var distance = Utility.distance_squared(me, coin)
	var distance_to_other_coins = _distance_to_other_coins(me, coin)
	
	var good = distance_to_peers + distance_to_crocodile
	var bad = distance + distance_to_other_coins
	var desirability = good / bad
	
	return desirability

func _distance_to_peers(me, coin):
	var total_distance = 0
	
	for player in Global.Players:
		if player == me or player.is_crocodile(): continue
		
		var distance = Utility.distance_squared(player, coin)
		total_distance += distance

	return total_distance

func _distance_to_other_coins(me, coin):
	var total_distance = 0
	
	for c in Global.Coins:
		if c == coin or c.collected: continue
		
		var distance = Utility.distance_squared(c, coin)
		total_distance += distance

	return total_distance

func find_closest_coin(me):
	var compute_distance_squared = funcref(Utility, "distance_squared")
	var filter_coin = funcref(self, "_filter_coin")
	
	return Utility.find_min(me, Global.Coins, compute_distance_squared, filter_coin)

func find_closest_platform(me):
	var compute_distance_squared = funcref(Utility, "distance_squared")
	var filter_platform = funcref(self, "_filter_platform")
	
	return Utility.find_min(me, Global.Platforms, "distance_squared", "_filter_platform")