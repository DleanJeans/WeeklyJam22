extends Node2D

const maps_path = "res://source/maps"

onready var game = Global.Game

var MAX_MAP
var index = -1

var maps = []
var _current_map

func _ready():
	_load_map_scenes()
	_current_map = game.get_node("Map")

func _load_map_scenes():
	var directory = Directory.new()
	directory.open(maps_path)
	directory.list_dir_begin()
	
	while true:
		var file = directory.get_next()
		if _file_is_scene(file):
			_load_file_to_scene(file)
		elif file == "":
			break
	
	directory.list_dir_end()
	MAX_MAP = maps.size()

func _load_file_to_scene(file):
	var map_path = _get_map_path(file)
	var map_scene = load(map_path)
	maps.append(map_scene)

func _file_is_scene(file):
	return file.ends_with(".tscn")

func _get_map_path(file):
	return "%s/%s" % [maps_path, file]

func next_map():
	game.emit_signal("map_preloaded")
	
	game.stop_counting_down()
	
	_disable_ai()
	_free_old_map()
	_add_new_map_to_game()
	_update_map_button()
	_enable_ai()
	
	game.emit_signal("map_loaded")

func _disable_ai():
	Systems.PlayerManager.disable_ai()

func _free_old_map():
	game.get_node("Map").free()

func _add_new_map_to_game():
	_current_map = _instance_next_map()
	game.add_child(_current_map)
	game.move_child(_current_map, 0)

func _instance_next_map():
	_increment_map_index()
	return maps[index].instance()

func _increment_map_index():
	index = wrapi(index + 1, 0, MAX_MAP)

func _update_map_button():
	Screens.MainMenu.update_map_button(_current_map.map_name)

func _enable_ai():
	Systems.PlayerManager.enable_ai()