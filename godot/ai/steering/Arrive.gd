extends "res://ai/steering/SteeringBehavior.gd"

export(float) var deceleration = 0.5

func execute():
	if target == null or target.is_queued_for_deletion():
		return Vector2()
	return arrive() * multiplier

func arrive():
	var to_target = target.position - player.position
	var distance = to_target.length()
	
	if distance > 0:
		var speed = distance / deceleration
		speed = min(speed, player.max_velocity)
		
		var velocity = to_target * speed / distance
		
		return velocity - player.velocity
	
	return Vector2()