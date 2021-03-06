extends Node

var Platform = load("res://source/Platform.gd")
var Player = load("res://source/Player.gd")
var Coin = load("res://source/Coin.gd")
var Wall = load("res://source/Wall.gd")

var Goal = load("res://source/ai/goal/Goal.gd")

var ChaseOthers = load("res://source/ai/goal/ChaseOthers.gd")
var GoAroundPlatform = load("res://source/ai/goal/GoAroundPlatform.gd")

var GetMostCoins = load("res://source/ai/goal/GetMostCoins.gd")
var ArriveAtPlatform = load("res://source/ai/goal/ArriveAtPlatform.gd")
var GoGetCoin = load("res://source/ai/goal/GoGetCoin.gd")
var LeavePlatform = load("res://source/ai/goal/LeavePlatform.gd")
var FleeCrocodile = load("res://source/ai/goal/FleeCrocodile.gd")