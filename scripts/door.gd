extends Area2D

@export_file("*.tscn") var target_scene: String
@export var target_spawn_name := "SpawnPoint"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		get_tree().current_scene.change_map(target_scene, target_spawn_name)
