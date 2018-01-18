extends KinematicBody2D

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
	return not body is Classes.Player

func _physics_process(delta):
	_work_magnet()

func _work_magnet():
	var bodies = $MagnetRadius.get_overlapping_bodies()
	for body in bodies:
		if not body in Global.Players: continue
		
		_magnet_player(body)

func _magnet_player(player):
	var to_player = Utility.unit_vector_from(self, player)
	var velocity = to_player * magnet_speed
	
	if player.is_crocodile():
		move_and_slide(-velocity)
	else: move_and_slide(velocity)

func _on_screen_exited():
	queue_free()
	print("Coin out of screen! Free!")