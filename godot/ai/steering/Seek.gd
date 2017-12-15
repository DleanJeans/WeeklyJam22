extends "res://ai/steering/SteeringBehavior.gd"

func execute():
	return seek_target() * multiplier

func seek_target():
	if target == null:
		return Vector2()
	return seek(target.position)

func seek(target_position):
	var velocity = player.moving_vector(target_position - player.position)
	return velocity - player.velocity