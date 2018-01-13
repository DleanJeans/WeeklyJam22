extends Node2D

func reset():
	_call_all("reset")

func enable():
	_call_all("enable")

func disable():
	_call_all("disable")

func stop_bounce_tween():
	_call_all("stop_bounce_tween")

func _call_all(method):
	get_tree().call_group("Platforms", method)