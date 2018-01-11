extends Node2D

func reset():
	for platform in Global.Platforms:
		platform.reset()

func enable():
	for platform in Global.Platforms:
		platform.enable()

func disable():
	for platform in Global.Platforms:
		platform.disable()