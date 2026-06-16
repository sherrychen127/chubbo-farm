class_name FarmTileMap
extends Node2D

@export var tillable_layer: TileMapLayer
@export var soil_layer: TileMapLayer

const SOIL_TERRAIN_SET := 0
const SOIL_TERRAIN_DRY := 0
const SOIL_TERRAIN_WET := 1

var tilled_tiles := {}
var watered_tiles := {}
var crop_sprites := {}

func _ready() -> void:
	add_to_group("farm_tilemap")
	var world_clock = get_tree().get_first_node_in_group("world_clock")
	if world_clock:
		world_clock.clock_progress.connect(_on_hour_passed)

func world_to_cell(world_pos: Vector2) -> Vector2i:
	return soil_layer.local_to_map(soil_layer.to_local(world_pos))

func is_tillable(world_pos: Vector2) -> bool:
	if tillable_layer == null:
		return false
	var cell := tillable_layer.local_to_map(tillable_layer.to_local(world_pos))
	return tillable_layer.get_cell_source_id(cell) != -1

func is_tilled(world_pos: Vector2) -> bool:
	return tilled_tiles.has(world_to_cell(world_pos))

func is_watered(world_pos: Vector2) -> bool:
	return watered_tiles.has(world_to_cell(world_pos))

func till(world_pos: Vector2) -> bool:
	if not is_tillable(world_pos):
		return false

	var cell := world_to_cell(world_pos)
	if tilled_tiles.has(cell):
		return false

	tilled_tiles[cell] = null
	_update_soil_terrain()
	return true

func water(world_pos: Vector2) -> bool:
	var cell := world_to_cell(world_pos)
	if not tilled_tiles.has(cell):
		return false
	if watered_tiles.has(cell):
		return false

	watered_tiles[cell] = true
	_update_soil_terrain()
	return true

func plant_crop(world_pos: Vector2, crop: Crop) -> bool:
	var cell := world_to_cell(world_pos)
	if not tilled_tiles.has(cell):
		return false
	if tilled_tiles[cell] != null:
		return false

	tilled_tiles[cell] = crop.duplicate()
	_update_crop_sprite(cell)
	return true

func harvest(world_pos: Vector2) -> Dictionary:
	var cell := world_to_cell(world_pos)
	if not tilled_tiles.has(cell):
		return {}

	var crop = tilled_tiles[cell]
	if crop == null or not crop.is_harvestable():
		return {}

	var result := {"item": crop.harvest_item, "amount": crop.harvest_amount}
	tilled_tiles[cell] = null
	watered_tiles.erase(cell)
	_remove_crop_sprite(cell)
	_update_soil_terrain()
	return result

func get_crop_at(world_pos: Vector2) -> Crop:
	var cell := world_to_cell(world_pos)
	return tilled_tiles.get(cell)

func _update_soil_terrain() -> void:
	soil_layer.clear()

	var dry_cells: Array[Vector2i] = []
	var wet_cells: Array[Vector2i] = []

	for cell in tilled_tiles.keys():
		if watered_tiles.has(cell):
			wet_cells.append(cell)
		else:
			dry_cells.append(cell)

	if dry_cells.size() > 0:
		soil_layer.set_cells_terrain_connect(dry_cells, SOIL_TERRAIN_SET, SOIL_TERRAIN_DRY)
	if wet_cells.size() > 0:
		soil_layer.set_cells_terrain_connect(wet_cells, SOIL_TERRAIN_SET, SOIL_TERRAIN_WET)

func _update_crop_sprite(cell: Vector2i) -> void:
	var crop = tilled_tiles.get(cell)
	if crop == null:
		_remove_crop_sprite(cell)
		return

	var sprite: Sprite2D
	if crop_sprites.has(cell):
		sprite = crop_sprites[cell]
	else:
		sprite = Sprite2D.new()
		sprite.z_index = 1
		sprite.offset = Vector2(0, -3)
		add_child(sprite)
		crop_sprites[cell] = sprite

	sprite.texture = crop.texture
	sprite.global_position = soil_layer.to_global(soil_layer.map_to_local(cell))
	sprite.visible = crop.texture != null

func _remove_crop_sprite(cell: Vector2i) -> void:
	if crop_sprites.has(cell):
		crop_sprites[cell].queue_free()
		crop_sprites.erase(cell)

func _on_hour_passed(day: int, hour: int) -> void:
	if hour % 12 != 0:
		return

	var grew := false
	for cell in tilled_tiles.keys():
		var crop = tilled_tiles[cell]
		if crop == null:
			continue
		if not watered_tiles.has(cell):
			continue
		crop.advance_growth_phase()
		_update_crop_sprite(cell)
		grew = true

	if grew:
		watered_tiles.clear()
		_update_soil_terrain()
