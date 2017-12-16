extends Area2D

var collected = false

signal collected

func _on_collected(body):
	if _is_not_player(body): return
	if collected or body.is_crocodile(): return
	
	collected = true
	emit_signal("collected")
	body.collect_coin()

func _is_not_player(body):
	return not body is load("res://Player.gd")

func _on_animation_finished(name):
	if name == "Collected":
		queue_free()