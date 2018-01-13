extends Button

export(float) var delay = 2

func show_in_secs():
	yield(get_tree().create_timer(delay), "timeout")
	show()
	grab_focus()

func show():
	$AnimationPlayer.play("Show")

func hide():
	$AnimationPlayer.play("Hide")