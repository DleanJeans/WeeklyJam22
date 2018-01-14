tool
extends Control

export(String, "A", "3", "Enter", "L1", "Space", "Start", "F11") var button = "Space" setget set_button

func set_button(button_name):
	button = button_name
	
	if not has_node("Sprites"): return
	
	for sprite in $Sprites.get_children():
		sprite.hide()
	$Sprites.get_node(button).show()

func set_visible(value):
	if visible != value:
		if visible:
			$AnimationPlayer.play("PopUp")
		else: $AnimationPlayer.play("PopOut")
			
	visible = value

func pop_up():
	$AnimationPlayer.play("PopUp")

func pop_out():
	$AnimationPlayer.play("PopOut")