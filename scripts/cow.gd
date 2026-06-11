class_name Cow
extends Animal

@export var milk_item: InvItem
@export var milk_interval_hours := 24

var hours_since_milk := 0
var milk_ready := false


func _ready() -> void:
	super._ready()


func _on_hour_passed() -> void:
	hours_since_milk += 1

	if hours_since_milk >= milk_interval_hours:
		hours_since_milk = 0
		milk_ready = true
		print("Cow has milk ready")


func interact(player) -> void:
	if milk_ready:
		player.inventory.add_item(milk_item, 1)
		milk_ready = false
		print("Collected milk")
	else:
		print("Cow has no milk right now")
