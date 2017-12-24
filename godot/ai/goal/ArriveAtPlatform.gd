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
	elif Locator.distance(player, platform) <= 40 and not player.is_panicking():
		state = GOAL_COMPLETED
	elif _blocked_out_of_platform():
		player.jump()

func _blocked_out_of_platform():
	return player.collision_layer == Global.COLLISION_BLOCKED

func terminate():
	.terminate()
	steering.arrive_off()