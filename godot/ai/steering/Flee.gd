
extends "res://ai/steering/SteeringBehavior.gd"

var panic_radius setget , _get_panic_radius

func execute():
	return flee_target() * multiplier

func flee_target():
	if target == null:
		return Vector2()
	return flee(target.position)

func flee(target_position):
	var distance_squared = target_position.distance_to(player.position) + 1
	
	if not is_panicking():
		return Vector2()
	
	var velocity = player.moving_vector(player.position - target_position, self.panic_radius / distance_squared * multiplier)
	
	return velocity - player.velocity

func is_panicking():
	return $PanicRadius.get_overlapping_bodies().has(Global.crocodile)

func _get_panic_radius():
	return $PanicRadius.scale.x * $PanicRadius/Shape.shape.radius