extends "res://ai/steering/SteeringBehavior.gd"

signal point_reached(index, vector)

export(int) var reach_radius = 30
export(int) var direction = -1
export(bool) var loop = true

onready var Steering = get_parent()

var _path = [Vector2()]
var current_index = 0 setget set_current_index

var current_point setget , _current_point
var next_point setget , _next_point

func on(target):
	.on(target)
	_path = target
	
	current_index -= direction
	_set_next_point()
	_seek_point()

func _seek_point():
	Steering.seek_on(self.current_point)

func execute():
	return follow_path()

func follow_path():
	var distance_squared_to_point = Utility.distance_squared(player, self.current_point)
	if distance_squared_to_point < reach_radius * reach_radius:
		emit_signal("point_reached", current_index, self.current_point)
		_seek_next_point()
		if self.current_point == null:
			Steering.seek_off()
		
	return Vector2()

func _seek_next_point():
	_set_next_index()
	_seek_point()

func _set_next_point():
	_set_next_index()
	if _path_smoothable():
		_set_next_point()

func _set_next_index():
	set_current_index(_next_index())

func _next_index():
	var next_index = current_index + direction
	if loop:
		if next_index < 0:
			next_index = _path.size() - 1
		elif next_index >= _path.size():
			next_index = 0
	return next_index

func _path_smoothable():
	if self.current_point == null:
		return false
	
	var current_transform = player.transform
	current_transform.origin -= player.heading
	
	var result = Utility.raycast(player.position, self.next_point, [], Global.COLLISION_PLATFORM)
	var wont_collide = result.empty()
	
	return wont_collide

func _current_point():
	if current_index >= _path.size():
		return null
	return _path[current_index]

func _next_point():
	return _path[_next_index()]

func set_current_index(index):
	current_index = index