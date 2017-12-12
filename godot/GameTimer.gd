extends Timer

export(int) var countdown_duration = 3
export(int) var round_duration = 180

onready var game = get_parent()

func start_playing():
	_start_preround()

func _start_preround():
	wait_time = countdown_duration
	start()
	$PreroundLabel.show()

func _start_round():
	wait_time = round_duration
	start()
	$RoundLabel.show()

func _on_timeout():
	$PreroundLabel.hide()
	$RoundLabel.hide()
	
	if _in_countdown_mode():
		_start_round()
		game.start()
	elif _in_normal_mode():
		game.end()

func _process(delta):
	var time_left = get_time_left()
	
	if _in_countdown_mode():
		$PreroundLabel.text = String(round(time_left))
	elif _in_normal_mode():
		var minutes = floor(time_left / 60)
		var seconds = floor(time_left - 60 * minutes)
		if seconds < 10:
			seconds = "0%s" % seconds
		$RoundLabel.text = "%s:%s" % [minutes, seconds]

func _in_countdown_mode():
	return wait_time == countdown_duration

func _in_normal_mode():
	return wait_time == round_duration