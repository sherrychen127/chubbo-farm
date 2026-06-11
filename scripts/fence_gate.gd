class_name FenceGate
extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var interaction_area: Area2D = $InteractionArea

var is_open := false
var player_nearby := false
var is_animating := false

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	animated_sprite.play("closed")
	collision_shape.disabled = false


func _input(event: InputEvent) -> void:
	if not player_nearby:
		return

	if is_animating:
		return

	if event.is_action_pressed("interact"):
		toggle_gate()


func toggle_gate() -> void:
	if is_open:
		close_gate()
	else:
		open_gate()


func open_gate() -> void:
	is_animating = true
	is_open = true
	collision_shape.disabled = true
	animated_sprite.play("opening")


func close_gate() -> void:
	is_animating = true
	is_open = false
	collision_shape.disabled = false
	animated_sprite.play("closing")


func _on_animation_finished() -> void:
	if animated_sprite.animation == "opening":
		is_animating = false
		animated_sprite.play("open")

	elif animated_sprite.animation == "closing":
		is_animating = false
		animated_sprite.play("closed")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
