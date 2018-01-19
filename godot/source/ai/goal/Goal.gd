extends Node2D

enum {
	GOAL_TERMINATED, #0
	GOAL_INACTIVE, #1
	GOAL_ACTIVE, #2
	GOAL_COMPLETED, #3
	GOAL_FAILED #4
}

var player
var steering
var activated = false

var subgoals = []

onready var _name = get_script().get_path().get_file().get_basename()

func _ready(): 
	clear_subgoals()

func activate():
	activated = true
	
	player = get_parent().player
	steering = player.get_node("AI/Steering")

func terminate():
	clear_subgoals()
	queue_free()
	_remove_from_parent_goal()

func clear_subgoals():
	for child in subgoals:
		child.terminate()

func _remove_from_parent_goal():
	var parent = get_parent()
	if parent is Classes.Goal:
		parent.remove_subgoal(self)

func remove_subgoal(goal):
	subgoals.erase(goal)
	if not goal.is_queued_for_deletion():
		goal.queue_Free()

func add_subgoal(goal):
	subgoals.push_front(goal)
	add_child(goal)

func process():
	activate_if_inactive()
	process_subgoals()

func activate_if_inactive():
	if not activated:
		activate()

func process_subgoals():
	if _has_subgoals():
		_first_subgoal().process()
	
func _first_subgoal():
	return subgoals[0]

func _subgoal_count():
	return subgoals.size()

func _has_subgoals():
	return _subgoal_count() > 0

func _has_no_subgoals():
	return _subgoal_count() == 0