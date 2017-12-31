extends "res://ai/goal/Goal.gd"

onready var path_follow

var _platform
var _target
var _path = [Vector2()]
var _path_direction = 1

func _init(platform, target):
	_platform = platform
	_target = target
	_name = "GoAroundPlatform"

func process():
	.process()
	
	_update_goal_state()

func _update_goal_state():
	if _target == null or _target.on_platform:
		state = GOAL_FAILED

func activate():
	.activate()
	path_follow = steering.get_node("PathFollow")
	
	_update_goal_state()
	if state != GOAL_ACTIVE:
		return
	
	get_parent().pause_acquisition()
	
	_create_path()
	_find_path_direction()
	_start_following()
	path_follow.connect("point_reached", self, "_terminate_if_not_blocked_anymore")

func _create_path():
	_path = []
	_path.append(_platform.position + Vector2(-50, -50) * _platform.scale + Vector2(-40, -25))
	_path.append(_platform.position + Vector2(-50, 50) * _platform.scale + Vector2(-40, 25))
	_path.append(_platform.position + Vector2(50, 50) * _platform.scale + Vector2(40, 25))
	_path.append(_platform.position + Vector2(50, -50) * _platform.scale + Vector2(40, -25))

func _find_path_direction():
	var point_near_player = _closest_point_to(player)
	var point_near_target = _closest_point_to(_target)
	
	var point_player_index = _path.find(point_near_player)
	var point_target_index = _path.find(point_near_target)
		
	_decide_direction(point_near_player, point_near_target)
	 
	path_follow.direction = _path_direction
	path_follow.set_current_index(point_player_index)

func _closest_point_to(player, exceptions = null):
	return Utility.find_min(player, _path, funcref(Utility, "distance_squared"), exceptions)

func _decide_direction(from_index, to_index):
	if to_index <= from_index:
		_path_direction = 1
	else: _path_direction = -1

func _start_following():
	steering.path_follow_on(_path)

func _terminate_if_not_blocked_anymore(point_index, point):
	if _raycast_to_target_not_hit_platform(point):
		state = GOAL_COMPLETED
	else:
		pass

func _raycast_to_target_not_hit_platform(point):
	var hit_platform = player.test_move(player.transform, _target.position - player.position)
	return not hit_platform

func terminate():
	_disconnect_signal()
	_resume_parent_target_acquisition()
	steering.path_follow_off()
	.terminate()

func _disconnect_signal():
	if path_follow.is_connected("point_reached", self, "_terminate_if_not_blocked_anymore"):
		path_follow.disconnect("point_reached", self, "_terminate_if_not_blocked_anymore")

func _resume_parent_target_acquisition():
	get_parent().resume_acquisition()
	get_parent().reacquire_target()