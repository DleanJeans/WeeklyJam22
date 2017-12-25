extends Node2D

export(String) var name = "Map Name"

export(float) var position_tween_time = 0.5

onready var _tween = Tween.new()

var _players = []
var _positions = {}

func _ready():
	_record_positions()
	add_child(_tween)

func _record_positions():
	for player in $Objects.get_children():
		_players.append(player)
		_positions[player] = player.position

func reset_positions():
	for player in _players:
		_tween.interpolate_property(player, "position", player.position, _positions[player], position_tween_time, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	_tween.start()