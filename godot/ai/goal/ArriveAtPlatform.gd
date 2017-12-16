extends "res://ai/goal/Goal.gd"

var platform
var estimated_duration
onready var timer = Timer.new()

func _ready():
	_name = "ArriveAtPlatform"
	timer.one_shot = true
	timer.connect("timeout", self, "_goal_failed")

func _goal_failed():
	state = GOAL_FAILED

func activate():
	.activate()
	_relocate_platform()
	timer.start()

func _relocate_platform():
	platform = Locator.find_most_desired_platform(player)
	if platform == null:
		state = GOAL_FAILED
		return
	steering.arrive_on(platform)
	estimated_duration = platform.position.distance_to(player.position) / player.max_velocity
	timer.wait_time = estimated_duration

func process():
	.process()
	
	if platform == null:
		state = GOAL_FAILED
	elif Locator.distance(player, platform) <= 50 and not steering.get_node("Flee").is_panicking():
		state = GOAL_COMPLETED
	elif platform.occupied and not player.on_platform:
		state = GOAL_FAILED

func terminate():
	.terminate()
	steering.arrive_off()