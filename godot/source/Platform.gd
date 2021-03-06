extends StaticBody2D

signal player_exited(player)

var occupied setget , _get_occupied

var _current_player
var _occupier

var dips = []

func dip(player):
	if not dipped() and not player_dipped(player):
		dips.append(player)

func undip(player):
	if dips.has(player):
		dips.erase(player)

func dipped():
	return dips.size() >= 2

func player_dipped(player):
	return dips.has(player)

func stop_bounce_tween():
	$Bouncer/Tween.stop_all()

func get_players_fully_inside():
	return $Shape/InsideArea.get_overlapping_bodies()

func get_size():
	var size = 100 * $Shape/Sprite.scale * scale
	return size

func reset():
	_turn_green()

func _on_player_enter(body):
	if not _is_player(body): return
	_current_player = body
	if _current_player.is_crocodile(): return
	
	if _current_player.just_landed and _current_player in get_players_fully_inside():
		_current_player.on_platform = true
		$Bouncer.bounce_other_players_off(_current_player)

func _is_player(body):
	return body is Classes.Player

func _player_not_allowed():
	return _current_player.is_crocodile() or self.occupied

func _on_player_exited(player):
	if not player is Classes.Player: return
	
	emit_signal("player_exited", player) 
	
	if player.on_platform:
		player.on_platform = false
	
	player._leave_platform()

func _turn_red():
	$ColorChanger.play("TurnRed")

func _get_occupied():
	return _occupier != null