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
	
	if _has_subgoals(): return
	
	if _should_flee():
		add_subgoal(FleeCrocodile.new())
	elif _should_go_after_coins():
		add_subgoal(GoGetCoin.new())
	elif _should_get_on_platform():
		add_subgoal(ArriveAtPlatform.new())

func _should_get_on_platform():
	if player.on_platform:
		return false
	
	for plat in Global.Platforms:
		if not plat.occupied:
			return true

func _should_flee():
	var should_be_panicking = steering.get_node("Flee").is_panicking()
	var crocodile_not_frozen = not Global.crocodile.frozen
	
	return should_be_panicking and crocodile_not_frozen

func _should_go_after_coins():
	for coin in Global.Coins:
		return not Locator._filter_coin(player, coin)

func terminate():
	.terminate()
	steering.separation_off()