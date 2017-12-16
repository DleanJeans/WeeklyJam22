extends "res://ai/goal/Goal.gd"

var platform

func _ready():
	_name = "FleeCrocodile"

func activate():
	.activate()
	steering.flee_on(Global.crocodile)

func process():
	.process()
	
	if _got_away():
		state = GOAL_COMPLETED

func _got_away():
	var on_platform = player.on_platform
	var not_panicking_anymore = not steering.get_node("Flee").is_panicking()
	var crocodile_frozen = Global.crocodile.frozen
	
	return on_platform or not_panicking_anymore or crocodile_frozen

func terminate():
	steering.flee_off()
	.terminate()