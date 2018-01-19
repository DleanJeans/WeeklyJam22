extends KinematicBody2D

export(int) var magnet_speed = 50
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
	_update_notifier_position()
	_work_magnet()
	
func _update_notifier_position():
	$VisibilityNotifier.global_position = global_position

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

func _process(delta):
	_debug()

func _debug():
	if not Debug.Settings.debug_coins: return
	
	Debug.Labels.add_line(self, "%s" % global_position.floor(), Vector2(-100, 0))
