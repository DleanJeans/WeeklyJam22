extends Node

signal pre_fullscreen_toggle
signal post_fullscreen_toggle

export(bool) var enable_oversampling_workaround = true

var oversampling_affected = []

func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS

func _process(delta):
	if Input.is_action_just_pressed("toggle_fullscreen"):
		toggle()

func _pre_toggle():
	if not enable_oversampling_workaround: return
	Global.Game.hide()

func toggle():
	_pre_toggle()
	OS.window_fullscreen = not OS.window_fullscreen
	_post_toggle()

func _post_toggle():
	if not enable_oversampling_workaround: return
	Global.Game.show()