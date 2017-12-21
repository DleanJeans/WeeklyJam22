extends Node2D

onready var player = get_parent()

func _ready():
	$WinGame.activate()
	$Steering.separation_on()

func _physics_process(delta):
	if player.controller != "AI": return
	
	if has_node("WinGame"):
		$WinGame.process()
	
	player.velocity += $Steering.steer()