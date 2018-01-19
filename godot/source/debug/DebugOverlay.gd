extends Control

export(bool) var debug_players = false
export(bool) var debug_goal_tree = false
export(bool) var debug_steering = false

export(bool) var debug_coins = false

export(bool) var debug_crown = false

export(bool) var enable_slo_mo = false
export(float) var slo_mo_scale = 0.1

func _ready():
	Debug.Settings = self
	if not OS.is_debug_build():
		queue_free()
	
	call_deferred("raise")