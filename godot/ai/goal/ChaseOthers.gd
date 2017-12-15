extends "res://ai/goal/Goal.gd"

var PursuitTarget = load("res://ai/goal/PursuitTarget.tscn")

func _ready():
	_name = "ChaseOthers"

func activate():
	.activate()
	steering.obstacle_avoidance_on()

func process():
	.process()
	
	if not player.is_crocodile():
		state = GOAL_COMPLETED
	
	if _has_no_subgoals():
		add_subgoal(PursuitTarget.instance())

func terminate():
	.terminate()
	steering.obstacle_avoidance_off()