class_name InventorySlot
extends Resource

@export var item: InvItem
@export var quantity: int = 0

func is_empty() -> bool:
	return item == null or quantity <= 0


func clear() -> void:
	item = null
	quantity = 0
