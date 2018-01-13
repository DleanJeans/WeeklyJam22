extends Container

onready var game = get_parent()
onready var menu_button = game.get_node("MenuButton")

var opened = true

signal play_pressed
signal map_pressed
signal duration_pressed

func update_duration_button(minutes):
	$RoundDurationButton.text = "Duration: %s Minutes" % minutes

func open():
	opened = true
	show()
	$PlayButton.grab_focus()
	$AnimationPlayer.play("Open")
	_toggle_joypad_hint()

func close():
	opened = false
	$AnimationPlayer.play("Close")

func _toggle_joypad_hint():
	if game.joypad_connected():
		$FullScreenHints/L1.show()
	else: $FullScreenHints/L1.hide()

func _ready():
	$PlayButton.grab_focus()
	_toggle_joypad_hint()

func _process(delta):
	if Input.is_action_just_pressed("toggle_main_menu") and OS.is_debug_build():
		if opened:
			close()
			menu_button.show()
			menu_button.grab_focus()
		else:
			open()
			menu_button.hide()

func _on_FullScreenButton_pressed():
	Global.toggle_fullscreen()

func _on_PlayButton_pressed():
	emit_signal("play_pressed")

func _on_MapButton_pressed():
	emit_signal("map_pressed")

func _on_RoundDurationButton_pressed():
	emit_signal("duration_pressed")