extends Node

var Platform = preload("res://Platform.gd")
var Player = preload("res://Player.gd")
var Coin = preload("res://Coin.gd")
var Wall = preload("res://Wall.gd")

var Goal = preload("res://ai/goal/Goal.gd")

var ChaseOthers = preload("res://ai/goal/ChaseOthers.gd")
var GoAroundPlatform = preload("res://ai/goal/GoAroundPlatform.gd")

var GetMostCoins = preload("res://ai/goal/GetMostCoins.gd")
var ArriveAtPlatform = preload("res://ai/goal/ArriveAtPlatform.gd")
var GoGetCoin = preload("res://ai/goal/GoGetCoin.gd")
var LeavePlatform = preload("res://ai/goal/LeavePlatform.gd")
var FleeCrocodile = preload("res://ai/goal/FleeCrocodile.gd")