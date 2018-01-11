extends Node

func player_blocked_by_platform(player):
	var slide_count = player.get_slide_count()
	if slide_count == 0:
		return false
	
	var collision = player.get_slide_collision(0)
	return collision.collider is load("res://Platform.gd")

func relative_dot_to(from, point1, point2):
	var to_point1 = unit_vector_from(from, point1)
	var to_point2 = unit_vector_from(from, point2)
	var dot = to_point1.dot(to_point2)

	return dot

func find_max(me, objects, calculate_points, filter = null):
	var highest_points = -INF
	var best_candidate

	for object in objects:
		if filter != null:
			if typeof(filter) == TYPE_ARRAY and filter.has(object): continue
			elif filter.call_func(me, object): continue

		var points = calculate_points.call_func(me, object)
		if points > highest_points:
			highest_points = points
			best_candidate = object

	return best_candidate

func find_min(me, objects, calculate_points, filter = null):
	var lowest_points = INF
	var best_candidate

	for object in objects:
		if filter != null and filter.call_func(me, object): continue

		var points = calculate_points.call_func(me, object)
		if points < lowest_points:
			lowest_points = points
			best_candidate = object

	return best_candidate

func unit_vector_from(from, to):
	return vector_from(from, to).normalized()

func vector_from(from, to):
	from = get_position(from)
	to = get_position(to)
	
	return to - from

func distance(node1, node2):
	node1 = get_position(node1)
	node2 = get_position(node2)
	return node1.distance_to(node2)

func distance_squared(node1, node2):
	node1 = get_position(node1)
	node2 = get_position(node2)
	return node1.distance_squared_to(node2)

func raycast(from, to, exclude = [], layer = null):
	from = get_position(from)
	to = get_position(to)
	
	var space_state = Global.Game.get_world_2d().get_direct_space_state()
	var result = space_state.intersect_ray(from, to, exclude, layer)
	return result

func get_position(object):
	if typeof(object) != TYPE_VECTOR2:
		object = object.position
	return object