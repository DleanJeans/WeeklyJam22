extends Container

onready var game = get_parent()

signal shown
signal hidden

func show():
	.show()
	emit_signal("shown")

func hide():
	.hide()
	emit_signal("hidden")

func _ready():
	$PlayButton.grab_focus()

func _process(delta):
	if not visible:
		if Input.is_action_just_pressed("ui_select"):
			show()
	else:
		if Input.is_action_just_pressed("ui_cancel"):
			$ResumeButton.emit_signal("pressed")

func _on_FullScreenButton_pressed():
	Global.toggle_fullscreen()