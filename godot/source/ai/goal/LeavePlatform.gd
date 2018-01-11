extends "res://source//ai/goal/Goal.gd"

func process():
	.process()
	
	if Global.player_blocked_by_platform(player):
		player.jump()