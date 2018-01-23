extends Control

signal play_again
signal main_menu

export(float) var delay = 1.5
var showing = false

func _ready():
	_hide_immediately()

func _hide_immediately():
	hide()
	$AnimationPlayer.seek(0)

func show_in_secs():
	yield(get_tree().create_timer(delay), "timeout")
	show()
	$Buttons/PlayAgainButton.grab_focus()

func show():
	showing = true
	$AnimationPlayer.play("Show")

func hide():
	showing = false
	$AnimationPlayer.play_backwards("Show")
	$Buttons/PlayAgainButton.release_focus()

func _play_again():
	emit_signal("play_again")

func _main_menu():
	emit_signal("main_menu")

func _hide_if_not_showing():
	if not showing:
		_hide_immediately()