extends Control
var inventory: Inventory

@onready var grid: GridContainer = $GridContainer

func _ready() -> void:
	call_deferred("setup_inventory")

	
func setup_inventory() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		print("ERROR: InventoryUI cannot find player group")
		return

	inventory = player.inventory

	if inventory == null:
		print("ERROR: Player inventory is null")
		return

	if not inventory.inventory_changed.is_connected(refresh):
		inventory.inventory_changed.connect(refresh)

	refresh()	

func refresh() -> void:
	if inventory == null:
		setup_inventory()
		return

	var player = get_tree().get_first_node_in_group("player")

	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]

		if slot == null:
			slot = InventorySlot.new()
			inventory.slots[i] = slot

		var slot_ui = grid.get_child(i) as SlotUI
		slot_ui.slot_index = i
		slot_ui.update_slot(slot)

		if player != null:
			slot_ui.set_selected(i == player.selected_slot_index)
