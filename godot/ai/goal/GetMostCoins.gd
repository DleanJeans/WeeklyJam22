extends "res://ai/goal/Goal.gd"

var fleeing_radius = 250

var FleeCrocodile = load("res://ai/goal/FleeCrocodile.gd")
var GoGetCoin = load("res://ai/goal/GoGetCoin.gd")
var ArriveAtPlatform = load("res://ai/goal/ArriveAtPlatform.gd")

func _ready():
	_name = "GetMostCoins"

func activate():
	.activate()
	steering.separation_on()

func process():
	.process()
	
	if player.is_crocodile():
		state = GOAL_FAILED
	
	if _should_flee():
		var subgoal = ArriveAtPlatform
		
		if player.on_platform:
			return
		elif _goal_not_active_already(subgoal):
			clear_subgoals()
			add_subgoal(subgoal.new())
	
	if _has_subgoals(): return
	
	if _should_go_after_coins():
		add_subgoal(GoGetCoin.new())
	elif _should_get_on_platform():
		add_subgoal(ArriveAtPlatform.new())

func _should_flee():
	if Global.crocodile == null: return false
	
	var targeted_by_crocodile = _targeted_by_crocodile()
	var crocodile_is_close = _crocodile_is_close()
	var crocodile_almost_unfrozen = Global.crocodile.almost_unfrozen()
	
	return crocodile_almost_unfrozen and (crocodile_is_close or targeted_by_crocodile)

func _crocodile_is_close():
	var distance_squared = Utility.distance_squared(player, Global.crocodile) 
	var fleeing_radius_squared = fleeing_radius * fleeing_radius
	
	return distance_squared < fleeing_radius_squared

func _targeted_by_crocodile():
	var crocodile = Global.crocodile
	if crocodile == null: return false
	
	var crocodile_heading = crocodile.heading
	var crocodile_to_player = Utility.unit_vector_from(crocodile, player)
	var dot = crocodile_heading.dot(crocodile_to_player)
	
	return dot > 0.95

func _goal_not_active_already(goal):
	var has_subgoals = _has_subgoals()
	
	if has_subgoals:
		var first_subgoal_not_this_goal = not _first_subgoal() is goal
		return first_subgoal_not_this_goal
	else: return not has_subgoals

func _should_go_after_coins():
	for coin in Global.Coins:
		return not Locator._filter_coin(player, coin)

func _should_get_on_platform():
	if player.on_platform:
		return false
	
	return not _all_platforms_occupied()

func _all_platforms_occupied():
	for plat in Global.Platforms:
		if not plat.occupied:
			return false
	return true

func terminate():
	.terminate()
	steering.separation_off()