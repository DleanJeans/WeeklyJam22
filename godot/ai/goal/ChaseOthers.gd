extends "res://ai/goal/GoalWithTarget.gd"

var GoAroundPlatform = load("res://ai/goal/GoAroundPlatform.gd")

func reacquire_target():
	target = Locator.find_most_desired_player(player)

func _target_acquired():
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
		player.groan()
		add_subgoal(GoAroundPlatform.new(collision.collider, target))

func terminate():
	.terminate()
	steering.seek_off()