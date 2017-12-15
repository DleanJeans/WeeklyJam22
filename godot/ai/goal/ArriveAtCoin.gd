extends "res://ai/goal/Goal.gd"

var coin

func _ready():
	_name = "ArriveAtCoin"

func activate():
	.activate()
	$RelocatingTimer.start()
	_relocate_coin()

func _relocate_coin():
	coin = Locator.find_most_desired_coin(player)
	steering.arrive_on(coin)

func process():
	.process()
	
	if coin == null:
		state = GOAL_FAILED
	elif coin.collected:
		state = GOAL_COMPLETED
		steering.arrive_off()

func terminate():
	.terminate()
	steering.arrive_off()
	$RelocatingTimer.stop()