extends Control

@onready var icon: TextureRect = $TextureRect
@onready var count_label: Label = $Label

func update(slot: InventorySlot):
	if slot == null or slot.is_empty():
		icon.texture = null
		count_label.text = ""
	else:
		icon.texture = slot.item.texture
		count_label.text = str(slot.quantity)
