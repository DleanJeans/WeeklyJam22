extends CanvasLayer

const SWIM = "Swim!"
const GAME_OVER = "Game Over!"

onready var timer = get_parent()

func update_main_menu_duration_button(minutes):
	$"/root/Game/MainMenu".update_duration_button(minutes)

func show_round_label():
	$RoundLabel.show()

func show_countdown_label():
	$CountdownLabel.show()

func hide():
	$RoundLabel.hide()
	$CountdownLabel.hide()

func update_round_label_every_sec():
	while _rounded_time_left() > timer.round_end_countdown_duration:
		_update_round_label()
		yield(Utility.timer(1), "timeout")
	if not timer.is_stopped_or_paused():
		$RoundLabel.hide()
		play_countdown_sequence()

func play_countdown_sequence():
	$CountdownLabel.show()
	_start_countdown_animation()
	_update_countdown_label()
	
	while _rounded_time_left() > 0:
		yield(Utility.timer(1), "timeout")
		_update_countdown_label()

func play_last_sequence():
	_play_last_sound()
	
	yield(Utility.timer(1), "timeout")
	
	print("Disappeared!")
	_play_countdown_label_disappear_animation()

func _play_countdown_label_disappear_animation():
	$CountdownAnimation.play("Disappear", 0.1)

func _play_last_sound():
	if timer.in_countdown_mode():
		$StringSound.play()
	elif timer.in_round_mode():
		$GameOverVoice.play()

func _update_round_label():
	var minutes = floor(timer.time_left / 60)
	var seconds = floor(timer.time_left - 60 * minutes)
	var seconds_padded = str(seconds).pad_zeros(2)
	var text = "%s:%s" % [minutes, seconds_padded]
	
	$RoundLabel.text = text

func _update_countdown_label():
	var time_left = _rounded_time_left()
	print("%s -> %s" % [timer.time_left, time_left])
	var text = "%s" % time_left
	
	if time_left == 0:
		if timer.in_countdown_mode():
			text = SWIM
		elif timer.in_round_mode():
			text = GAME_OVER
	
	$CountdownLabel.text = text

func _rounded_time_left():
	return round(timer.time_left) 

func _play_ticking_sound():
	var time_left = _rounded_time_left()
	if time_left > 0 and time_left < timer.countdown_duration + 2:
		$TikSound.play()

func _start_countdown_animation():
	$CountdownAnimation.play(".")

func _stop_countdown_animation():
	$CountdownAnimation.stop()

func _countdown_label_text_is(text):
	return $CountdownLabel.text == text