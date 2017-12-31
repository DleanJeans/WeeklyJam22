extends "res://ai/goal/Goal.gd"

var GoAroundPlatform = load("res://ai/goal/GoAroundPlatform.gd")

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
	
	go_around_platform_if_needed()

func go_around_platform_if_needed():
	if _has_subgoals() or player.get_slide_count() == 0: return
	
	var collision = player.get_slide_collision(0)
	
	var normal = collision.normal
	var heading = player.heading
	var dot = normal.dot(heading)
	if dot > -0.75: return
	
	var collider = collision.collider
	
	if collider is load("res://Platform.gd"):
		add_subgoal(GoAroundPlatform.new(collision.collider, target))

func terminate():
	.terminate()
	steering.seek_off()
	relocating_timer.queue_free()