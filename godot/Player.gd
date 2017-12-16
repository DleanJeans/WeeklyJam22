extends KinematicBody2D

const COINS_PERCENT_TRANSFERRED_ON_TAG = 50
const BONUS_COINS_ON_TAG = 10

export(Color) var color = Color("#ffffff")
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

func _ready():
	$Sprite.self_modulate = color
	$Sprite/CoinLabel.self_modulate = color
	$Sprite/NameTag.self_modulate = color

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
	$CoinChangeLabel.text = "+%s" % amount
	$CoinChangeLabel.modulate = Global.GREEN
	$AnimationPlayer.play("CoinChanged")

func take_away_coin(amount):
	if amount > coins:
		amount = coins
	
	self.coins -= amount
	
	if amount > 0:
		$CoinChangeLabel.text = "%s" % amount
		$CoinChangeLabel.modulate = Global.RED
		$AnimationPlayer.play("CoinChanged")

func move(direction, multiplier = 1):
	velocity += direction.normalized() * max_velocity * multiplier

func moving_vector(direction, multiplier = 1):
	return direction.normalized() * max_velocity * multiplier

func turn_normal():
	emit_signal("turning_normal")
	$Sprite/Crocodile.hide()

func turn_crocodile():
	emit_signal("turning_crocodile")
	Global.crocodile = self
	$Sprite/Crocodile.show()

func is_crocodile():
	return self == Global.crocodile

func tag_crocodile(player_area):
	var player = player_area.get_parent()
	if _not_taggable(player):
		return
	
	var coins_lost = _coins_lost(player)
	var coins_gained = _coins_gained(coins_lost)
	
	player.turn_crocodile()
	player.get_node("FreezeTimer").start()
	player.take_away_coin(coins_lost)
	
	self.turn_normal()
	self.collect_coin(coins_gained)
	
	$TapSound.play()

func _coins_lost(player):
	var coins = ceil(player.coins * 0.5)
	coins = _round_to_nearest_5(coins)
	return coins

func _coins_gained(coins_lost):
	return _round_to_nearest_5(coins_lost / 2) + BONUS_COINS_ON_TAG

func _round_to_nearest_5(value):
	return round(value / 5) * 5

func _not_taggable(player):
	return not is_crocodile() or not player is load("res://Player.gd") or frozen or player.on_platform

func _physics_process(delta):
	$DebugLabel.text = "[Debug:%s]\n" % get_name()
	debug("On Platform: %s" % on_platform)
	
	if frozen: return
	
	clamp_velocity()
	move_and_slide(velocity)
	velocity *= drag_scale
	
	if sign(velocity.x) != sign(heading.x):
		if velocity.x > 0:
			$Sprite/Crocodile.flip_h = true
			$Sprite/Crocodile.position.x = 12
		else:
			$Sprite/Crocodile.flip_h = false
			$Sprite/Crocodile.position.x = -12
	
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