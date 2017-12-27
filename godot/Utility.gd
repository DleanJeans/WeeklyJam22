extends Node

func relative_direction(origin, position1, position2):
	var to_position1 = (position1 - origin).normalized()
	var to_position2 = (position2 - origin).normalized()
	var dot = to_position1.dot(to_position2)
	var relative_direction = acos(dot)
	
	return relative_direction

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
	
func distance(node1, node2):
	node1 = get_position(node1)
	node2 = get_position(node2)
	return node1.distance_to(node2)

func distance_squared(node1, node2):
	node1 = get_position(node1)
	node2 = get_position(node2)
	return node1.distance_squared_to(node2)

func get_position(object):
	if typeof(object) != TYPE_VECTOR2:
		object = object.position
	return object