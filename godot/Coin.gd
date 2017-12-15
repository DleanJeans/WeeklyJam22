extends Area2D

var collected = false

signal collected

func _on_collected(player):
	if collected or player.is_crocodile(): return
	collected = true
	
	emit_signal("collected")
	player.collect_coin()

func _on_animation_finished(name):
	if name == "Collected":
		queue_free()