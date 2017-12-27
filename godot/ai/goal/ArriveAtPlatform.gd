extends "res://ai/goal/Goal.gd"

var platform
var estimated_duration
onready var fail_timer = Timer.new()

func _ready():
	_name = "ArriveAtPlatform"
	_init_fail_timer()

func _init_fail_timer():
	fail_timer.one_shot = true
	fail_timer.wait_time = 1.5
	fail_timer.connect("timeout", self, "_goal_failed")

func _goal_failed():
	state = GOAL_FAILED

func activate():
	.activate()
	_relocate_platform()
	fail_timer.start()

func _relocate_platform():
	platform = Locator.find_most_desired_platform(player)
	if platform == null:
		state = GOAL_FAILED
		return
	steering.arrive_on(platform)

func process():
	.process()

	if platform == null:
		state = GOAL_FAILED
	elif Utility.distance_squared(player, platform) <= 1600 and not player.is_panicking():
		state = GOAL_COMPLETED
	elif _blocked_out_of_platform():
		player.jump()

func _blocked_out_of_platform():
	return player.collision_layer == Global.COLLISION_BLOCKED

func terminate():
	.terminate()
	steering.arrive_off()