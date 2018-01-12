extends Label

var parent_node
var offset

func setup(parent_node, offset = Vector2(20, 0)):
	self.parent_node = weakref(parent_node)
	self.offset = offset

func add_line(line):
	if _replace_if_similar(line):
		return
	_append_line(line)

func _replace_if_similar(new_line):
	var lines = text.split("\n", true, INF)
	for line in lines:
		if line.similarity(new_line) >= 0.5:
			text = text.replace(line, new_line)
			return true
	return false

func _append_line(new_line):
	new_line = "\n%s" % new_line
	text += new_line

func set_offset(new_offset):
	if new_offset != null:
		offset = new_offset

func set_opaque(opaque):
	$Panel.set_opaque(opaque)

func _physics_process(delta):
	_clear()
	_update_position()

func _clear():
	text = ""

func _update_position():
	var parent = parent_node.get_ref()
	if not parent:
		return
	
	rect_position = parent.position + offset