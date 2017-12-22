extends StaticBody2D

# ALWAYS keep $Shape/Area/Shape
# a lil bit larget than $Shape itself
# because only then _on_player_enter() can be called

var coins_per_second_rates = 10

var to_screen_center
var occupied
var _player
var _occupier

func _ready():
	var screen_center = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height")) / 2
	to_screen_center = (screen_center - position).normalized()

func reset():
	_turn_green()

func _on_player_enter(body):
	if not _is_player(body): return
	
	_player = body
	
	if _player_not_allowed():
		_block_player()
	else:
		_unblock_player()

func _is_player(body):
	return body.is_in_group(Global.PLAYERS_GROUP)

func _player_not_allowed():
	return occupied or _player.is_crocodile() or _player.out_of_coins()

func _block_player():
	_player.collision_layer |= collision_mask

func _unblock_player():
	occupied = true
	_occupier = _player
	$AllowSound.play()
	_player.collision_layer = 1
	_player.on_platform = true
	_turn_red()
	$FeeTimer.start()

func _on_player_exited(player):
	if occupied and player.on_platform:
		occupied = false
		player.on_platform = false
		_turn_green()
		$FeeTimer.stop()

func _turn_red():
	$ColorChanger.play("TurnRed")

func _process(delta):
	for body in $Shape/Area.get_overlapping_bodies():
		if not _is_player(body): continue
		_player = body
		if _player.is_crocodile():
			_block_player()
		elif _player.coins <= 0 and _player.on_platform:
			_push_player_out()
		elif not occupied:
			_unblock_player()

func _push_player_out():
	$FeeTimer.stop()
	_player.move_and_slide(to_screen_center * 500)

func _steer_player():
	var heading_angle = _player.velocity.angle_to_point(Vector2())
	var new_angle = round(heading_angle / 45) * 45
	
	_player.velocity = _player.velocity.rotated(new_angle - heading_angle)

func _turn_green():
	$ColorChanger.play("TurnGreen")

func _on_FeeTimer_timeout():
	_occupier.take_away_coins(coins_per_second_rates * $FeeTimer.wait_time)