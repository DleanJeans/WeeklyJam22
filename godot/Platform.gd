extends StaticBody2D

# ALWAYS keep $Shape/Area/Shape
# a lil bit larget than $Shape itself
# because only then _on_player_enter() can be called

var occupied
var _player

func reset():
	_turn_green()

func _on_player_enter(body):
	if not _is_player(body): return
	
	_player = body
	
	if _player_is_not_allowed():
		_block_player()
	else:
		_unblock_player()

func _is_player(body):
	return body.is_in_group(Global.PLAYERS_GROUP)

func _player_is_not_allowed():
	return occupied or _player.is_crocodile()

func _block_player():
	_player.collision_layer |= collision_mask

func _unblock_player():
	occupied = true
	$AllowSound.play()
	_player.collision_layer = 1
	_player.on_platform = true
	_turn_red()

func _on_player_exited(player):
	if occupied and player.on_platform:
		occupied = false
		player.on_platform = false
		_turn_green()

func _turn_red():
	$ColorChanger.play("TurnRed")

func _process(delta):
	for body in $Shape/Area.get_overlapping_bodies():
		if not _is_player(body): continue
		_player = body
		if _player.is_crocodile():
			_block_player()
		elif not occupied:
			_unblock_player()

func _steer_player():
	var heading_angle = _player.velocity.angle_to_point(Vector2())
	var new_angle = round(heading_angle / 45) * 45
	
	_player.velocity = _player.velocity.rotated(new_angle - heading_angle)

func _turn_green():
	$ColorChanger.play("TurnGreen")