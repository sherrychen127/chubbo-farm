class_name Cow
extends FarmAnimal

#@export var nest: Nest
@export var milk_interval_hours := 24
@onready var popup := $PopUp
@export var milk_item: InvItem
@export var max_milk := 1

var hours_since_milk := 0
var milk_ready = false

func _ready() -> void:
	popup.visible = false
	super._ready()


func _on_hour_passed(day: int, hour: int) -> void:
	hours_since_milk += 1

	if hours_since_milk >= milk_interval_hours:
		hours_since_milk = 0
		produce_milk()


func produce_milk() -> void:
	if milk_ready:
		return
	popup.visible = true
	milk_ready = true

func collect_milk(player) -> void:
	if not milk_ready:
		print("No milk produced!")
		return

	player.inventory.add_item(milk_item, 1)

	print("Collected 1 milk")
	milk_ready = false
	popup.visible = false
