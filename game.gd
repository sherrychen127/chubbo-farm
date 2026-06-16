extends Node

@onready var map_root: Node = $Maps
@onready var player: CharacterBody2D = $player
@onready var world_clock: WorldClock = $WorldClock
var loaded_maps := {}

func _ready() -> void:
	print("MAIN READY")

	Global.player = player
	Global.world_clock = world_clock

	Global.inventory = load("res://resources/player_inventory.tres")
	player.inventory = Global.inventory

	change_map("res://scenes/farm.tscn", "SpawnFromHome")


func change_map(scene_path: String, spawn_name: String) -> void:
	print("Changing map to: ", scene_path)
	print("Spawn name: ", spawn_name)

	if Global.current_map != null:
		Global.current_map.queue_free()
		Global.current_map = null

	var packed_scene := load(scene_path) as PackedScene

	if packed_scene == null:
		print("ERROR: Cannot load scene: ", scene_path)
		return

	var new_map := packed_scene.instantiate() as Node2D

	if new_map == null:
		print("ERROR: Scene root is not Node2D")
		return

	new_map.position = Vector2.ZERO
	new_map.scale = Vector2.ONE

	map_root.add_child(new_map)
	Global.current_map = new_map

	print("New map added: ", new_map.name)
	#print("MapRoot position: ", map_root.global_position)
	#print("New map position: ", new_map.global_position)

	var spawn := new_map.get_node_or_null(spawn_name) as Marker2D

	if spawn == null:
		print("ERROR: Missing spawn point: ", spawn_name)
		print("Children in new map:")
		for child in new_map.get_children():
			print("- ", child.name)
		return

	player.global_position = spawn.global_position

	print("Spawn position: ", spawn.global_position)
