extends "res://ai/goal/Goal.gd"

var coin

func _ready():
	_name = "GoGetCoin"

func activate():
	.activate()
	coin = Locator.find_most_desired_coin(player)
	steering.seek_on(coin)

func process():
	.process()
	
	if coin == null:
		state = GOAL_FAILED
	elif coin.collected:
		state = GOAL_COMPLETED
		steering.seek_off()

func terminate():
	.terminate()
	steering.seek_off()