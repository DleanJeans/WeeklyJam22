extends "res://source//ai/steering/SteeringBehavior.gd"

export(float) var look_ahead_time_tweaker = 0.5
onready var seeker = get_parent().get_node("Seek")

func execute():
	if target == null:
		return Vector2()
	return pursuit() * multiplier

func pursuit():
	var to_target = target.position - player.position
	var relative_heading = abs(player.heading.dot(target.heading))
	relative_heading = rad2deg(acos(relative_heading))
	
	if relative_heading < 20:
		return seeker.seek(target.position)
	
	var look_ahead_time = to_target.length() / player.max_velocity
	look_ahead_time *= look_ahead_time_tweaker
	
	var future_target_position = target.position + target.velocity * look_ahead_time
	
	return seeker.seek(future_target_position)