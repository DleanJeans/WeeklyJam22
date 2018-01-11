extends "res://ai/goal/Goal.gd"

var coin

func activate():
	.activate()
	coin = Locator.find_most_desired_coin(player)
	if coin == null or not coin is load("res://Coin.gd"):
		state = GOAL_FAILED
	else: steering.seek_on(coin)
	
	add_subgoal(load("res://ai/goal/LeavePlatform.gd").new())

func process():
	.process()
	
	if coin == null or Global.Coins.size() == 0:
		state = GOAL_FAILED
	elif coin.collected:
		state = GOAL_COMPLETED

func terminate():
	.terminate()
	steering.seek_off()