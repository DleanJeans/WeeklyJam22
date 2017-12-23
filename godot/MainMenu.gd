extends Container

onready var game = get_parent()

signal shown
signal play_pressed
signal map_pressed
signal duration_pressed

func show():
	.show()
	emit_signal("shown")

func _ready():
	$PlayButton.grab_focus()

func _on_FullScreenButton_pressed():
	Global.toggle_fullscreen()

func _on_PlayButton_pressed():
	emit_signal("play_pressed")

func _on_MapButton_pressed():
	emit_signal("map_pressed")

func _on_RoundDurationButton_pressed():
	emit_signal("duration_pressed")
