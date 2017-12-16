extends Node2D

enum {
	GOAL_TERMINATED, #0
	GOAL_INACTIVE, #1
	GOAL_ACTIVE, #2
	GOAL_COMPLETED, #3
	GOAL_FAILED #4
}

var Goal = load("res://ai/goal/Goal.gd")

var player
var steering
var state = GOAL_INACTIVE

var _name

func _ready():
	clear_subgoals()

func activate():
	state = GOAL_ACTIVE
	player = get_parent().player
	steering = player.get_node("AI/Steering")
	
#	print("\nPlayer: %s" % player.get_name())
#	print("Goal Activated: %s" % _name)

func terminate():
#	print("\nPlayer: %s" % player.get_name())
#	print("Goal Terminated - %s: %s" % [state, _name])
	clear_subgoals()
	queue_free()
	state = GOAL_TERMINATED

func add_subgoal(goal):
	add_child(goal)
	move_child(goal, 0)

func clear_subgoals():
	for child in get_children():
		if child is load("res://ai/goal/Goal.gd"):
			_terminate_subgoal(child)

func activate_if_inactive():
	if is_inactive():
		activate()

func process():
	activate_if_inactive()
	process_subgoals()

func process_subgoals():
	if _has_subgoals():
		_first_subgoal().process()
	
	_clear_completed_failed_subgoals()

func _first_subgoal():
	for i in range(0, get_child_count()):
		var child = get_child(i)
		if child is Goal:
			return child
	return null

func _clear_completed_failed_subgoals():
	while _has_subgoals() and _first_subgoal()._is_completed_or_failed():
		_terminate_subgoal(_first_subgoal())

func _terminate_subgoal(goal):
	if goal.is_terminated() or goal.is_inactive(): return
	goal.terminate()
	remove_child(goal)

func _has_subgoals():
	return _subgoal_count() > 0

func _has_no_subgoals():
	return _subgoal_count() == 0

func _subgoal_count():
	var count = 0
	for child in get_children():
		if child is Goal:
			count += 1
	return count

func _is_completed_or_failed():
	return is_completed() or has_failed()

func is_inactive():
	return state == GOAL_INACTIVE

func is_active():
	return state == GOAL_ACTIVE

func is_completed():
	return state == GOAL_COMPLETED

func has_failed():
	return state == GOAL_FAILED

func is_terminated():
	return state == GOAL_TERMINATED