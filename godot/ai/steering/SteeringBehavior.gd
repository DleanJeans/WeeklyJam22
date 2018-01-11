extends Node2D

export(float) var multiplier = 1
export(bool) var is_on = false

onready var player = $"../../.."
var target

func execute():
	return Vector2()
 
func on(target = null):
	is_on = true
	self.target = target

func off():
	is_on = false
	target = null