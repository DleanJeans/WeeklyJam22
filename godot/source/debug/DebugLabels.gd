extends Control

export(bool) var default_opaque = false

var DebugLabel = load("res://source/debug/DebugLabel.tscn")

var _label_dictionary = {}

func remove_label(node):
	var label = _get_label(node)
	label.queue_free()
	_remove_from_dictionary(node)

func _remove_from_dictionary(node):
	_label_dictionary.erase(node)

func add_label(node, label_offset = Vector2(0, 0)):
	var label = DebugLabel.instance()
	label.setup(node, label_offset)
	label.set_opaque(default_opaque)
	add_child(label)
	_add_to_dictionary(node, label)

func set_offset(node, new_offset):
	var label = _get_label(node)
	label.set_offset(new_offset)

func _add_to_dictionary(node, label):
	_label_dictionary[node] = label

func add_line(node, text, label_offset = null):
	if node_not_added(node):
		add_label(node)
	
	var label = _get_label(node)
	label.add_line(text)
	
	if label_offset != null:
		label.set_offset(label_offset)

func node_not_added(node):
	return not _label_dictionary.has(node)

func _get_label(node):
	return _label_dictionary[node]

func _ready():
	Debug.Labels = self