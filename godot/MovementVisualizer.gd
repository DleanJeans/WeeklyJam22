extends Node2D

# GDquest colors
var colors = {
	WHITE = Color(1.0, 1.0, 1.0),
	YELLOW = Color(1.0, .757, .027),
	GREEN = Color(.282, .757, .255),
	BLUE = Color(.098, .463, .824),
	PINK = Color(.914, .118, .388)
}

export(float) var width = 4
export(float) var multiplier = 1

onready var parent = get_parent()

func _ready():
	update()

func _draw():
	draw_vector(parent.velocity, Vector2(), colors['GREEN'])

func draw_vector(vector, offset, _color):
	if vector == Vector2():
		return
	draw_line(offset * multiplier, vector * multiplier, _color, width)

	var dir = vector.normalized()
	draw_triangle_equilateral(vector * multiplier, dir, 10, _color)
	draw_circle(offset, 6, _color)

func draw_triangle_equilateral(center=Vector2(), direction=Vector2(), radius=50, _color=WHITE):
	var point_1 = center + direction * radius
	var point_2 = center + direction.rotated(2*PI/3) * radius
	var point_3 = center + direction.rotated(4*PI/3) * radius

	var points = PoolVector2Array([point_1, point_2, point_3])
	draw_polygon(points, PoolColorArray([_color]))

func _process(delta):
	update()