extends "res://ai/goal/Goal.gd"

var ChaseOthers = load("res://ai/goal/ChaseOthers.gd")
var GetMostCoins = load("res://ai/goal/GetMostCoins.gd")

func process():
	.process()
	
	if _has_no_subgoals():
		if not player.is_crocodile():
			add_subgoal(GetMostCoins.new())
		elif not player.frozen:
			add_subgoal(ChaseOthers.new())

func _process(delta):
	if ProjectSettings.get_setting("game/debug_goal_tree"):
		player.debug("WinGame")
		_debug_subgoals(get_children(), 1)

func _debug_subgoals(subgoals, level):
	for child in subgoals:
		if not child is load("res://ai/goal/Goal.gd"): continue
		var tabs = ""
		for i in range(0, level):
			tabs += "    "
		player.debug("%s%s" % [tabs, child._name])
		_debug_subgoals(child.get_children(), level + 1)