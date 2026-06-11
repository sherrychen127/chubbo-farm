extends CharacterBody2D

@export var inventory: Inventory
@export var speed := 200.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var selected_slot_index: int = 0
var target_position: Vector2
var has_move_target := false

var target_plot: Plot = null
var interaction_distance := 24.0

func _ready() -> void:
	if inventory == null:
		inventory = Inventory.new()
	if inventory.slots.is_empty():
		inventory.setup(12)


func add_to_inventory(item: InvItem, amount: int = 1) -> bool:
	print("Adding to player inventory: ", item.name, " x", amount)
	var success := inventory.add_item(item, amount)
	return success

func get_selected_slot() -> InventorySlot:
	if inventory == null:
		return null

	if selected_slot_index < 0 or selected_slot_index >= inventory.slots.size():
		return null

	return inventory.slots[selected_slot_index]


func use_selected_item_on_plot(plot: Plot) -> void:
	var slot := get_selected_slot()

	if slot == null or slot.is_empty():
		print("No selected item")
		return

	var item := slot.item

	if item.is_seed():
		print("selected:", item.name)
		var success := plot.plant_crop(item.crop_to_plant)

		if success:
			inventory.remove_from_slot(selected_slot_index, 1)
			get_tree().call_group("inventory_ui", "refresh")
	else:
		print(item.name, " cannot be planted")
	
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

func try_interact() -> void:
	var areas = $InteractionArea.get_overlapping_areas()

	for area in areas:
		var target = area.get_parent()

		if target is Nest:
			target.collect_eggs(self)
			return
