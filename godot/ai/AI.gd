extends Node2D

onready var player = get_parent()

func enable():
	set_physics_process(true)

func disable():
	set_physics_process(false)

func _ready():
	$WinGame.activate()
	$Steering.separation_on()

func _physics_process(delta):
	if player.controller != "AI": return
	
	if has_node("WinGame"):
		$WinGame.process()
	
	player.velocity += $Steering.steer()
	
#	if not player.frozen:
#		_steer_if_blocked()

#func _steer_if_blocked():
#	if player.get_slide_count() > 0:
#		var velocity = player.velocity
#
#		var collision = player.get_slide_collision(0)
#		var normal = collision.normal
#		var tangent = velocity.tangent()
#		var velocity_dot = player.heading.dot(normal)
#		var tangent_dot = tangent.normalized().dot(normal)
#
#		if abs(velocity_dot) > 0.25 and abs(velocity_dot) < 0.9 and tangent_dot < 0:
#			tangent *= -1
#		velocity = tangent
#		player.move_and_slide(velocity)