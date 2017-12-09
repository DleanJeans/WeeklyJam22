extends KinematicBody2D

export(String, "P1", "P2", "P3", "P4", "AI") var controller = "AI"
export(int) var max_velocity = 100
export(Vector2) var drag_scale = Vector2(0.9, 0.9)

onready var platform_offset = $Sprite.texture.get_height() * $Sprite.scale.y

var last_visited_platform
var on_platform = false

var velocity = Vector2()
var acceleration = Vector2()
var frozen = false

func toggle_frozen():
	frozen = not frozen

func move(direction):
	velocity += direction * max_velocity

func turn_normal():
	$Sprite.modulate = Color("#ffffff") # white, duh

func turn_crocodile():
	$Sprite.modulate = Global.CROCODILE_GREEN

func is_crocodile():
	return $Sprite.modulate == Global.CROCODILE_GREEN

func pass_crocodile(player_area):
	var player = player_area.get_parent()
	if _not_passable(player):
		return
	
	player.turn_crocodile()
	player.get_node("FreezeTimer").start()
	self.turn_normal()

func _not_passable(player):
	return not is_crocodile() or not player is load("res://Player.gd") or frozen

func _physics_process(delta):
	$DebugLabel.text = ""
	if frozen: return
	
	velocity += acceleration * delta
	velocity *= drag_scale
	clamp_velocity()
	move_and_slide(velocity)
	append_debug_info("Layer: %s" % collision_layer)

func append_debug_info(info):
	$DebugLabel.text += "%s\n" % info

func clamp_velocity():
	velocity = velocity.clamped(max_velocity)