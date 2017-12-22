extends "res://ai/goal/Goal.gd"

var target
var relocating_timer

func _ready():
	_name = "ChaseOthers"
	relocating_timer = Timer.new()
	relocating_timer.wait_time = 0.5
	relocating_timer.connect("timeout", self, "_relocate_target")
	add_child(relocating_timer)

func activate():
	.activate()
	_relocate_target()
	relocating_timer.start()

func _relocate_target():
	target = Locator.find_most_desired_player(player)
	steering.seek_on(target)

func process():
	.process()
	
	if not player.is_crocodile():
		state = GOAL_COMPLETED
	elif target == null or target.on_platform:
		_relocate_target()

func terminate():
	.terminate()
	steering.seek_off()
