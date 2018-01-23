extends Node2D

signal player_collect_coin(player)

func stop_spawners():
	get_tree().call_group("CoinSpawners", "stop")
	print("Coin Spawners stopped!")

func clear():
	get_tree().call_group("Coins", "queue_free")

func _ready():
	while true:
		_free_if_out_of_screen()
		yield(Utility.timer(0.5), "timeout")

func _free_if_out_of_screen():
	var rect = $VisibilityNotifier.rect
	for coin in Global.Coins:
		var coin_position = coin.global_position
		if not rect.has_point(coin_position):
			coin.queue_free()