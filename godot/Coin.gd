extends Area2D

export(int) var magnet_speed = 100
var collected = false

signal collected

func _on_collected(body):
	if _is_not_player(body): return
	if collected or body.is_crocodile(): return
	
	collected = true
	emit_signal("collected")
	body.collect_coins()

func _is_not_player(body):
	return not body is load("res://Player.gd")

func _on_animation_finished(name):
	if name == "Collected":
		queue_free()

func _physics_process(delta):
	var bodies = $MagnetRadius.get_overlapping_bodies()
	for body in bodies:
		if not body in Global.Players or body == Global.crocodile: continue
		
		var to_player = (body.position - position).normalized()
		var movement = to_player * delta * magnet_speed
		
		if body.is_crocodile():
			position += -movement
		else: position += movement