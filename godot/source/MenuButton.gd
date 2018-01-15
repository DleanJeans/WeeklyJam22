extends Button

export(float) var delay = 2
var showing = false

func show_in_secs():
	yield(get_tree().create_timer(delay), "timeout")
	show()
	grab_focus()

func show():
	showing = true
	$AnimationPlayer.play("Show")

func hide():
	showing = false
	$AnimationPlayer.play_backwards("Show")