extends Area2D

export(NodePath) var container_path = "../../Objects"
export(float) var spawn_interval = 3

onready var scaled_extents = $Shape.shape.extents * scale
onready var size = scaled_extents * 2
onready var container = get_node(container_path)

var Coin = preload("res://Coin.tscn")

func _ready():
	$Timer.start()

func stop():
	$Timer.stop()

func resume():
	$Timer.start()

func spawn():
	_spawn_coin()
	_flutuate_spawn_time()

func _spawn_coin():
	var random_position = Vector2(_random_x(), _random_y())
	var coin = Coin.instance()
	
	container.add_child(coin)
	coin.position = position - scaled_extents + random_position

func _random_x():
	return randi() % int(size.x)

func _random_y():
	return randi() % int(size.y)

func _flutuate_spawn_time():
	$Timer.wait_time = spawn_interval + rand_range(-0.5, 0.5)