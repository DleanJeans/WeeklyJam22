extends Container

onready var game = Global.Game
onready var PlayerManager = Systems.PlayerManager

var label_dict = {}
var players_ready = {}
var players_joined = []

var closed = true

var _current_player
var _current_label

func _ready():
	setup_label_dict()

func setup_label_dict():
	label_dict.clear()
	
	for i in range(0, Global.Players.size()):
		var player = Global.Players[i]
		var label = $Labels.get_child(i)
		
		label_dict[player] = label

func show_if_not_closed():
	if not closed:
		show()

func open():
	closed = false
	show()
	$Hints.show()
	
	players_joined = []
	players_ready = {}
	
	$ControllerManager.reset()
	_hide_labels()
	_add_user_controlled_player()
	_toggle_joypad_hints()
	PlayerManager.connect("player_jump", self, "_on_player_jump")

func _add_user_controlled_player():
	for player in Global.Players:
		if player.is_ai_controlled(): continue
		_current_player = player
		_get_current_label()
		
		players_joined.append(player)
		players_ready[player] = false
		_current_label.show()
		
		_update_current_label()

func _get_current_label():
	_current_label = label_dict[_current_player]

func _toggle_joypad_hints():
	if game.joypad_connected():
		$Hints/ButtonHints/A.show()
		$Hints/ButtonHints/B3.show()
	else:
		$Hints/ButtonHints/A.hide()
		$Hints/ButtonHints/B3.hide()

func close():
	closed = true
	_disconnnect_jump_signals()
	hide()

func _hide_labels():
	for label in $Labels.get_children():
		label.hide()

func _disconnnect_jump_signals():
	for player in players_joined:
		if player.is_connected("jump", self, "_on_player_jump"):
			player.disconnect("jump", self, "_on_player_jump")
	if PlayerManager.is_connected("player_jump", self, "_on_player_jump"):
		PlayerManager.disconnect("player_jump", self, "_on_player_jump")

func _process(delta):
	if not visible: return
	
	_stick_label_to_players()

func _stick_label_to_players():
	for player in players_joined:
		var label = label_dict[player]
		_set_label_position(label, player)

func _set_label_position(label, player):
	label.rect_position = player.position + Vector2(30, -50)

func _on_player_jump(player):
	_current_player = player
	_current_label = label_dict[player]
	
	if players_ready.has(player):
		_toggle_player_ready()
	else:
		_add_player()
	
	if _all_ready():
		game.start_counting_down()
		$Hints.hide()
	else:
		game.stop_counting_down()
		$Hints.show()

func _toggle_player_ready():
	players_ready[_current_player] = not players_ready[_current_player]
	_update_current_label()

func _add_player():
	players_ready[_current_player] = false
	players_joined.append(_current_player)
	
	_current_label.show()
	_update_current_label()

func _update_current_label():
	var player_is_ready = players_ready[_current_player]
	
	if player_is_ready:
		_current_label.text = "Ready!"
		_current_label.modulate = _current_player.color
	else:
		_current_label.text = "Not Ready?"
		_current_label.modulate = Const.WHITE

func _all_ready():
	if players_joined.size() == 0:
		return false
	for player in players_joined:
		if not players_ready[player]:
			return false
	return true