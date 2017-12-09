extends StaticBody2D

var _player

func _on_player_enter(player):
	if not player.is_in_group(Global.PLAYERS_GROUP): return
	
	print("Player entered")
	_player = player
	
	if _player_is_not_allowed():
		_block_player()
		return
	else:
		_unblock_player()
		_player.last_visited_platform = self
		_player.on_platform = true

func _player_is_not_allowed():
	return _player.last_visited_platform == self or _player.is_crocodile()

func _block_player():
	_player.collision_layer |= collision_mask

func _unblock_player():
	_player.collision_layer = 1

func _on_player_exited(player):
	player.on_platform = false