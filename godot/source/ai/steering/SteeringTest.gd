extends Node2D

onready var TestSubject = $TileMap/TestSubject
onready var ControlSubject = $TileMap/ControlSubject
onready var Steering = $TileMap/TestSubject/AI/Steering

func _ready():
	Global.Game = self
	Steering.player = TestSubject
	for behavior in Steering.get_children():
		behavior.player = TestSubject
	
	ControlSubject.controller = "P1"
	TestSubject.turn_normal()
	TestSubject.get_node("AI/WinGame").queue_free()
	ControlSubject.turn_normal()
	
func _physics_process(delta):
	TestSubject.velocity += Steering.steer()

func _process(delta):
	var mouse_position = get_global_mouse_position()
	
	if Input.is_mouse_button_pressed(BUTTON_RIGHT):
		$Target.position = mouse_position
	
func _on_Behavior_toggled(pressed, behavior_name):
	print("%s Toggled" % behavior_name)
	var behavior = Steering.get_node(behavior_name)
	if pressed:
		behavior.on($Target)
	else: behavior.off()

func _on_Pursuit_toggled(pressed):
	if pressed:
		Steering.pursuit_on(ControlSubject)
	else:
		Steering.pursuit_off()