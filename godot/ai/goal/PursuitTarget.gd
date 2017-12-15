extends "res://ai/goal/Goal.gd"

var target

func _ready():
	_name = "PursuitTarget"

func activate():
	.activate()
	$RelocatingTimer.start()
	_relocate_target()

func process():
	.process()
	
	if target == null or target.on_platform:
		state = GOAL_FAILED

func terminate():
	$RelocatingTimer.stop()
	steering.pursuit_off()
	.terminate()

func _relocate_target():
	target = Locator.find_most_desired_player(player)
	steering.pursuit_on(target)