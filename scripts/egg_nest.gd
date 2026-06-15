class_name Nest
extends StaticBody2D

@export var egg_item: InvItem
@export var max_eggs := 3

var egg_count := 0
@onready var popup := $PopUp
@onready var egg_sprites := [
	$Egg1,
	$Egg2,
	$Egg3
]


func _ready() -> void:
	update_visuals()


func add_egg() -> bool:
	if egg_count >= max_eggs:
		return false

	egg_count += 1
	update_visuals()
	return true


func collect_eggs(player) -> void:
	if egg_count <= 0:
		print("No eggs in nest")
		return
	print("egg_item = ", egg_item)


	player.inventory.add_item(egg_item, egg_count)

	print("Inventory after adding:")
	for slot in player.inventory.slots:
		print("slot item=", slot.item, " qty=", slot.quantity)

	print("Collected ", egg_count, " eggs")
	egg_count = 0
	update_visuals()


func update_visuals() -> void:
	if egg_count > 0:
		popup.visible = true 
	else:
		popup.visible = false
	for i in range(egg_sprites.size()):
		egg_sprites[i].visible = i < egg_count
