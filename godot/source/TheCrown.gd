extends Node2D

export(float) var transition_duration = 0.5

onready var Crown = $Sprite/Crown
onready var PopOutAnimation = $Sprite/Crown/PopOutAnimation

var keeping_winner_jumping = false

var _leader
var _player

func _ready():
	$Sprite.self_modulate.a = 0

func keep_winner_jumping():
	keeping_winner_jumping = true
	_leader.hide_button_hint()
	
	while keeping_winner_jumping:
		_leader.force_jump()
		yield(Utility.timer(Const.JUMP_DURATION), "timeout")

func stop_winner_jumping():
	keeping_winner_jumping = false

func reset():
	_leader = null
	Crown.hide()
	Crown.reparent_to_the_crown()

func on_player_coins_collected(player):
	_player = player
	
	if _player_qualifies_as_the_new_leading():
		_stop_transition_tween()
		
		_pop_out_if_no_leader()
		_fly_to_player_otherwise()
		
		_set_player_as_new_leader()
		_reparent_crown_to_leader_sprite_on_tween_completed()

func _stop_transition_tween():
	$TransitionTween.stop_all()

func _player_qualifies_as_the_new_leading():
	var no_leader = _no_leader()
	var is_leading = _player == _leader
	
	if no_leader:
		return true
	elif is_leading:
		return false
	
	var has_same_or_more_coins = _player.coins >= _leader.coins and _player.coins > 0
	
	return has_same_or_more_coins

func _no_leader():
	return _leader == null

func _pop_out_if_no_leader():
	if _no_leader():
		Crown.reparent_to_player_sprite(_player)
		Crown.pop_out()

func _fly_to_player_otherwise():
	if _no_leader(): return
	
	_set_tween_to_player_position()
	$TransitionTween.start()
	$SwooshSound.play()
	Crown.reparent_to_the_crown()

func _set_tween_to_player_position():
	$TransitionTween.follow_property(self, "position", Crown.global_position, _player, "position", transition_duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)

func _set_player_as_new_leader():
	_leader = _player

func _reparent_crown_to_leader_sprite_on_tween_completed():
	yield($TransitionTween, "tween_completed")
	if Crown.is_child_to_the_crown() and _leader != null:
		Crown.reparent_to_player_sprite(_leader)