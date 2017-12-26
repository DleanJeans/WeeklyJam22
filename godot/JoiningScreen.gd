extends Container

onready var game = get_parent()

var player_label_dict = {}
var players_ready = {}
var players_joined = []

var closed = true

func show_if_not_closed():
	if not closed:
		show()

func open():
	closed = false
	show()
	
	players_joined = []
	players_ready = {}
	
	_hide_labels()
	_move_label_to_players()
	_toggle_joypad_hints()

func _toggle_joypad_hints():
	if game.joypad_connected():
		$Hints/A.show()
		$Hints/B3.show()
	else:
		$Hints/A.hide()
		$Hints/B3.hide()

func close():
	closed = true
	_disconnnect_jump_signals()
	hide()

func _hide_labels():
	for label in $Labels.get_children():
		label.hide()

func _move_label_to_players():
	player_label_dict = {}
	for i in range(0, Global.Players.size()):
		var player = Global.Players[i]
		var label = $Labels.get_child(i)
		player_label_dict[player] = label
		
		_set_label_position(label, player)

func _stick_label_to_players():
	for player in players_joined:
		var label = player_label_dict[player]
		_set_label_position(label, player)

func _set_label_position(label, player):
	label.rect_position = player.position + Vector2(35, -50)

func _disconnnect_jump_signals():
	for player in players_joined:
		if player.is_connected("jump", self, "_on_player_jump"):
			player.disconnect("jump", self, "_on_player_jump")

func _process(delta):
	if not visible: return
	
	if _all_ready():
		game.start_counting_down()
	else: game.stop_counting_down()
	
	_stick_label_to_players()

func _all_ready():
	if players_joined.size() == 0:
		return false
	for player in players_joined:
		if not players_ready[player]:
			return false
	return true

func _on_player_jump(player):
	var label = player_label_dict[player]
	
	if players_ready.has(player):
		players_ready[player] = not players_ready[player]
		_update_label(player)
	else:
		players_ready[player] = false
		players_joined.append(player)
		player.connect("jump", self, "_on_player_jump", [player])
		
		label.show()
		_update_label(player)

func _update_label(player):
	var label = player_label_dict[player]
	if players_ready[player]:
		label.text = "Ready!"
		label.modulate = player.color
	else:
		label.text = "Not Ready?"
		label.modulate = Global.WHITE