extends Node

var ControllerAssigner setget , get_ControllerAssigner
var PlayerManager setget , get_PlayerManager
var MapSelector setget , get_MapSelector
var CoinManager setget , get_CoinManager
var PlatformManager setget , get_PlatformManager

func get_ControllerAssigner():
	return $"/root/Game/Systems/ControllerAssigner"

func get_PlayerManager():
	return $"/root/Game/Systems/PlayerManager"

func get_MapSelector():
	return $"/root/Game/Systems/MapSelector"

func get_CoinManager():
	return $"/root/Game/Systems/CoinManager"

func get_PlatformManager():
	return $"/root/Game/Systems/PlatformManager"