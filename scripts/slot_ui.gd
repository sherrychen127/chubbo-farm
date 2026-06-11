class_name SlotUI
extends Panel

@export var slot_index: int = 0

@onready var item_icon: TextureRect = $ItemIcon
@onready var quantity_label: Label = $QuantityLabel

var slot: InventorySlot


func update_slot(new_slot: InventorySlot):
	slot = new_slot

	if slot == null or slot.is_empty():
		item_icon.visible = false
		quantity_label.text = ""
		return

	item_icon.visible = true
	item_icon.texture = slot.item.texture

	if slot.quantity > 1:
		quantity_label.text = str(slot.quantity)
	else:
		quantity_label.text = ""


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var player = get_tree().get_first_node_in_group("player")

			if player == null:
				print("ERROR: player not found")
				return

			player.selected_slot_index = slot_index
			print("Selected slot: ", slot_index)

			get_tree().call_group("inventory_ui", "refresh")


func set_selected(is_selected: bool) -> void:
	if is_selected:
		modulate = Color(1.3, 1.3, 1.3)
	else:
		modulate = Color(1, 1, 1)
