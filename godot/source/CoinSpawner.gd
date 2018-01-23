extends Area2D

signal coin_spawned(coin)

var Coin = load("res://source/Coin.tscn")

export(float) var spawn_interval = 1
export(float) var fluctuating_amount = 0.1

onready var _coin_parent
onready var _scaled_extents = $Shape.shape.extents * self.scale
onready var _size = _scaled_extents * 2

func is_stopped():
	return $Timer.is_stopped()

func stop():
	$Timer.stop()

func resume():
	$Timer.start()

func spawn():
	if is_stopped(): return
	
	_spawn_coin()
	_flutuate_spawn_time()

func _spawn_coin():
	var random_position = Vector2(_random_x(), _random_y())
	var coin = Coin.instance()
	
	coin.position = global_position - _scaled_extents + random_position
	_coin_parent.add_child(coin)
	emit_signal("coin_spawned", coin)

func _random_x():
	return randi() % int(_size.x)

func _random_y():
	return randi() % int(_size.y)

func _flutuate_spawn_time():
	$Timer.wait_time = spawn_interval + rand_range(-fluctuating_amount, fluctuating_amount)

func set_coin_parent(value):
	_coin_parent = value