extends Sprite

onready var ReferenceSprite = get_parent()
onready var TheCrown = ReferenceSprite.get_parent()

func pop_out():
	$PopOutAnimation.play(".")

func is_child_to_reference_sprite():
	return get_parent() == ReferenceSprite

func reparent_to_reference_sprite():
	reparent(ReferenceSprite)

func reparent_to_player_sprite(player):
	var sprite = player.get_node("Sprite")
	reparent(sprite)

func reparent(new_parent):
	var old_parent = get_parent()
	old_parent.remove_child(self)
	new_parent.add_child(self)

func _ready():
	Debug.Labels.add_label(self, Vector2(20, 0))

func _process(delta):
	_debug()

func _debug():
	if not Debug.Settings.debug_crown: return
	
	var local_pos = position.floor()
	var global_pos = global_position.floor()
	var parent_name = get_parent().get_name()
	
	Debug.Labels.add_line(self, "Global Pos: %s" % global_pos)
	Debug.Labels.add_line(self, "Scale: %s" % scale)
	Debug.Labels.add_line(self, "Parent: %s" % parent_name)
	
	if get_parent() == TheCrown:
		var the_crown_pos = TheCrown.position
		Debug.Labels.add_line(self, "TheCrown Pos: %s" % the_crown_pos)