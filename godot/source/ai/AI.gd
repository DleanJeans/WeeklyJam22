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