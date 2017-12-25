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

export(bool) var just_landed = false
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
signal frozen_as_crocodile
signal hit_wall(player, bounce)

func reset():
	turn_normal()
	self.coins = 0
	self.controller = "AI"
	$Sprite.modulate = get_node("/root/Global").WHITE
	$AI/WinGame.clear_subgoals()
	$FreezeTimer.stop()
	$WinnerLabel.hide()
	$ScreamSound.choose_random_sound()

func enable_ai():
	$AI.enable()

func disable_ai():
	$AI.disable()

func hide_button_hint():
	$ButtonHint.hide()

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
	if not frozen:
		force_jump()

func force_jump():
	if not $JumpAnimation.is_playing():
		emit_signal("jump")

func groan():
	if not $GroaningSound.playing:
		$GroaningSound.play()
		$ButtonHint.pop_out()

func _finished_playing(name):
	if name == "Jump" or name == "Groan":
		$ButtonHint.pop_up()

func break_unfrozen():
	$Sprite.modulate = get_node("/root/Global").WHITE
	groan()
	jump()

func toggle_frozen():
	self.frozen = not frozen

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
	
	turn_normal()
	player.turn_crocodile()
	_transfer_coins(player)
	$TapSound.play()

func _not_taggable(player):
	return player == self or not is_crocodile() or not player is load("res://Player.gd") or frozen or player.on_platform

func start_freezing():
	$FreezeTimer.start()

func _transfer_coins(player):
	var coins_lost = _coins_lost(player)
	var coins_gained = _coins_gained(coins_lost)
	
	player.take_away_coins(coins_lost)
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
	
	_emit_signal_if_hit_wall()
	
	if frozen: return
	
	_move_player()
	_steer_ai_if_blocked()

func _move_player():
	clamp_velocity()
	velocity *= drag_scale
	move_and_slide(velocity)
	
	heading = velocity.normalized()

func _emit_signal_if_hit_wall():
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if not collision.collider is load("res://Wall.gd"): return
		
		var normal = collision.normal
		
		if abs(normal.x) == 1:
			emit_signal("hit_wall", self, Vector2(-1, 1))
		elif abs(normal.y) == 1:
			emit_signal("hit_wall", self, Vector2(1, -1))

func _steer_ai_if_blocked():
	if get_slide_count() > 0 and is_controlled_by_ai():
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
	
	_toggle_button_hint_visible()
	_choose_button_hint()

func _toggle_button_hint_visible():
	if controller == "AI":
		$ButtonHint.hide()
	else: $ButtonHint.show()

func _choose_button_hint():
	match controller:
		"P1": $ButtonHint.button = "Space"
		"P2": $ButtonHint.button = "Enter"
		"P3", "P4", "P5", "P6": $ButtonHint.button = _get_gamepad_bottom_button_name()

func _get_gamepad_bottom_button_name():
	var device_id = int(controller.substr(1, 1)) - 3 # P3 -> 0 and so on
	var device_name = Input.get_joy_name(device_id)
	if device_name.find("USB") > -1:
		return "3"
	else: return "A"

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
		$Sprite/Panic.self_modulate = color

func _set_crocodile(value):
	get_node("/root/Global").crocodile = value

func _get_crocodile():
	return get_node("/root/Global").crocodile

func _set_frozen(value):
	frozen = value
	if is_crocodile() and frozen:
		emit_signal("frozen_as_crocodile")
		$Sprite.modulate = get_node("/root/Global").ICY_BLUE
		$FreezingSound.play()