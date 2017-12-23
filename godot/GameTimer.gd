extends Timer

export(int) var countdown_duration = 5

var durations = [1, 2, 3, 5, 10]
var duration_index = 2
var round_duration = 180

onready var game = get_parent()

func next_duration():
	duration_index += 1
	if duration_index >= durations.size():
		duration_index = 0
	
	var minutes = durations[duration_index]
	round_duration = minutes * 60
	get_parent().get_node("MainMenu/RoundDurationButton").text = "Duration: %s Minutes" % minutes

func hide():
	$RoundLabel.hide()
	$CountdownLabel.hide()

func show():
	if wait_time == round_duration:
		$RoundLabel.show()
	elif wait_time == countdown_duration:
		$CountdownLabel.show()

func pause():
	set_paused(true)

func resume():
	set_paused(false)

func start_counting_down():
	wait_time = countdown_duration
	start()
	$CountdownLabel.show()

func _start_round():
	wait_time = round_duration
	start()
	$RoundLabel.show()

func _on_timeout():
	$CountdownLabel.hide()
	$RoundLabel.hide()
	
	if in_countdown_mode():
		_start_round()
		game.start()
	elif in_round_mode():
		game.end()

func _process(delta):
	var time_left = get_time_left()
	
	if in_countdown_mode():
		$CountdownLabel.text = "%s" % round(time_left)
	elif in_round_mode():
		var minutes = floor(time_left / 60)
		var seconds = floor(time_left - 60 * minutes)
		$RoundLabel.text = "%s:%s" % [minutes, String(seconds).pad_zeros(2)]

func is_counting_down():
	return in_countdown_mode() and get_time_left() > 0

func in_countdown_mode():
	return wait_time == countdown_duration

func in_round_mode():
	return wait_time == round_duration