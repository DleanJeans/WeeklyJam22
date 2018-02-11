extends "res://source/ai/goal/Goal.gd"

var coin
var _coin_ref

func activate():
	.activate()
	_get_coin()
	_free_if_coin_null()
	
	if coin != null:
		steering.seek_on(coin)
	
	add_subgoal(Classes.LeavePlatform.new())

func _get_coin():
	coin = Locator.find_most_desired_coin(player)
	if coin == null:
		terminate()

func _free_if_coin_null():
	if coin == null: return
	
	coin.connect("tree_exiting", self, "terminate")

func process():
	.process()
	
	if coin == null or coin.collected:
		terminate()

func terminate():
	.terminate()
	steering.seek_off()