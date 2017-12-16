extends KinematicBody2D

const COINS_PERCENT_TRANSFERRED_ON_TAG = 50
const BONUS_COINS_ON_TAG = 10

export(int) var max_velocity = 300
export(float) var drag_scale = 0.8

onready var platform_offset = $Sprite.texture.get_height() * $Sprite.scale.y

var controller = "AI" setget _set_controller
var on_platform = false

var velocity = Vector2()
var heading = Vector2()
var frozen = false

var coins = 0 setget _set_coins

var _debug_text = ""

signal turning_crocodile
signal turning_normal

func reset():
	turn_normal()
	self.coins = 0
	self.controller = "AI"
	$AI/WinGame.clear_subgoals()
	$FreezeTimer.stop()
	if not frozen:
		toggle_frozen()
	$WinnerLabel.hide()

func jump():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Jump")

func toggle_frozen():
	frozen = not frozen

func collect_coin(amount = 10):
	self.coins += amount

func take_away_coin(amount):
	self.coins -= amount
	if self.coins < 0:
		self.coins = 0

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
	
	var coins_transferred = _coins_transferred(player)
	
	player.turn_crocodile()
	player.get_node("FreezeTimer").start()
	player.take_away_coin(coins_transferred)
	
	self.turn_normal()
	self.collect_coin(coins_transferred + BONUS_COINS_ON_TAG)
	
	$TapSound.play()

func _coins_transferred(player):
	var coins = ceil(player.coins * COINS_PERCENT_TRANSFERRED_ON_TAG * 0.01)
	coins = round(coins / 5) * 5 # round to nearest 5
	return coins

func _not_taggable(player):
	return not is_crocodile() or not player is load("res://Player.gd") or frozen or player.on_platform

func _physics_process(delta):
	$DebugLabel.text = "[Debug:%s]\n" % get_name()
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

func _set_coins(value):
	coins = value
	$Sprite/CoinLabel.text = String(value)