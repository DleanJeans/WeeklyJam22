extends "res://ai/goal/Goal.gd"

onready var reacquire_timer = Timer.new()

func _ready():
	name = "GoalWithTarget"
	_setup_timer()

func _setup_timer():
	reacquire_timer.wait_time = 0.2
	reacquire_timer.connect("timeout", self, "reacquire_target")
	reacquire_timer.connect("timeout", self, "_target_acquired", [], Timer.CONNECT_DEFERRED)
	reacquire_timer.start()
	add_child(reacquire_timer)

func reacquire_target():
	pass

func _target_acquired():
	pass