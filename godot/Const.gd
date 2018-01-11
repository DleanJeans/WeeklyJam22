extends Node

const COLLISION_NORMAL = 1 + 16
const COLLISION_BLOCKED = 1 + 2 + 16
const COLLISION_AIRBORNE = 16
const COLLISION_PLATFORM = 4

const JUMP_DURATION = 1

const UP = Vector2(0, -1)
const DOWN = Vector2(0, 1)
const LEFT = Vector2(-1, 0)
const RIGHT = Vector2(1, 0)

const WHITE = Color("#ffffff")
const RED = Color("#ce0707")
const CASHY_GREEN = Color("#0fe408")
const ICY_BLUE = Color("#7fb5e6")

const PLAYERS_GROUP = "Players"
const PLATFORMS_GROUP = "Platforms"