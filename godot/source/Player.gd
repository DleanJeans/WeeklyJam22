tool
extends KinematicBody2D

var GAMEPAD_DEVICE_MAP = {
	"P3": 0,
	"P4": 1,
	"P5": 2,
	"P6": 3
}

export(bool) var pushing_out = false
export(bool) var just_landed = false
export(Color) var color = Color("#ffffff") setget _set_color

var max_velocity = 300
var drag_scale = 0.8
var crocodile_speed = 400
var normal_speed = 300
var ai_speed_scale = 0.975

onready var platform_offset = $Sprite.texture.get_height() * $Sprite.scale.y

var controller = "AI" setget _set_controller
var on_platform = false

var velocity = Vector2()
var heading = Vector2()
var frozen = false setget _set_frozen
var jump_frozen = false

var coins = 0 setget _set_coins

var _debug_text = ""

signal turning_crocodile
signal turning_normal

signal jump
signal bounce

signal frozen_as_crocodile
signal unfrozen_as_crocodile

signal got_coins

func almost_unfrozen():
	return $FreezeTimer.time_left < 1

func reset():
	turn_normal()
	self.coins = 0
	self.controller = "AI"
	$Sprite.modulate = $Util.WHITE
	$AI/WinGame.clear_subgoals()
	$FreezeTimer.stop()
	$ScreamSound.choose_random_sound()

func enable_ai():
	$AI.enable()

func disable_ai():
	$AI.disable()

func hide_button_hint():
	$ButtonHint.hide()

func out_of_coins():
	return coins <= 0

func is_panicking():
	if $Util.crocodile == null: return false

	var crocodile_in_panic_radius = $PanicRadius.get_overlapping_bodies().has($Util.crocodile)
	var crocodile_not_frozen = not $Util.crocodile.frozen

	return not on_platform and crocodile_in_panic_radius and crocodile_not_frozen

func is_close_to_at_least_3_others():
	return $Util.is_close_to_at_least_3_others()

func bounce():
	var jump_animation_not_player = _jump_animation_not_playing()
	var current_animation_is_not_bounce = $JumpAnimation.get_current_animation() != "Bounce"
	
	if jump_animation_not_player or current_animation_is_not_bounce:
		$JumpAnimation.play("Bounce")

func _jump_animation_not_playing():
	return not $JumpAnimation.is_playing()

func play_jump_gui():
	$JumpSound.play()
	$ButtonHint.pop_out()

func jump():
	if not (frozen or jump_frozen):
		force_jump()

func force_jump():
	if _jump_animation_not_playing():
		emit_signal("jump")

func groan():
	if not $GroaningSound.playing:
		$GroaningSound.play()
		$ButtonHint.pop_out()
		$Sprite/Crocodile.rawr()

func _finished_playing(_name):
	if _name == "Jump" or _name == "Groan":
		$ButtonHint.pop_up()

func break_unfrozen():
	groan()
	jump()

func collect_coins(amount = 10):
	self.coins += amount
	emit_signal("got_coins")

func take_away_coins(amount):
	if amount > coins:
		amount = coins

	self.coins -= amount

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
	$Util.crocodile = self
	self.max_velocity = crocodile_speed

func is_crocodile():
	return self == $Util.crocodile

func tag_crocodile(player):
	if $Util.not_taggable(player):
		return

	turn_normal()
	player.turn_crocodile()
	_transfer_coins(player)
	$TapSound.play()

func start_freezing():
	$FreezeTimer.start()

func _transfer_coins(player):
	var coins_lost = _coins_lost(player)
	var coins_gained = _coins_gained(coins_lost)

	player.take_away_coins(coins_lost)
	self.collect_coins(coins_gained)

func _coins_lost(player):
	var coins = player.coins - self.coins
	return coins

func _coins_gained(coins_lost):
	return coins_lost

func _physics_process(delta):
	if frozen: return

	_move_player()

func _move_player():
	clamp_velocity()
	velocity *= drag_scale
	move_and_slide(velocity)

	heading = velocity.normalized()

func _ready():
	$Util.setup_debug()

func _process(delta):
	debug("On Platform: %s" % on_platform)

func debug(text):
	if not Engine.editor_hint:
		$Util.debug(text)

func clamp_velocity():
	var cap = max_velocity
	if is_controlled_by_ai():
		cap *= ai_speed_scale
	velocity = velocity.clamped(cap)

func set_name_tag(_name):
	$Sprite/NameTag.text = _name

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
		$Sprite/Panic.self_modulate = color

func _set_frozen(value):
	frozen = value
	if is_crocodile():
		if frozen:
			emit_signal("frozen_as_crocodile")
		else: emit_signal("unfrozen_as_crocodile")

func _leave_platform():
	if $Util.crocodile != null:
		$Util.crocodile._tag_overlapping_player()

func _tag_overlapping_player():
	var bodies = $TouchArea.get_overlapping_bodies()
	for body in bodies:
		tag_crocodile(body)