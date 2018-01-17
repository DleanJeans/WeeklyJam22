extends Control

func reset():
	$Script.free_hints()

func on_player_go_rawr(player):
	$Script.set_current_player(player)
	
	$Script.pop_hint_if_has_one()

func on_player_jump(player):
	$Script.set_current_player(player)
	
	if $Script.player_is_ai_controlled():
		return
	elif not $Script.player_already_has_hint():
		$Script.create_hint_for_player()
		
	$Script.pop_hint_if_has_one()
	
	print("Player: %s" % $Script.current_player.get_name())

func on_player_controller_changed(player):
	$Script.set_current_player(player)
	
	if not $Script.player_already_has_hint(): return
	
	if $Script.player_is_ai_controlled():
		$Script.free_hint()
	else: $Script.set_hint_button()