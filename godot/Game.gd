extends Node2D

signal game_loaded
signal countdown_started
signal game_started
signal game_over
signal game_paused
signal game_resumed

var showing_winner = false
var winners

func start_counting_down():
	emit_signal("countdown_started")
	showing_winner = false

func start():
	emit_signal("game_started")

func try_pause():
	if _users_playing():
		emit_signal("game_paused")

func try_resume():
	if _users_playing():
		emit_signal("game_resumed")
		if $GameTimer.in_countdown_mode():
			$PlayerManager.freeze_players()
			_stop_coin_spawners()

func _users_playing():
	for player in Global.Players:
		if not player.is_controlled_by_ai():
			return true
	return false

func _reset_players():
	for p in Global.Players:
		p.reset()

func _reset_platforms():
	for p in Global.Platforms:
		p.reset()

func _resume_coin_spawners():
	for spawner in Global.CoinSpawners:
		spawner.resume()

func _stop_coin_spawners():
	for spawner in Global.CoinSpawners:
		spawner.stop()

func end():
	emit_signal("game_over")

func _ready():
	randomize()
	emit_signal("game_loaded")

func _show_winner():
	$PlayerManager.freeze_players()
	Global.crocodile.get_node("FreezeTimer").stop()
	showing_winner = true
	winners = _players_with_highest_score()
	$ControlHint.show()

func _players_with_highest_score():
	var winner
	var winner2
	var highest_score = -INF
	
	for p in Global.Players:
		if p.is_crocodile(): continue
		if p.coins > highest_score:
			winner = p
			winner2 = null
			highest_score = p.coins
		elif p.coins == highest_score:
			winner2 = p
	
	if winner2 == null:
		return [winner]
	else: return [winner, winner2]

func _clear_coins():
	for coin in Global.Coins:
		coin.queue_free()

func _process(delta):
	if showing_winner:
		for p in winners:
			p.show_winner_label()
			p.jump()
	
	if Input.is_action_just_pressed("slo_mo_toggle"):
		Engine.set_time_scale(ProjectSettings.get_setting("game/slo_mo_scale") if Engine.get_time_scale() == 1 else 1)