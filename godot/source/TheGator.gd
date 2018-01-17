extends Node2D

onready var Gator = $Gator

var crocodile

func reparent_here():
	reparent(self)

func reparent_to_crocodile():
	if Global.crocodile != null:
		var player_sprite = Global.crocodile.get_node("Sprite")
		reparent(player_sprite)

func reparent(new_parent):
	Utility.reparent(Gator, new_parent)

func _ready():
	Global.connect("crocodile_changed", self, "_on_crocodile_changed")

func _on_crocodile_changed():
	crocodile = Global.crocodile
	if crocodile == null:
		hide()
		return
	else:
		show()
	
	_listen_to_crocodile_going_rawr()
	reparent_to_crocodile()

func _listen_to_crocodile_going_rawr():
	if not crocodile.is_connected("rawr", Gator, "rawr"):
		crocodile.connect("rawr", Gator, "rawr")