extends Node2D

export(NodePath) var coin_parent_path = "../Map/Objects"
export(int) var distance_between_coins = 100

onready var Gator = $Gator

var _crocodile
var _last_coin_spawn_position

func reparent_here():
	reparent(self)

func reparent_to_crocodile():
	if Global.crocodile != null:
		var player_sprite = Global.crocodile.get_node("Sprite")
		reparent(player_sprite)

func reparent(new_parent):
	Utility.reparent(Gator, new_parent)

func _ready():
	Global.connect("crocodile_changed", self, "_on_crocodile_changed")

func _on_crocodile_changed():
	_crocodile = Global.crocodile
	
	if _no_crocodile():
		_stop_coin_spawner()
		hide()
		return
	else: show()
	
	_listen_to_crocodile_going_rawr()
	reparent_to_crocodile()
	_stop_for_awhile()

func _no_crocodile():
	return _crocodile == null

func _stop_coin_spawner():
	$CoinSpawner.stop()

func _listen_to_crocodile_going_rawr():
	if not _crocodile.is_connected("rawr", Gator, "rawr"):
		_crocodile.connect("rawr", Gator, "rawr")

func _stop_for_awhile():
	$CoinSpawner.stop()
	yield(Utility.timer(3), "timeout")
	if Global.crocodile != null and not Global.Game.game_over:
		$CoinSpawner.resume()

func _process(delta):
	_update_position()
	_spawn_coin_if_go_far_enough()

func _update_position():
	if Gator.get_parent() != self:
		position = Gator.global_position

func _spawn_coin_if_go_far_enough():
	if _last_coin_spawn_position == null:
		_spawn_coin()
		return
	
	var distance_squared_to_last_spawn_point = _get_distance_squared_to_last_spawn_point()
	var distance_between_coins_squared = distance_between_coins * distance_between_coins
	if distance_squared_to_last_spawn_point > distance_between_coins_squared:
		_spawn_coin()

func _get_distance_squared_to_last_spawn_point():
	return Utility.distance_squared(position, _last_coin_spawn_position)

func _spawn_coin():
	$CoinSpawner.spawn()

func update_coin_parent():
	var coin_parent = get_node(coin_parent_path)
	$CoinSpawner.set_coin_parent(coin_parent)

func _on_coin_spawned(coin):
	_last_coin_spawn_position = coin.global_position