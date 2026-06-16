extends Node

@onready var map_root: Node = $Maps
@onready var player: CharacterBody2D = $player
@onready var world_clock: WorldClock = $WorldClock
var cached_maps := {}

func _ready() -> void:
	print("MAIN READY")

	Global.player = player
	Global.world_clock = world_clock

	Global.inventory = load("res://resources/player_inventory.tres")
	player.inventory = Global.inventory

	change_map("res://scenes/farm.tscn", "SpawnFromHome")


var is_transitioning := false

func change_map(scene_path: String, spawn_name: String) -> void:
	if is_transitioning:
		return
	is_transitioning = true

	var resolved_path := scene_path
	if scene_path.begins_with("uid://"):
		resolved_path = ResourceUID.get_id_path(ResourceUID.text_to_id(scene_path))

	print("Changing map to: ", resolved_path)
	print("Spawn name: ", spawn_name)

	if Global.current_map != null:
		map_root.remove_child(Global.current_map)
		Global.current_map = null

	var new_map: Node2D

	if cached_maps.has(resolved_path):
		new_map = cached_maps[resolved_path]
	else:
		var packed_scene := load(resolved_path) as PackedScene

		if packed_scene == null:
			print("ERROR: Cannot load scene: ", resolved_path)
			is_transitioning = false
			return

		new_map = packed_scene.instantiate() as Node2D

		if new_map == null:
			print("ERROR: Scene root is not Node2D")
			is_transitioning = false
			return

		new_map.position = Vector2.ZERO
		new_map.scale = Vector2.ONE
		cached_maps[resolved_path] = new_map

	map_root.add_child(new_map)
	Global.current_map = new_map

	var spawn := new_map.get_node_or_null(spawn_name) as Marker2D

	if spawn == null:
		print("ERROR: Missing spawn point: ", spawn_name)
		is_transitioning = false
		return

	player.global_position = spawn.global_position

	get_tree().create_timer(0.1).timeout.connect(func(): is_transitioning = false)
