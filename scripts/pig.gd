class_name Pig
extends Animal

@export var truffle_item: InvItem
@export var truffle_chance := 0.5
@export var truffle_interval_hours := 24

var hours_since_truffle := 0
var truffle_ready := false


func _ready() -> void:
	super._ready()


func _on_hour_passed() -> void:
	hours_since_truffle += 1

	if hours_since_truffle >= truffle_interval_hours:
		hours_since_truffle = 0
		truffle_ready = randf() < truffle_chance


func interact(player) -> void:
	if truffle_ready:
		player.inventory.add_item(truffle_item, 1)
		truffle_ready = false
		print("Collected truffle")
	else:
		print("Pig found nothing")
