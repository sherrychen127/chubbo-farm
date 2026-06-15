extends Control
class_name CookingUI

@onready var cook_button: Button=$Panel/VBoxContainer/CookButton
@onready var take_button: Button=$Panel/VBoxContainer/TakeButton
@onready var status_label: Label = $Panel/VBoxContainer/StatusLabel

var player: Node = null
var is_cooking := false
var cooked_item_ready := false


func _ready() -> void:
	visible = false
	cook_button.pressed.connect(cook)
	take_button.pressed.connect(take)

func open() -> void:
	player = get_tree().get_first_node_in_group("player")
	visible = true
	update_ui()

func close() -> void:
	visible = false
	#update_ui()



func update_ui() -> void:
	pass



func cook() -> void:
	status_label.text = "Cooking..."
	cook_button.disabled = true

	await get_tree().create_timer(3.0).timeout

	#status_label.text = "Food is ready!"
	status_label.text = "Output: Fried Egg"
	take_button.visible = true


func take() -> void:
	status_label.text = "Added to inventory!"
	#status_label.text = "Output: Empty"
	take_button.visible = false
	cook_button.disabled = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
