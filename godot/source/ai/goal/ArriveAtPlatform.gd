extends "res://source/ai/goal/GoalWithTarget.gd"

var platform
onready var fail_timer = Timer.new()

func _ready():
	_setup_fail_timer()

func _setup_fail_timer():
	fail_timer.one_shot = true
	fail_timer.wait_time = 1.5
	fail_timer.connect("timeout", self, "_goal_failed")
	add_child(fail_timer)

func _goal_failed():
	state = GOAL_FAILED

func activate():
	.activate()
	fail_timer.start()

func reacquire_target():
	undip_platform()
	platform = Locator.find_most_desired_platform(player)
	dip_platform()
	if platform == null:
		state = GOAL_FAILED

func dip_platform():
	if platform != null:
		platform.dip(player)

func undip_platform():
	if platform != null:
		platform.undip(player)

func _target_acquired():
	steering.seek_on(platform)

func process():
	.process()

	if platform == null:
		state = GOAL_FAILED
	elif _get_enough_on_platform() and not player.is_panicking():
		state = GOAL_COMPLETED
	elif Global.player_blocked_by_platform(player):
		player.jump()

func _get_enough_on_platform():
	var distance_squared_to_platform = Utility.distance_squared(player, platform)
	
	return distance_squared_to_platform < 30 * 30

func terminate():
	.terminate()
	steering.seek_off()
	fail_timer.queue_free()
	undip_platform()