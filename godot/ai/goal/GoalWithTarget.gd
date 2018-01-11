extends "res://ai/goal/Goal.gd"

onready var timer = Timer.new()
var target

func _ready():
	_setup_timer()

func _setup_timer():
	timer.wait_time = 0.3
	timer.connect("timeout", self, "reacquire_target")
	timer.connect("timeout", self, "_target_acquired", [], Timer.CONNECT_DEFERRED)
	timer.start()
	add_child(timer)

func pause_acquisition():
	timer.set_paused(true)

func resume_acquisition():
	timer.set_paused(false)

func activate():
	.activate()
	reacquire_target()
	_target_acquired()

func reacquire_target():
	pass

func _target_acquired():
	pass

func terminate():
	.terminate()
	timer.queue_free()