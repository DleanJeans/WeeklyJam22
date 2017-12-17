tool
extends "res://ai/steering/SteeringBehavior.gd"

export(float) var breaking_weight = 0.5
export(int) var min_detection_length = 50 setget _set_min_detection_length
var detection_length = 50 setget _set_detection_length

func execute():
	return avoid_obstacles() * multiplier

func _physics_process(delta):
	if not Engine.is_editor_hint() and player != null and player.controller == "AI":
		$DetectionBox.rotation = player.heading.angle_to_point(Vector2())
		self.detection_length = 1 + (player.velocity.length() / player.max_velocity) * min_detection_length * 2

func avoid_obstacles():
	var obstacle = _find_closest_obstance()
	var velocity = Vector2()
	
	if obstacle == null:
		return velocity
	
#	var obstacle_local_position = $DetectionBox.to_local(obstacle.position)	
#	var distance_to_obstacle = player.position.distance_to(obstacle.position)
#	var multiplier = 1 + (detection_length - obstacle_local_position.y) / detection_length
#	var obstacle_size = obstacle.get_node("Shape").shape.extents * 2
#
#	velocity.y = (obstacle_size.y - obstacle_local_position.y) * multiplier
#	velocity.x = (obstacle_size.x - obstacle_local_position.x) * breaking_weight
#
#	velocity = $DetectionBox.to_global(velocity) - obstacle.position
	velocity = player.position - obstacle.position
	velocity = velocity.clamped(player.max_velocity)
	
	return velocity

func _find_closest_obstance():
	var obstacles = $DetectionBox.get_overlapping_bodies()
	var closest
	var shortest_distance = INF
	
	for obs in obstacles:
		var distance_to_obstacle = player.position.distance_squared_to(obs.position)
		if distance_to_obstacle < shortest_distance:
			closest = obs
			shortest_distance = distance_to_obstacle
	
	return closest

func _calculate_osbtacle_radius(obstacle):
	var shape_extent = obstacle.get_node("Shape").shape.extents
	return shape_extent.distance_to(Vector2())

func _set_min_detection_length(value):
	min_detection_length = value
	if has_node("DetectionBox/Shape"):
		self.detection_length = value

func _set_detection_length(value):
	detection_length = value
	if has_node("DetectionBox/Shape"):
		$DetectionBox/Shape.scale.x = value / $DetectionBox/Shape.shape.extents.x
		$DetectionBox/Shape.position.x = value
