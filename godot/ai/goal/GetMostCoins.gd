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
		var subgoal
		
		if _all_platforms_occupied():
			subgoal = FleeCrocodile
		else: subgoal = ArriveAtPlatform
		
		if _goal_not_active_already(subgoal):
			clear_subgoals()
			add_subgoal(subgoal.new())
	
	if _has_subgoals(): return
	
	if _should_go_after_coins():
		add_subgoal(GoGetCoin.new())
	elif _should_get_on_platform():
		add_subgoal(ArriveAtPlatform.new())

func _should_flee():
	if Global.crocodile == null: return false
	
	var should_be_panicking = Utility.distance_squared(player, Global.crocodile) < fleeing_radius * fleeing_radius
	var crocodile_not_frozen = not Global.crocodile.frozen
	
	return should_be_panicking and crocodile_not_frozen

func _goal_not_active_already(goal):
	var has_subgoals = _has_subgoals()
	
	if has_subgoals:
		var first_subgoal_not_this_goal = not _first_subgoal() is goal
		return first_subgoal_not_this_goal
	else: return not has_subgoals

func _all_platforms_occupied():
	for plat in Global.Platforms:
		if not plat.occupied:
			return false
	return true

func _crocodile_blocks_way_to_platform():
	var platform = Locator.find_most_desired_platform(player)
	if platform == null:
		return true
	
	var to_platform = (platform.position - player.position).normalized()
	var to_crocodile = (Global.crocodile.position - player.position).normalized()
	var dot = to_platform.dot(to_crocodile)
	
	return dot > 0

func _should_get_on_platform():
	if player.on_platform:
		return false
	
	return not _all_platforms_occupied()

func _should_go_after_coins():
	if player.out_of_coins():
		return true
	for coin in Global.Coins:
		return not Locator._filter_coin(player, coin)

func terminate():
	.terminate()
	steering.separation_off()