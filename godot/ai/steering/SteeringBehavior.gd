extends Node2D

export(float) var multiplier = 1

onready var player = $"../../.."
var is_on = false
var target

func execute():
	return Vector2()

func on(target = null):
	is_on = true
	self.target = target

func off():
	is_on = false
	target = null