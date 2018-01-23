extends Node2D

signal player_jump(player)
signal player_go_rawr(player)
signal player_get_coin(player)
signal player_controller_changed(player)

var positions = []

func listen_to_players_collecting_coins():
	for player in Global.Players:
		_forward_signal(player, "got_coins", "player_get_coin", [player])

func listen_to_players_jumping():
	for player in Global.Players:
		_forward_signal(player, "jump", "player_jump" , [player])

func listen_to_players_going_rawr():
	for player in Global.Players:
		_forward_signal(player, "rawr", "player_go_rawr" , [player])

func _forward_signal(player, player_signal, self_signal, bindings = []):
	bindings.push_front(self_signal)
	player.connect(player_signal, self, "emit_signal", bindings)

func enable_ai():
	for player in Global.Players:
		player.enable_ai()

func disable_ai():
	for player in Global.Players:
		player.disable_ai()

func reset_positions():
	var map = _current_map()
	map.reset_positions()

func _current_map():
	return $"/root/Game/Map"

func reset_controllers():
	for player in Global.Players:
		player.controller = "AI"
		emit_signal("player_controller_changed", player)

func emit_player_controller_changed(player):
	emit_signal("player_controller_changed", player)

func find_random_ai():
	var random_player = _find_random_player()
	while random_player.controller != "AI":
		random_player = _find_random_player()
	return random_player

func choose_crocodile_randomly():
	if Global.crocodile != null: return
	
	var random_player = _find_random_player()
	random_player.turn_crocodile()
	print("A Wild Gator appeared!")

func _find_random_player():
	var random_player_index = randi() % Global.Players.size()
	var random_player = Global.Players[random_player_index]
	
	return random_player

func freeze_players():
	for p in Global.Players:
		p.frozen = true

func unfreeze_players():
	for p in Global.Players:
		p.frozen = false

func reset():
	Global.crocodile = null
	for p in Global.Players:
		p.reset()

func resume_freeze_timer():
	Global.crocodile.get_node("FreezeTimer").set_paused(false)

func pause_freeze_timer():
	Global.crocodile.get_node("FreezeTimer").set_paused(true)