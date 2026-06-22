extends Node2D
class_name FruitTree

@export var fruit_item: InvItem
@export var max_fruit := 3
@export var days_per_fruit := 1

@onready var harvest_area: Area2D = $HarvestArea
@onready var fruit1: Sprite2D = $HarvestArea/Fruit1
@onready var fruit2: Sprite2D = $HarvestArea/Fruit2
@onready var fruit3: Sprite2D = $HarvestArea/Fruit3

var fruit_count := 3
var days_since_growth := 0

func _ready() -> void:
	harvest_area.add_to_group("fruit_tree_area")

	var world_clock = get_tree().get_first_node_in_group("world_clock")
	if world_clock != null:
		world_clock.new_day.connect(_on_new_day)

	update_sprite()


func _on_new_day() -> void:
	if fruit_count >= max_fruit:
		return

	days_since_growth += 1

	if days_since_growth >= days_per_fruit:
		fruit_count += 1
		days_since_growth = 0

	update_sprite()


func collect_fruit(player) -> void:
	if fruit_count <= 0:
		print("No fruit yet")
		return

	if fruit_item == null:
		print("No fruit item assigned")
		return

	var amount := fruit_count
	var success :bool = player.add_to_inventory(fruit_item, amount)

	if not success:
		print("Inventory full")
		return

	fruit_count = 0
	days_since_growth = 0
	update_sprite()

	get_tree().call_group("inventory_ui", "refresh")
	print("Collected ", amount, " fruit")


func update_sprite() -> void:
	fruit1.visible = fruit_count >= 1
	fruit2.visible = fruit_count >= 2
	fruit3.visible = fruit_count >= 3
