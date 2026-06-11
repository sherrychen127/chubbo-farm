class_name Plot
extends StaticBody2D

@export var soil_sprite: Sprite2D
@export var crop_sprite: Sprite2D

@export var crop: Crop
@export var dry_texture: Texture2D
@export var wet_texture: Texture2D

var is_watered := false

func _ready() -> void:
	input_pickable = true

	if soil_sprite == null:
		soil_sprite = $SoilSprite

	if crop_sprite == null:
		crop_sprite = $CropSprite

	var world_clock = get_tree().get_first_node_in_group("world_clock")

	if world_clock == null:
		print("ERROR: Plot cannot find WorldClock")
		return

	world_clock.clock_progress.connect(handle_hourly_growth)

	update_sprite()

	Input.set_custom_mouse_cursor(
		Global.RESOURCES.CURSOR.DEFAULT,
		Input.CURSOR_ARROW
	)

	Input.set_custom_mouse_cursor(
		Global.RESOURCES.CURSOR.HARVEST,
		Input.CURSOR_POINTING_HAND
	)


func update_sprite() -> void:
	if soil_sprite != null:
		soil_sprite.texture = wet_texture if is_watered else dry_texture

	if crop_sprite == null:
		return

	if crop == null:
		crop_sprite.texture = null
		crop_sprite.visible = false
		return

	crop_sprite.texture = crop.texture
	crop_sprite.visible = true


func plant_crop(new_crop: Crop) -> bool:
	if new_crop == null:
		print("ERROR: new_crop is null")
		return false

	if crop != null:
		print("Plot already has crop")
		return false

	crop = new_crop.duplicate()
	is_watered = false
	update_sprite()

	print("Planted crop: ", crop.name)
	return true

func handle_hourly_growth(day, hour) -> void:
	if crop == null:
		return

	if hour % 12 != 0:
		return

	if !is_watered:
		print("Crop needs water before it can grow")
		return

	crop.advance_growth_phase()
	is_watered = false
	update_sprite()


func water() -> void:
	if crop == null:
		print("No crop to water")
		return

	if is_watered:
		print("Already watered")
		return

	is_watered = true
	update_sprite()
	print("Watered plot")


func _mouse_shape_enter(shape_idx: int) -> void:
	if crop != null and crop.is_harvestable():
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _mouse_shape_exit(shape_idx: int) -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if not event.is_action_pressed("select"):
		return

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("ERROR: player group not found")
		return

	if crop == null:
		player.use_selected_item_on_plot(self)
		return

	var selected_slot = player.get_selected_slot()
	var selected_item = null

	if selected_slot != null:
		selected_item = selected_slot.item

	if selected_item != null and selected_item.name == "watering_can":
		water()
		return

	if crop.is_harvestable():
		print("Harvest!")

		player.add_to_inventory(crop.harvest_item, crop.harvest_amount)
		get_tree().call_group("inventory_ui", "refresh")

		Input.set_default_cursor_shape(Input.CURSOR_ARROW)

		crop = null
		is_watered = false
		update_sprite()
		return

	print("Crop is not ready yet")
