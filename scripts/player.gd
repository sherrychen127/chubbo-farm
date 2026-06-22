extends CharacterBody2D

@export var inventory: Inventory
@export var speed := 120.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var selected_slot_index: int = 0

func _ready() -> void:
	Global.player = self

	if Global.inventory == null:
		Global.inventory = Inventory.new()
		Global.inventory.setup(12)

	inventory = Global.inventory

func add_to_inventory(item: InvItem, amount: int = 1) -> bool:
	var success := inventory.add_item(item, amount)
	return success

func get_selected_slot() -> InventorySlot:
	if inventory == null:
		return null

	if selected_slot_index < 0 or selected_slot_index >= inventory.slots.size():
		return null

	return inventory.slots[selected_slot_index]

func _physics_process(delta):
	var direction := Vector2.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1

	direction = direction.normalized()
	velocity = direction * speed
	move_and_slide()

	play_animation(direction)


func play_animation(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		sprite.play("idle")
		return

	if abs(direction.x) > abs(direction.y):
		sprite.play("walk")

		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false

	else:
		sprite.flip_h = false

		if direction.y < 0:
			sprite.play("walk_up")
		else:
			sprite.play("walk_down")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()

	if event.is_action_pressed("select"):
		_handle_click()

func _handle_click() -> void:
	var slot := get_selected_slot()
	var mouse_pos := get_global_mouse_position()
	var farm_tilemap := _get_farm_tilemap()

	if farm_tilemap == null:
		print("DEBUG: farm_tilemap is null")
		return

	var item: InvItem = null
	if slot != null and not slot.is_empty():
		item = slot.item

	if item != null and item.name == "hoe":
		print("DEBUG: hoe click at ", mouse_pos, " tillable=", farm_tilemap.is_tillable(mouse_pos))
		if farm_tilemap.till(mouse_pos):
			print("Tilled soil")
		return

	if item != null and item.name == "watering_can":
		if farm_tilemap.water(mouse_pos):
			print("Watered soil")
		return

	if item != null and item.is_seed():
		if farm_tilemap.plant_crop(mouse_pos, item.crop_to_plant):
			inventory.remove_from_slot(selected_slot_index, 1)
			get_tree().call_group("inventory_ui", "refresh")
			print("Planted ", item.name)
		return

	var result := farm_tilemap.harvest(mouse_pos)
	if not result.is_empty():
		add_to_inventory(result["item"], result["amount"])
		get_tree().call_group("inventory_ui", "refresh")
		print("Harvested!")

func _get_farm_tilemap() -> FarmTileMap:
	var nodes = get_tree().get_nodes_in_group("farm_tilemap")
	if nodes.size() > 0:
		return nodes[0] as FarmTileMap
	return null

func try_interact() -> void:
	var areas = $InteractionArea.get_overlapping_areas()

	for area in areas:
		var target = area.get_parent()
		
		if target is FruitTree:
			target.collect_fruit(self)
			return

		if target is Nest:
			target.collect_eggs(self)
			return

		if target is Cow:
			target.collect_milk(self)
			return
