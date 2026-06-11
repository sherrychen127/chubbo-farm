class_name Chicken
extends FarmAnimal

@export var nest: Nest
@export var egg_interval_hours := 24

var hours_since_egg := 0


func _ready() -> void:
	super._ready()


func _on_hour_passed(day: int, hour: int) -> void:
	hours_since_egg += 1

	if hours_since_egg >= egg_interval_hours:
		hours_since_egg = 0
		lay_egg()


func lay_egg() -> void:
	if nest == null:
		print("Chicken has no nest")
		return

	if nest.add_egg():
		print("Chicken laid an egg")
	else:
		print("Nest is full")
