class_name Inventory
extends Resource

@export var slots: Array[InventorySlot] = []
signal inventory_changed

func setup(size: int = 12):
	slots.clear()

	for i in size:
		slots.append(InventorySlot.new())

func has_item(item: InvItem, amount: int) -> bool:
	var total: int = 0

	for slot in slots:
		if slot.item == item:
			total += slot.quantity

	return total >= amount

func add_item(new_item: InvItem, amount: int = 1) -> bool:
	# First try stacking
	for slot in slots:
		if slot.item == new_item and slot.quantity < new_item.max_stack:
			var space_left = new_item.max_stack - slot.quantity
			var amount_to_add = min(space_left, amount)

			slot.quantity += amount_to_add
			amount -= amount_to_add
			inventory_changed.emit()
			if amount <= 0:
				return true

	# Then try empty slots
	for slot in slots:
		if slot.is_empty():
			var amount_to_add = min(new_item.max_stack, amount)
			slot.item = new_item
			slot.quantity = amount_to_add
			amount -= amount_to_add
			inventory_changed.emit()

			if amount <= 0:
				return true
				
	return false


func remove_item(item: InvItem, amount: int) -> bool:
	if not has_item(item, amount):
		return false

	var remaining: int = amount

	for slot in slots:
		if slot.item == item:
			var removed: int = min(slot.quantity, remaining)
			slot.quantity -= removed
			remaining -= removed

			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0

			if remaining <= 0:
				inventory_changed.emit()
				return true

	inventory_changed.emit()
	return true
	
func remove_from_slot(index: int, amount: int = 1) -> void:
	if index < 0 or index >= slots.size():
		return

	var slot = slots[index]
	if slot == null or slot.is_empty():
		return

	slot.quantity -= amount

	if slot.quantity <= 0:
		slot.item = null
		slot.quantity = 0
	inventory_changed.emit()
