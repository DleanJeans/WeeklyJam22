extends Node2D

const WHITE = Color("#ffffff")
var debug_label_offset = Vector2(40, -100)

var crocodile setget set_crocodile, get_crocodile

onready var PanicRadius = $"../PanicRadius"
onready var player = get_parent()

func set_crocodile(value):
	Global.crocodile = value

func get_crocodile():
	return Global.crocodile

func is_close_to_at_least_3_others():
	if player.frozen or not player.is_crocodile(): return

	var bodies = PanicRadius.get_overlapping_bodies()
	var players_count = 0

	for b in bodies:
		if b is Classes.Player and b != self:
			players_count += 1
			if players_count == 3:
				return true

	return false

func not_taggable(body):
	if not body is Classes.Player: return true
	
	var is_self = body == player
	var self_not_crocodile = not player.is_crocodile()
	
	return is_self or self_not_crocodile or player.frozen or body.on_platform

func setup_debug():
	yield(Utility.timer(0.1), "timeout")
	if Debug.Labels.node_not_added(player):
		Debug.Labels.add_label(player, debug_label_offset)
	else: Debug.Labels.set_offset(player, debug_label_offset)

func debug(text):
	if OS.is_debug_build() and Debug.Settings.debug_players:
		Debug.Labels.add_line(player, text)

func remove_debug():
	Debug.Labels.remove_label(player)