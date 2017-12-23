extends "res://ai/goal/Goal.gd"

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
		var subgoal_to_add
		
		if _all_platforms_occupied() or _crocodile_blocks_way_to_platform() or player.out_of_coins():
			subgoal_to_add = FleeCrocodile
		else:
			subgoal_to_add = ArriveAtPlatform
		
		if _goal_not_active_already(subgoal_to_add):
			clear_subgoals()
			add_subgoal(subgoal_to_add.new())
	
	if _has_subgoals(): return
	
	if _should_go_after_coins():
		add_subgoal(GoGetCoin.new())
	elif _should_get_on_platform():
		add_subgoal(ArriveAtPlatform.new())

func _goal_not_active_already(goal):
	return _has_subgoals() and not _first_subgoal() is goal

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

func _should_flee():
	if Global.crocodile == null: return false
	
	var should_be_panicking = steering.get_node("Flee").is_panicking(Global.crocodile)
	var crocodile_not_frozen = not Global.crocodile.frozen
	
	return should_be_panicking and crocodile_not_frozen

func _should_go_after_coins():
	if player.out_of_coins():
		return true
	for coin in Global.Coins:
		return not Locator._filter_coin(player, coin)

func terminate():
	.terminate()
	steering.separation_off()