extends Node2D

@export var cooking_ui: Control

@onready var area: Area2D = $Area2D

var player_nearby := false

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if event.is_action_pressed("interact"):
		if cooking_ui != null:
			cooking_ui.open()
		else:
			print("ERROR: Kitchen cooking_ui is not assigned")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		print("Player near kitchen")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		print("Player left kitchen")
		cooking_ui.close()
