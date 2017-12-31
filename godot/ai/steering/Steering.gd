extends Node2D

export(int) var total_force = 350
onready var player = get_parent().get_parent()

var priorities = ["PathFollow", "Arrive", "Flee", "Pursuit", "Seek"]

func steer():
	var steering_velocity = Vector2()
	var force_left = total_force
	
	for behavior in priorities:
		behavior = get_node(behavior)
		if behavior.is_on:
			var velocity = behavior.execute()
			var magnitude = velocity.length()
			
			if magnitude < force_left:
				steering_velocity += velocity
			else:
				steering_velocity += velocity.normalized() * force_left
			
			force_left -= magnitude
			if magnitude > 0 and ProjectSettings.get_setting("game/debug_steering"):
				player.debug("%s: %s" % [behavior.get_name(), round(magnitude)])
			
		if force_left <= 0:
			break
	
	return steering_velocity

func all_off():
	for child in get_children():
		child.off()

func seek_on(target):
	$Seek.on(target)

func seek_off():
	$Seek.off()

func arrive_on(target):
	$Arrive.on(target)

func arrive_off():
	$Arrive.off()

func flee_on(target):
	$Flee.on(target)

func flee_off():
	$Flee.off()

func pursuit_on(target):
	$Pursuit.on(target)

func pursuit_off():
	$Pursuit.off()

func separation_on():
	$Separation.on()

func separation_off():
	$Separation.off()

func path_follow_on(target):
	$PathFollow.on(target)

func path_follow_off():
	$PathFollow.off()