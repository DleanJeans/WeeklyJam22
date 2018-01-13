tool
extends KinematicBody2D

var debug_label_offset = Vector2(40, -100)

var GAMEPAD_DEVICE_MAP = {
	"P3": 0,
	"P4": 1,
	"P5": 2,
	"P6": 3
}

var crocodile setget _set_crocodile, _get_crocodile

export(bool) var pushing_out = false
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
var jump_frozen = false

var coins = 0 setget _set_coins

var _debug_text = ""

signal turning_crocodile
signal turning_normal

signal jump
signal bounce

signal frozen_as_crocodile
signal unfrozen_as_crocodile

signal hit_wall(player, bounce)

func almost_unfrozen():
	var time_left = $FreezeTimer.get_time_left()
	return time_left < 1

func reset():
	turn_normal()
	self.coins = 0
	self.controller = "AI"
	$Sprite.modulate = get_node("/root/Const").WHITE
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
		if b is Classes.Player and b != self:
			players_count += 1
			if players_count == 3:
				return true

	return false

func show_winner_label():
	$WinnerLabel.show()

func hide_winner_label():
	$WinnerLabel.hide()

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

func _finished_playing(name):
	if name == "Jump" or name == "Groan":
		$ButtonHint.pop_up()

func break_unfrozen():
	groan()
	jump()

func collect_coins(amount = 10):
	self.coins += amount

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
	return player == self or not is_crocodile() or not player is Classes.Player or frozen or player.on_platform

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
	_emit_signal_if_hit_wall()

	if frozen: return

	_move_player()

func _emit_signal_if_hit_wall():
	if get_slide_count() > 0:
		var collision = get_slide_collision(0)
		if not collision.collider is Classes.Wall: return

		var normal = collision.normal

		if abs(normal.x) == 1:
			emit_signal("hit_wall", self, Vector2(-1, 1))
		elif abs(normal.y) == 1:
			emit_signal("hit_wall", self, Vector2(1, -1))

func _move_player():
	clamp_velocity()
	velocity *= drag_scale
	move_and_slide(velocity)

	heading = velocity.normalized()

func _ready():
	yield(Utility.timer(0.1), "timeout")
	if Debug.Labels.node_not_added(self):
		Debug.Labels.add_label(self, debug_label_offset)
	else: Debug.Labels.set_offset(self, debug_label_offset)

func _process(delta):
	debug("On Platform: %s" % on_platform)

func debug(info):
	if not Engine.is_editor_hint() and OS.is_debug_build() and Debug.Settings.debug_players:
		Debug.Labels.add_line(self, info)

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
	if is_crocodile():
		if frozen:
			emit_signal("frozen_as_crocodile")
		else: emit_signal("unfrozen_as_crocodile")

func _leave_platform():
	if self.crocodile != null:
		self.crocodile._tag_overlapping_player()

func _tag_overlapping_player():
	var bodies = $TouchArea.get_overlapping_bodies()
	for body in bodies:
		tag_crocodile(body)

func _exit_tree():
	Debug.Labels.remove_label(self)