tool
extends KinematicBody2D

var GAMEPAD_DEVICE_MAP = {
	"P3": 0,
	"P4": 1,
	"P5": 2,
	"P6": 3
}

const COINS_PERCENT_TRANSFERRED_ON_TAG = 50
const BONUS_COINS_ON_TAG = 10

export(Color) var color = Color("#ffffff") setget _set_color
var max_velocity = 300
var drag_scale = 0.8
var crocodile_speed = 400
var normal_speed = 300
var ai_speed_scale = 0.9

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
	$WinnerLabel.hide()
	frozen = true

func show_winner_label():
	$WinnerLabel.show()

func jump():
	if not $AnimationPlayer.is_playing():
		$AnimationPlayer.play("Jump")
		$JumpSound.play()

func break_unfrozen():
	$Sprite.modulate = get_node("/root/Global").WHITE
	groan()
	jump()

func toggle_frozen():
	frozen = not frozen
	if is_crocodile() and frozen:
		$Sprite.modulate = get_node("/root/Global").ICY_BLUE
		$FreezingSound.play()

func groan():
	if not $GroaningSound.playing:
		$GroaningSound.play()

func collect_coin(amount = 10):
	self.coins += amount
	$CoinChangeLabel.text = "+%s" % amount
	$CoinChangeLabel.modulate = get_node("/root/Global").CASHY_GREEN
	$AnimationPlayer.play("CoinChanged")

func take_away_coin(amount):
	if amount > coins:
		amount = coins
	
	self.coins -= amount
	
	if amount > 0:
		$CoinChangeLabel.text = "%s" % amount
		$CoinChangeLabel.modulate = get_node("/root/Global").RED
		$AnimationPlayer.play("CoinChanged")

func is_controlled_by_ai():
	return controller == "AI"

func move(direction, multiplier = 1):
	velocity += direction.normalized() * max_velocity * multiplier

func moving_vector(direction, multiplier = 1):
	return direction.normalized() * max_velocity * multiplier

func turn_normal():
	emit_signal("turning_normal")
	self.max_velocity = normal_speed
	$TouchArea/Shape.scale = Vector2(1, 1)

func turn_crocodile():
	emit_signal("turning_crocodile")
	get_node("/root/Global").crocodile = self
	self.max_velocity = crocodile_speed
	$TouchArea/Shape.scale = Vector2(2, 2)

func is_crocodile():
	return self == get_node("/root/Global").crocodile

func tag_crocodile(player_area):
	var player = player_area.get_parent()
	if _not_taggable(player):
		return
	
	_transfer_coins(player)
	$TapSound.play()

func _transfer_coins(player):
	var coins_lost = _coins_lost(player)
	var coins_gained = _coins_gained(coins_lost)
	
	player.turn_crocodile()
	player.get_node("FreezeTimer").start()
	player.take_away_coin(coins_lost)
	
	self.turn_normal()
	self.collect_coin(coins_gained)

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
	velocity *= drag_scale
	move_and_slide(velocity)
	
	_flip_crocodile()
	
	heading = velocity.normalized()
	debug("Velocity: %s" % velocity.length())

func debug(info):
	$DebugLabel.text += "%s\n" % info

func clamp_velocity():
	velocity = velocity.clamped(max_velocity)
	if is_controlled_by_ai():
		velocity *= ai_speed_scale

func _flip_crocodile():
	if sign(velocity.x) == sign(heading.x): return
	
	if velocity.x > 0:
		$Sprite/Crocodile.flip_h = true
		$Sprite/Crocodile.position.x = 12
		$Sprite/Crocodile/Shadow.position.x = -10
	else:
		$Sprite/Crocodile.flip_h = false
		$Sprite/Crocodile.position.x = -12
		$Sprite/Crocodile/Shadow.position.x = 10

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

func _set_color(value):
	color = value
	if has_node("Sprite"):
		$Sprite.self_modulate = color
		$Sprite/CoinLabel.self_modulate = color
		$Sprite/NameTag.self_modulate = color
		$WinnerLabel.self_modulate = color