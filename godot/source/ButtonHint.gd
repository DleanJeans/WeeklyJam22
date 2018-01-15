tool
extends Control

export(String, "A", "3", "Space", "Enter") var button = "A" setget set_button

var buttons = ["A", "3", "Space", "Enter"]

func set_button(button_name):
	button = button_name
	if has_node("Sprite"):
		$Sprite.frame = buttons.find(button_name)

func set_visible(value):
	if visible != value:
		if visible:
			$AnimationPlayer.play("PopUp")
		else: $AnimationPlayer.play("PopOut")
			
	visible = value

func pop_up():
	$AnimationPlayer.play("PopUp")

func pop_out():
	$AnimationPlayer.play_backwards("PopUp")

func _process(delta):
	if Input.is_action_just_pressed("p1_action"):
		pop_out()