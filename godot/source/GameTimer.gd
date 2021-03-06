extends Timer

export(int) var countdown_duration = 3
export(int) var round_end_countdown_duration = 5

export(bool) var enable_debug_duration = false setget set_enable_debug_duration
export(float) var debug_duration = 0.5 setget set_debug_duration

var durations = [1, 2, 3, 5]
var duration_index = 0
var minutes = 1
var round_duration = 60

func _get_time_left():
	return get_time_left()

onready var game = Global.Game

func hide():
	$GUI.hide()

func next_duration():
	_increment_duration_index()
	_calculate_round_duration()
	$GUI.update_main_menu_duration_button(minutes)

func _increment_duration_index():
	duration_index += 1
	duration_index = wrapi(duration_index, 0, durations.size())

func _calculate_round_duration():
	minutes = durations[duration_index]
	round_duration = minutes * 60

func pause():
	set_paused(true)

func resume():
	set_paused(false)

func start_counting_down():
	go_off_in(countdown_duration)
	$GUI.play_countdown_sequence()

func go_off_in(seconds):
	wait_time = seconds
	start()

func still_running():
	return time_left > 0 and not is_stopped()

func is_counting_down():
	return in_countdown_mode() and time_left > 0

func in_countdown_mode():
	return wait_time == countdown_duration

func in_round_mode():
	return wait_time == round_duration

func is_stopped_or_paused():
	return is_stopped() or is_paused()

func _on_timeout():
	if in_countdown_mode():
		_start_round_countdown()
		game.start()
	elif in_round_mode():
		game.end()

func _start_round_countdown():
	go_off_in(round_duration)
	$GUI.show_round_label()
	$GUI.update_round_label_every_sec()

func set_enable_debug_duration(value):
	enable_debug_duration = value
	if enable_debug_duration:
		durations.append(debug_duration)
	else: durations.erase(debug_duration)

func set_debug_duration(value):
	if enable_debug_duration:
		var index = durations.find(debug_duration)
		durations[index] = value
	debug_duration = value