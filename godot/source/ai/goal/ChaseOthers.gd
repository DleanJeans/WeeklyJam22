extends "res://source/ai/goal/GoalWithTarget.gd"

func reacquire_target():
	if player != null:
		target = Locator.find_most_desired_player(player)

func _target_acquired():
	steering.seek_on(target)

func process():
	.process()
	
	if not player.is_crocodile():
		terminate()
	
	go_around_platform_if_needed()

func go_around_platform_if_needed():
	if _has_subgoals() or player.get_slide_count() == 0: return
	
	var collision = player.get_slide_collision(0)
	
	var normal = collision.normal
	var heading = player.heading
	var dot = normal.dot(heading)
	if dot > -0.75: return
	
	var collider = collision.collider
	
	if collider is Classes.Platform:
		player.rawr()
		add_subgoal(Classes.GoAroundPlatform.new(collision.collider, target))

func terminate():
	.terminate()
	steering.seek_off()