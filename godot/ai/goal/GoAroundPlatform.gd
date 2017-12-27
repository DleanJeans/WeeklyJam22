extends "res://ai/goal/Goal.gd"

onready var path_follow

var _platform
var _target
var _path = [Vector2()]
var _path_direction = 1

	#1. Create a path
	#2. Find closest point
	#3. Find closest point to target
	#4. Find direction
	#5. Terminate if raycast to target not hit platform

func _init(platform, target):
	_platform = platform
	_target = target
	_name = "GoAroundPlatform"

func activate():
	.activate()
	get_parent().relocating_timer.set_paused(true)
	path_follow = steering.get_node("PathFollow")
	
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
#	var result = get_world_2d().get_direct_space_state().intersect_ray(point, _target.position, [], Global.COLLISION_PLATFORM)
#	var not_hit_platform = result.empty() or result.collider != _platform
#	return not_hit_platform
	var hit_platform = player.test_move(player.transform, _target.position - player.position)
	return not hit_platform

func terminate():
	path_follow.disconnect("point_reached", self, "_terminate_if_not_blocked_anymore")
	get_parent().relocating_timer.set_paused(false)
	get_parent()._relocate_target()
	steering.path_follow_off()
	.terminate()