extends Node2D

onready var player = get_parent()

func _ready():
	$WinGame.activate()

func _on_turning_crocodile():
	$Steering.all_off()
	$Steering.obstacle_avoidance_on()

func _on_turning_normal():
	$Steering.all_off()
	$Steering.separation_on()

func _physics_process(delta):
	if player.controller != "AI": return
	
	if has_node("WinGame"):
		$WinGame.process()
	
	player.velocity += $Steering.steer()