extends "res://ai/goal/Goal.gd"

var target

func _ready():
	_name = "ChaseOthers"

func activate():
	.activate()
	_relocate_target()

func _relocate_target():
	target = Locator.find_most_desired_player(player)
	steering.seek_on(target)

func process():
	.process()
	
	if not player.is_crocodile():
		state = GOAL_COMPLETED
	elif target == null or target.on_platform:
		_relocate_target()

func terminate():
	.terminate()
	steering.seek_off()
