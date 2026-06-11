class_name FarmAnimal
extends CharacterBody2D

enum AnimalState {
	IDLE,
	WANDER,
	SLEEP
}

@export_group("Animal Info")
@export var animal_name := "Animal"
@export var speed := 15.0


@export_group("Production")
@export var product_item: InvItem
@export var product_interval_hours := 24
@export var product_ready := false

@export_group("Movement")
@export var wander_radius := 80.0
@export var min_wait_time := 1.0
@export var max_wait_time := 3.0

var state: AnimalState = AnimalState.IDLE
var direction := Vector2.ZERO
var spawn_position := Vector2.ZERO
var hours_since_product := 0
var last_facing_right := false


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var wander_timer: Timer = $WanderTimer


func _ready() -> void:
	spawn_position = global_position

	wander_timer.timeout.connect(_on_wander_timer_timeout)

	var world_clock = get_tree().get_first_node_in_group("world_clock")
	if world_clock != null:
		world_clock.clock_progress.connect(_on_hour_passed)

	_choose_new_behavior()
	
func _physics_process(delta: float) -> void:
	match state:
		AnimalState.IDLE:
			velocity = Vector2.ZERO
			sprite.flip_h = last_facing_right
			_play_animation("idle")

		AnimalState.WANDER:
			velocity = direction * speed
			_update_walk_animation(direction)
			move_and_slide()

			if global_position.distance_to(spawn_position) > wander_radius:
				direction = global_position.direction_to(spawn_position)

		AnimalState.SLEEP:
			velocity = Vector2.ZERO
			sprite.flip_h = last_facing_right
			_play_animation("sleep")
			
func _update_walk_animation(move_dir: Vector2) -> void:
	if move_dir == Vector2.ZERO:
		sprite.flip_h = last_facing_right
		_play_animation("idle")
		return

	if move_dir.x > 0:
		last_facing_right = true
	elif move_dir.x < 0:
		last_facing_right = false

	sprite.flip_h = last_facing_right

	if abs(move_dir.y) > abs(move_dir.x) and move_dir.y < 0:
		_play_animation("walk_up")
	else:
		_play_animation("walk")
		
func _choose_new_behavior() -> void:
	var roll := randf()

	if roll < 0.6:
		state = AnimalState.IDLE
		direction = Vector2.ZERO
	else:
		state = AnimalState.WANDER
		direction = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized()

	wander_timer.start(randf_range(min_wait_time, max_wait_time))


func _on_wander_timer_timeout() -> void:
	_choose_new_behavior()


func _on_hour_passed(day: int, hour: int) -> void:
	pass
	
#func _on_hour_passed() -> void:
	#hours_since_product += 1
#
	#if hours_since_product >= product_interval_hours:
		#hours_since_product = 0
		#product_ready = true
		#print(animal_name, " product is ready")


func interact(player) -> void:
	if product_ready and product_item != null:
		product_ready = false
		player.inventory.add_item(product_item, 1)
		print("Collected ", product_item.item_name, " from ", animal_name)
	else:
		print(animal_name, " has nothing right now")


func _play_animation(anim_name: String) -> void:
	if sprite.sprite_frames == null:
		return

	if sprite.sprite_frames.has_animation(anim_name):
		if sprite.animation != anim_name:
			sprite.play(anim_name)
