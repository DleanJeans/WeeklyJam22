extends Node

var Platform = preload("res://source/Platform.gd")
var Player = preload("res://source/Player.gd")
var Coin = preload("res://source/Coin.gd")
var Wall = preload("res://source/Wall.gd")

var Goal = preload("res://source/ai/goal/Goal.gd")

var ChaseOthers = preload("res://source/ai/goal/ChaseOthers.gd")
var GoAroundPlatform = preload("res://source/ai/goal/GoAroundPlatform.gd")

var GetMostCoins = preload("res://source/ai/goal/GetMostCoins.gd")
var ArriveAtPlatform = preload("res://source/ai/goal/ArriveAtPlatform.gd")
var GoGetCoin = preload("res://source/ai/goal/GoGetCoin.gd")
var LeavePlatform = preload("res://source/ai/goal/LeavePlatform.gd")
var FleeCrocodile = preload("res://source/ai/goal/FleeCrocodile.gd")