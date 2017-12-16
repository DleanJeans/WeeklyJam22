extends StaticBody2D

# ALWAYS keep $Shape/Area/Shape
# a lil bit larget than $Shape itself
# because only then _on_player_enter() can be called

var occupied
var _player

func _on_player_enter(player):
	if not player.is_in_group(Global.PLAYERS_GROUP): return
	
	_player = player
	
	if _player_is_not_allowed():
		_block_player()
	else:
		_unblock_player()

func _player_is_not_allowed():
	return occupied or _player.is_crocodile()

func _block_player():
	_player.collision_layer |= collision_mask
	if _player.controller != "AI":
		$BlockSound.play()

func _unblock_player():
	occupied = true
	$AllowSound.play()
	_player.collision_layer = 1
	_player.on_platform = true

func _on_player_exited(player):
	if occupied and player.on_platform:
		occupied = false
		player.on_platform = false
		