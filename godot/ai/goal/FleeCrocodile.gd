extends "res://ai/goal/Goal.gd"

var platform

func _ready():
	_name = "FleeCrocodile"

func activate():
	.activate()
	$RelocatingTimer.start()

func process():
	.process()
	
	if player.on_platform or not steering.get_node("Flee").is_panicking():
		state = GOAL_COMPLETED

func terminate():
	$RelocatingTimer.stop()
	steering.flee_off()
	steering.arrive_off()
	.terminate()

func _relocate_platform():
	platform = Locator.find_most_desired_platform(player)
	steering.arrive_on(platform)
	steering.flee_on(Global.crocodile)
