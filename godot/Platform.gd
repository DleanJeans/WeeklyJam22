extends StaticBody2D

# ALWAYS keep $Shape/Area/Shape
# a lil bit larget than $Shape itself
# because only then _on_player_enter() can be called

var bounce_speed = 400

var to_screen_center
var occupied setget , _get_occupied

var _player
var _occupier
var _bounced_players = []
var _bounce_velocities = {}

func _ready():
	var screen_center = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height")) / 2
	to_screen_center = (screen_center - position).normalized()

func enable():
	set_process(true)

func disable():
	set_process(false)

func reset():
	_turn_green()

func _on_player_enter(body):
	if not _is_player(body): return
	
	_player = body
	
	if _player.just_landed:
		_unblock_player()
	elif _player_not_allowed():
		_block_player()
	else:
		_unblock_player()

func _is_player(body):
	return body.is_in_group(Global.PLAYERS_GROUP)

func _player_not_allowed():
	return _player.is_crocodile() or self.occupied

func _block_player():
	_player.collision_layer = Global.COLLISION_BLOCKED

func _unblock_player():
	_occupier = _player
	_player.on_platform = true
	_player.collision_layer = Global.COLLISION_NORMAL
	_player.frozen = false
	_turn_red()
	$AllowSound.play()

func _on_player_exited(player):
	player.frozen = false
	if self.occupied and player.on_platform:
		_occupier = null
		player.on_platform = false
		player.collision_layer = Global.COLLISION_NORMAL
		_turn_green()
	if player.is_connected("hit_wall", self, "_on_player_hit_wall"):
		player.disconnect("hit_wall", self, "_on_player_hit_wall")
	_bounce_velocities.erase(player)

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
		elif _player_pushed_out_by_others():
			_push_player_out()

func _no_one_here():
	return not self.occupied

func _player_pushed_out_by_others():
	return _player != _occupier and _player.collision_layer == Global.COLLISION_NORMAL and _occupier.pushing_out

func _push_player_out():
	var velocity
	
	if not _bounce_velocities.has(_player):
		var to_player = (_player.position - _occupier.position).normalized()
		velocity = to_player * bounce_speed
		
		_bounced_players.append(_player)
		_bounce_velocities[_player] = velocity
		
		_player.connect("hit_wall", self, "_on_player_hit_wall")
	
	velocity = _bounce_velocities[_player]
	_player.move_and_slide(velocity)

func _on_player_hit_wall(player, bounce_vector):
	if not _bounce_velocities.has(player): pass
	
	_bounce_velocities[player] *= bounce_vector

func _turn_green():
	$ColorChanger.play("TurnGreen")

func _get_occupied():
	return _occupier != null