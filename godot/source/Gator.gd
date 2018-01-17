extends Sprite

var blend_time = 0.1

func rawr():
	if $RawrAnimation.is_playing(): return
	
	if flip_h:
		_play_animation("Right")
	else: _play_animation("Left")
	
	$GroanSound.play()

func _process(delta):
	_flip_to_moving_direction()
	_flip_rawr_animation_if_turn()

func _flip_to_moving_direction():
	if Global.crocodile == null: return
	
	var velocity = Global.crocodile.velocity
	if velocity.x < 0 and _is_flip_right():
		$AnimationPlayer.play("TurnLeft")
	elif velocity.x > 0 and _is_flip_left():
		$AnimationPlayer.play("TurnRight")

func _flip_rawr_animation_if_turn():
	if $RawrAnimation.is_playing():
		var current_position = $RawrAnimation.get_current_animation_position()
		var playing_animation = $RawrAnimation.get_current_animation()
		
		if flip_h and playing_animation != "Right":
			_play_animation("Right")
		elif not flip_h and playing_animation != "Left":
			_play_animation("Left")
		
		$RawrAnimation.seek(current_position)

func _play_animation(animation_name):
	$RawrAnimation.play(animation_name, blend_time)

func _is_flip_left():
	return not flip_h

func _is_flip_right():
	return flip_h