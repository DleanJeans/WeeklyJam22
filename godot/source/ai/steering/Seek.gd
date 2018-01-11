extends "res://source/ai/steering/SteeringBehavior.gd"

func execute():
	if target == null:
		return Vector2()
	return seek_target() * multiplier

func seek_target():
	var target = Utility.get_position(self.target)
	return seek(target)

func seek(target_position):
	var velocity = player.moving_vector(target_position - player.position)
	return velocity - player.velocity