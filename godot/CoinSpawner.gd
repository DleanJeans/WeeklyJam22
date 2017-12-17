extends Area2D

export(NodePath) var container_path = "../../Objects"
export(float) var spawn_interval = 3

onready var size = $Shape.shape.extents * 2
onready var container = get_node(container_path)

var Coin = preload("res://Coin.tscn")

func _ready():
	$Timer.wait_time = spawn_interval + rand_range(-1, 1)
	$Timer.start()

func stop():
	$Timer.stop()

func resume():
	$Timer.start()

func spawn():
	var random_position = Vector2(rand_range(0, size.x), rand_range(0, size.y))
	var coin = Coin.instance()
	coin.position = position - $Shape.shape.extents + random_position
	
	container.add_child(coin)

func clear_coins():
	for c in get_tree().get_nodes_in_group("Coins"):
		c.queue_free()