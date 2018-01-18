extends Container

onready var game = Global.Game
onready var menu_button = $"/root/Game/UI/MenuButton"

var opened = true

signal play_pressed
signal map_pressed
signal duration_pressed

func update_duration_button(minutes):
	$DurationButton.text = "Duration: %s Minutes" % minutes

func update_map_button(map_name):
	$MapButton.text = "Map: %s" % map_name

func open():
	show()
	opened = true
	$PlayButton.grab_focus()
	$AnimationPlayer.play("Open")

func close():
	opened = false
	$AnimationPlayer.play("Close")
	yield($AnimationPlayer, "animation_finished")

func _ready():
	$PlayButton.grab_focus()

func _process(delta):
	if Input.is_action_just_pressed("toggle_main_menu") and OS.is_debug_build():
		if opened:
			close()
			menu_button.show()
			menu_button.grab_focus()
		else:
			open()
			menu_button.hide()

func _on_PlayButton_pressed():
	emit_signal("play_pressed")

func _on_MapButton_pressed():
	emit_signal("map_pressed")

func _on_RoundDurationButton_pressed():
	emit_signal("duration_pressed")

func _grab_focus_if_opened():
	if opened:
		$PlayButton.grab_focus()