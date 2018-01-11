extends "res://ai/goal/Goal.gd"

func process():
	.process()
	
	if Utility.player_blocked_by_platform(player):
		player.jump()