tool
extends "res://ai/steering/SteeringBehavior.gd"

export(int) var panic_radius setget _set_panic_radius

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

func is_panicking(target = null):
	if target == null:
		target = self.target
	return $PanicRadius.get_overlapping_bodies().has(target)

func _set_panic_radius(value):
	panic_radius = value
	if has_node("PanicRadius"):
		$PanicRadius.scale = Vector2(1, 1) * value * 0.02