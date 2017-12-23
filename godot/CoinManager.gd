extends Node2D

func stop_spawners():
	for spawner in Global.CoinSpawners:
		spawner.stop()

func resume_spawners():
	for spawner in Global.CoinSpawners:
		spawner.resume()

func clear():
	for coin in Global.Coins:
		coin.queue_free()
