extends Control

var MainMenu setget , get_MainMenu
var Pause setget , get_Pause
var Join setget , get_Join

func get_MainMenu():
	return $"/root/Game/Screens/MainMenu"

func get_Pause():
	return $"/root/Game/Screens/Pause"

func get_Join():
	return $"/root/Game/Screens/Join"