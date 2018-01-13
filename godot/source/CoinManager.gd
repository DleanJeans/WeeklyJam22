extends Node2D

func stop_spawners():
	get_tree().call_group("CoinSpawners", "stop")

func resume_spawners():
	get_tree().call_group("CoinSpawners", "resume")

func clear():
	get_tree().call_group("Coins", "queue_free")