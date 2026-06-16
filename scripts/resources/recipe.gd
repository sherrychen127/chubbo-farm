class_name Recipe
extends Resource

@export var recipe_name: String
@export var ingredients: Array[InventorySlot] = []

@export var result_item: InvItem
@export var result_quantity: int = 1
