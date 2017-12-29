extends StaticBody2D

# ALWAYS keep $Shape/Area/Shape
# a lil bit larget than $Shape itself
# because only then _on_player_enter() can be called

signal player_exited(player)

export(bool) var requires_path_around = true

var occupied setget , _get_occupied

var _player
var _occupier

func get_players_inside():
	return $Shape/Area.get_overlapping_bodies()

func reset():
	_turn_green()

func _on_player_enter(body):
	if not _is_player(body): return
	_player = body
	if _player.is_crocodile(): return
	
	if _player.just_landed:
		_unblock_player()
		_create_shockwave()
	elif _player_not_allowed():
		_block_player()
	else:
		_unblock_player()

func _unblock_player():
	_occupier = _player
	_player.on_platform = true
	_player.collision_layer = Global.COLLISION_NORMAL
	_turn_red()
	$AllowSound.play()

func _is_player(body):
	return body is load("res://Player.gd")

func _create_shockwave():
	var shockwave = load("res://Shockwave.tscn").instance()
	shockwave.init(self, _player)
	add_child(shockwave)

func _player_not_allowed():
	return _player.is_crocodile() or self.occupied

func _block_player():
	_player.collision_layer = Global.COLLISION_BLOCKED

func _on_player_exited(player):
	emit_signal("player_exited", player) 
	if self.occupied and player.on_platform:
		if _occupier == player:
			_occupier = null
		player.on_platform = false
		player.collision_layer = Global.COLLISION_NORMAL
		_turn_green()
	
	player._leave_platform()

func _turn_red():
	$ColorChanger.play("TurnRed")

func _process(delta):
	for body in $Shape/Area.get_overlapping_bodies():
		if not _is_player(body): continue
		_player = body
		
		if _player.is_crocodile():
			_block_player()
		elif _no_one_here():
			_unblock_player()

func _no_one_here():
	return not self.occupied

func _turn_green():
	$ColorChanger.play("TurnGreen")

func _get_occupied():
	return _occupier != null