extends Node2D

onready var PlayerManager = Systems.PlayerManager
onready var MainMenu = Screens.MainMenu

var num_users = 0
var _current_controller

func reset():
	set_process(true)
	
	num_users = 0
	for child in get_children():
		child.reset()
	
	for i in range(0, Global.Players.size()):
		var player = Global.Players[i]
		if not player.is_ai_controlled():
			var child = get_node(player.controller)
			child.unreset()
			num_users += 1

func _process(delta):
	if MainMenu.opened: return
	
	for child in get_children():
		_check_key_list(child)

func _check_key_list(controller_child):
	if controller_child.activated: return
	_current_controller = controller_child
	
	for key in _current_controller.key_list:
		if Input.is_action_pressed(key):
			_activate_controller()
			_lock_room()

func _activate_controller():
	_current_controller.activated = true
	num_users += 1
	
	var controller_name = _current_controller.name
	var random_player = PlayerManager.find_random_ai()
	
	random_player.controller = controller_name
	random_player.set_name_tag("P%s" % num_users)
	random_player.force_jump()
	
	PlayerManager.emit_player_controller_changed(random_player)

func _lock_room():
	if _room_full():
		set_process(false)

func _room_full():
	var player_count = Global.Players.size()
	return num_users >= player_count