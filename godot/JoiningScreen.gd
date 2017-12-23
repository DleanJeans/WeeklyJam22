extends Container

onready var game = get_parent()

var player_label_dict = {}
var players_ready = {}
var players_joined = []

func open():
	players_joined = []
	players_ready = {}
	show()
	hide_labels()
	_move_label_to_players()

func hide_labels():
	for label in $Labels.get_children():
		label.hide()
	for player in players_joined:
		player.disconnect("jump", self, "_on_player_jump")

func _process(delta):
	if not visible: return
	
	if _all_ready():
		game.start_counting_down()
	else: game.stop_counting_down()

func _all_ready():
	if players_joined.size() == 0:
		return false
	for player in players_joined:
		if not players_ready[player]:
			return false
	return true

func _move_label_to_players():
	player_label_dict = {}
	for i in range(0, Global.Players.size()):
		var player = Global.Players[i]
		var label = $Labels.get_child(i)
		player_label_dict[player] = label
		
		label.rect_position = player.position + Vector2(35, -50)

func _on_player_jump(player):
	var label = player_label_dict[player]
	
	if players_ready.has(player):
		players_ready[player] = not players_ready[player]
		
		if players_ready[player]:
			label.text = "Ready!"
			label.modulate = player.color
		else:
			label.text = "Not Ready?"
			label.modulate = Global.WHITE
	else:
		label.show()
		players_ready[player] = false
		players_joined.append(player)
		player.connect("jump", self, "_on_player_jump", [player])
