extends "res://ai/goal/GoalWithTarget.gd"

var platform
onready var fail_timer = Timer.new()

func _ready():
	_name = "ArriveAtPlatform"
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
	steering.arrive_on(platform)

func process():
	.process()

	if platform == null:
		state = GOAL_FAILED
	elif _get_enough_on_platform() and not player.is_panicking():
		state = GOAL_COMPLETED
	elif _blocked_out_of_platform():
		player.jump()

func _get_enough_on_platform():
	var distance_squared_to_platform = Utility.distance_squared(player, platform)
	
	return distance_squared_to_platform < 30 * 30

func _blocked_out_of_platform():
	return player.collision_layer == Global.COLLISION_BLOCKED

func terminate():
	.terminate()
	steering.arrive_off()
	fail_timer.queue_free()
	undip_platform()