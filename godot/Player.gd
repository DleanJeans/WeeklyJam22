extends KinematicBody2D

export(int) var max_velocity = 100
export(float) var drag_scale = 0.8

onready var platform_offset = $Sprite.texture.get_height() * $Sprite.scale.y

var controller = "AI" setget _set_controller
var last_visited_platform
var on_platform = false

var velocity = Vector2()
var heading = Vector2()
var frozen = false

var coins = 0

var _debug_text = ""

signal turning_crocodile
signal turning_normal

func reset():
	turn_normal()
	coins = 0
	self.controller = "AI"
	$FreezeTimer.stop()
	if not frozen:
		toggle_frozen()

func jump():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Jump")

func toggle_frozen():
	frozen = not frozen

func collect_coin():
	coins += 1
	$Sprite/CoinLabel.text = String(coins)

func move(direction, multiplier = 1):
	velocity += direction.normalized() * max_velocity * multiplier

func moving_vector(direction, multiplier = 1):
	return direction.normalized() * max_velocity * multiplier

func turn_normal():
	emit_signal("turning_normal")
	$Sprite.modulate = Global.WHITE

func turn_crocodile():
	emit_signal("turning_crocodile")
	Global.crocodile = self
	$Sprite.modulate = Global.CROCODILE_GREEN

func is_crocodile():
	return $Sprite.modulate == Global.CROCODILE_GREEN

func tag_crocodile(player_area):
	var player = player_area.get_parent()
	if _not_taggable(player):
		return
	
	player.turn_crocodile()
	player.get_node("FreezeTimer").start()
	self.turn_normal()
	$TapSound.play()

func _not_taggable(player):
	return not is_crocodile() or not player is load("res://Player.gd") or frozen or player.on_platform

func _physics_process(delta):
	$DebugLabel.text = "[Debug]\n"
	debug("On Platform: %s" % on_platform)
	
	if frozen: return
	
	clamp_velocity()
	move_and_slide(velocity)
	velocity *= drag_scale
	
	heading = velocity.normalized()

func debug(info):
	$DebugLabel.text += "%s\n" % info

func clamp_velocity():
	velocity = velocity.clamped(max_velocity)

func set_name_tag(name):
	$Sprite/NameTag.text = name

func _set_controller(value):
	controller = value
	if $Sprite/NameTag == null: return
	
	$Sprite/NameTag.text = value
	if value == "AI":
		$Sprite/NameTag.hide()
	else: $Sprite/NameTag.show()