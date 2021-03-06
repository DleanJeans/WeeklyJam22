extends "res://source/ai/goal/Goal.gd"

var platform
var timer

func _ready():
	timer = Timer.new()
	timer.wait_time = 2
	timer.connect("timeout", self, "_get_on_platform")
	add_child(timer)

func _get_on_platform():
	terminate()
	get_parent().add_subgoal(Classes.ArriveAtPlatform.new())

func activate():
	.activate()
	steering.flee_on(Global.crocodile)
	timer.start()

func process():
	.process()
	
	if _got_away():
		terminate()

func _got_away():
	var on_platform = player.on_platform
	var not_panicking_anymore = not steering.get_node("Flee").is_panicking(Global.crocodile)
	var crocodile_frozen = Global.crocodile.frozen
	
	return on_platform or not_panicking_anymore or crocodile_frozen

func terminate():
	.terminate()
	steering.flee_off()
	timer.queue_free()