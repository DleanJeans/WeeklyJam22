extends "res://ai/goal/Goal.gd"

var platform

func _ready():
	_name = "ArriveAtPlatform"

func activate():
	.activate()
	$RelocatingTimer.start()

func _relocate_platform():
	platform = Locator.find_most_desired_platform(player)
	steering.arrive_on(platform)

func process():
	.process()
	
	if player.on_platform:
		state = GOAL_COMPLETED

func terminate():
	.terminate()
	$RelocatingTimer.stop()
	steering.arrive_off()