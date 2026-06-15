extends Node


var inventory: Inventory
var current_map: Node = null
var player: Node = null
var world_clock: WorldClock = null

enum GrowthPhase {
	GERMINATING,
	BUDDING,
	FLOWERING,
	MATURE
}

const RESOURCES = {
	"CURSOR": {
		"DEFAULT": preload("res://assets/cursors/cursor_none.svg"),
		"HARVEST": preload("res://assets/cursors/hand_open.svg")
	}
}

func _ready() -> void:
	inventory = Inventory.new()
	inventory.setup(12)
