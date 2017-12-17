extends Node2D

onready var player_manager = $"../PlayerManager"

var num_users = 0
var _current_controller

func reset():
	num_users = 0
	for child in get_children():
		child.reset()

func _process(delta):
	if $"../MainMenu".visible: return
	
	for child in get_children():
		_check_key_list(child)

func _check_key_list(controller_child):
	if controller_child.activated: return
	_current_controller = controller_child
	
	for key in _current_controller.key_list:
		if Input.is_action_pressed(key):
			_activate_controller()

func _activate_controller():
	_current_controller.activated = true
	num_users += 1
	player_manager.activate_controller(num_users, _current_controller.get_name())