extends "res://ai/goal/Goal.gd"

var FleeCrocodile = load("res://ai/goal/FleeCrocodile.tscn")
var GoGetCoin = load("res://ai/goal/GoGetCoin.tscn")
var ArriveAtPlatform = load("res://ai/goal/ArriveAtPlatform.tscn")

func _ready():
	_name = "GetMostCoins"

func activate():
	.activate()
	steering.separation_on()

func process():
	.process()
	
	if player.is_crocodile():
		state = GOAL_FAILED
	
	var first_child = _first_subgoal()
	if _should_flee():
		clear_subgoals()
		add_subgoal(FleeCrocodile.instance())
	
	if _has_subgoals(): return
	
	if _should_go_after_coins():
		add_subgoal(GoGetCoin.instance())
	elif not player.on_platform:
		add_subgoal(ArriveAtPlatform.instance())

func _should_flee():
	var not_fleeing_already = _has_subgoals() and not _first_subgoal() is load("res://ai/goal/FleeCrocodile.gd")
	var should_be_panicking = steering.get_node("Flee").is_panicking()
	var crocodile_not_frozen = not Global.crocodile.frozen
	
	return not_fleeing_already and should_be_panicking and crocodile_not_frozen

func _should_go_after_coins():
	return Global.Coins.size() > 0

func terminate():
	.terminate()
	steering.separation_off()