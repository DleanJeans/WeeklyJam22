extends Area2D

export(float) var radius = 0
export(int) var pushing_speed = 500

var platform
var stomper

var _affected_players = {}
var _current_player

func init(platform, stomper):
	self.platform = platform
	self.stomper = stomper
	
	_set_position_at_stomper()
	_connect_signal_player_exited()

func _set_position_at_stomper():
	position = platform.to_local(stomper.position)

func _connect_signal_player_exited():
	platform.connect("player_exited", self, "_on_player_exited_platform")

func _ready():
	_key_max_radius_in_animation()

func _key_max_radius_in_animation():
	var animation = $Animation.get_animation(".")
	var radius_track = 0
	var second_key = 1
	var max_radius = _platform_across_length()
	
	animation.track_set_key_value(radius_track, second_key, max_radius)

func _platform_across_length():
	var platform_shape = platform.get_node("Shape").shape
	var platform_size = platform_shape.extents * 2 * platform.scale
	
	return platform_size.length()

func _on_player_exited_platform(player):
	_current_player = player
	if _player_is_stomper() or not _player_being_affected() or _player_is_crocodile(): return
	
	_remove_player_from_list()
	_disconnect_hit_wall_signal()
	disconnect_signal_player_exited()
	_unfreeze_player()
	_free_if_shockwave_ended()

func _player_is_crocodile():
	return _current_player.is_crocodile()

func _remove_player_from_list():
	_affected_players.erase(_current_player)

func _disconnect_hit_wall_signal():
	if _current_player.is_connected("hit_wall", self, "_on_player_hit_wall"):
		_current_player.disconnect("hit_wall", self, "_on_player_hit_wall")

func _unfreeze_player():
	_current_player.frozen = false

func _free_if_shockwave_ended():
	if _shockwave_ended():
		queue_free()

func _shockwave_ended():
	var list_empty = _affected_players.empty()
	var animation_finished = not $Animation.is_playing()
	
	return list_empty and animation_finished

func disconnect_signal_player_exited():
	if platform.is_connected("player_exited", self, "_on_player_exited_platform"): 
		platform.disconnect("player_exited", self, "_on_player_exited_platform")

func _physics_process(delta):
	for player in platform.get_players_inside():
		_current_player = player
		if _player_is_stomper() or _player_is_crocodile(): continue
		
		if _player_in_radius_first_time():
			_add_player_to_list()
			_connect_hit_wall_signal()
			_freeze_player()
		elif _player_being_affected():
			_push_player_out()

func _player_is_stomper():
	return _current_player == stomper

func _player_in_radius_first_time():
	var not_in_the_list = not _player_being_affected()
	
	return not_in_the_list and _player_inside_radius()

func _player_inside_radius():
	var distance_squared = Utility.distance_squared(to_global(self.position), _current_player)
	var radius_squared = radius * radius
	
	return distance_squared <= radius_squared

func _add_player_to_list():
	var pushing_velocity = _calculate_pushing_velocity()
	_affected_players[_current_player] = pushing_velocity

func _calculate_pushing_velocity():
	var to_player = Utility.unit_vector_from(stomper, _current_player)
	var velocity = to_player * pushing_speed
	if velocity == Vector2():
		velocity.x = 1
	
	return velocity

func _connect_hit_wall_signal():
	_current_player.connect("hit_wall", self, "_on_player_hit_wall") 

func _freeze_player():
	_current_player.frozen = true

func _on_player_hit_wall(player, bounce_back):
	_affected_players[player] *= bounce_back

func _player_got_off_platform():
	return not _current_player.on_platform

func _player_being_affected():
	return _affected_players.has(_current_player)

func _push_player_out():
	var velocity = _affected_players[_current_player]
	
	_current_player.move_and_slide(velocity)