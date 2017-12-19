extends Node2D

onready var player = get_parent()

func _process(delta):
	if player.controller == "AI": return
	
	if _is_action_pressed("left"):
		player.move(Global.LEFT)
	if _is_action_pressed("right"):
		player.move(Global.RIGHT)
	if _is_action_pressed("up"):
		player.move(Global.UP)
	if _is_action_pressed("down"):
		player.move(Global.DOWN)
	if _is_action_just_pressed("action"):
		if not player.is_crocodile():
			player.jump()
		elif not player.frozen:
			player.groan()

func _is_action_pressed(action):
	return Input.is_action_pressed("%s_%s" % [player.controller.to_lower(), action])
	
func _is_action_just_pressed(action):
	return Input.is_action_just_pressed("%s_%s" % [player.controller.to_lower(), action])