extends Node

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
