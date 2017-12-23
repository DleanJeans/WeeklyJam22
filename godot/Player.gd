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

var crocodile setget _set_crocodile, _get_crocodile

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
var frozen = false setget _set_frozen

var coins = 0 setget _set_coins

var _debug_text = ""

signal turning_crocodile
signal turning_normal
signal jump

func reset():
	turn_normal()
	self.coins = 0
	self.controller = "AI"
	$Sprite.modulate = get_node("/root/Global").WHITE
	$AI/WinGame.clear_subgoals()
	$FreezeTimer.stop()
	$WinnerLabel.hide()
	$ScreamSound.choose_random_sound()

func show_crown():
	if $Sprite/Crown.visible or $CrownAnimation.is_playing(): return
	
	$CrownAnimation.play("PopUp")
	$PopSound.play()

func hide_crown():
	if not $Sprite/Crown.visible or $CrownAnimation.is_playing(): return
	
	$CrownAnimation.play("PopOut")
	$PopSound.play()

func out_of_coins():
	return coins <= 0

func is_panicking():
	if self.crocodile == null: return false
	
	var crocodile_in_panic_radius = $PanicRadius.get_overlapping_bodies().has(self.crocodile)
	var crocodile_not_frozen = not self.crocodile.frozen
	return not on_platform and crocodile_in_panic_radius and crocodile_not_frozen

func is_close_to_at_least_3_others():
	if frozen or not is_crocodile(): return
	
	var bodies = $PanicRadius.get_overlapping_bodies()
	var players_count = 0
	
	for b in bodies:
		if get_node("/root/Global").Players.has(b) and b != self:
			players_count += 1
	
	return players_count >= 3

func show_winner_label():
	$WinnerLabel.show()

func hide_winner_label():
	$WinnerLabel.hide()

func jump():
	if not $JumpAnimation.is_playing():
		emit_signal("jump")

func break_unfrozen():
	$Sprite.modulate = get_node("/root/Global").WHITE
	groan()
	jump()

func toggle_frozen():
	self.frozen = not frozen

func groan():
	if not $GroaningSound.playing:
		$GroaningSound.play()

func collect_coins(amount = 10):
	self.coins += amount
	$CoinChangeLabel.text = "+%s" % amount
	$CoinChangeLabel.modulate = get_node("/root/Global").CASHY_GREEN
	$PointsAnimation.play("CoinChanged")

func take_away_coins(amount):
	if amount > coins:
		amount = coins
	
	self.coins -= amount
	
	if amount > 0:
		$CoinChangeLabel.text = "%s" % amount
		$CoinChangeLabel.modulate = get_node("/root/Global").RED
		$PointsAnimation.play("CoinChanged")

func is_controlled_by_ai():
	return controller == "AI"

func move(direction, multiplier = 1):
	velocity += direction.normalized() * max_velocity * multiplier

func moving_vector(direction, multiplier = 1):
	return direction.normalized() * max_velocity * multiplier

func turn_normal():
	emit_signal("turning_normal")
	self.max_velocity = normal_speed

func turn_crocodile():
	emit_signal("turning_crocodile")
	self.crocodile = self
	self.max_velocity = crocodile_speed

func is_crocodile():
	return self == self.crocodile

func tag_crocodile(player):
	if _not_taggable(player):
		return
	
	_transfer_coins(player)
	$TapSound.play()

func _not_taggable(player):
	return not is_crocodile() or not player is load("res://Player.gd") or frozen or player.on_platform

func start_freezing():
	$FreezeTimer.start()

func _transfer_coins(player):
	var coins_lost = _coins_lost(player)
	var coins_gained = _coins_gained(coins_lost)
	
	player.turn_crocodile()
	player.take_away_coins(coins_lost)
	
	self.turn_normal()
	self.collect_coins(coins_gained)

func _coins_lost(player):
	var coins = ceil(player.coins * 0.5)
	coins = _round_to_nearest_5(coins)
	return coins

func _coins_gained(coins_lost):
	return _round_to_nearest_5(coins_lost / 2) + BONUS_COINS_ON_TAG

func _round_to_nearest_5(value):
	return round(value / 5) * 5

func _physics_process(delta):
	$DebugLabel.text = "[Debug:%s]\n" % get_name()
	
	if frozen: return
	
	clamp_velocity()
	velocity *= drag_scale
	move_and_slide(velocity)
	
	heading = velocity.normalized()
	
	_steer_ai_crocodile_if_blocked()

func _steer_ai_crocodile_if_blocked():
	if get_slide_count() > 0 and is_crocodile() and is_controlled_by_ai():
		var collision = get_slide_collision(0)
		var normal = collision.normal
		var tangent = velocity.tangent()
		var velocity_dot = heading.dot(normal)
		var tangent_dot = tangent.normalized().dot(normal)
		
		if abs(velocity_dot) > 0.25 and abs(velocity_dot) < 0.75 and tangent_dot < 0:
			tangent *= -1
		velocity = tangent
		move_and_slide(velocity)

func debug(info):
	$DebugLabel.text += "%s\n" % info

func clamp_velocity():
	var cap = max_velocity
	if is_controlled_by_ai():
		cap *= ai_speed_scale
	velocity = velocity.clamped(cap)

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
		$Panic.self_modulate = color

func _set_crocodile(value):
	get_node("/root/Global").crocodile = value

func _get_crocodile():
	return get_node("/root/Global").crocodile

func _set_frozen(value):
	frozen = value
	if is_crocodile() and frozen:
		$Sprite.modulate = get_node("/root/Global").ICY_BLUE
		$FreezingSound.play()