class_name InvItem
extends Resource

enum ItemCategory {
	SEED,
	RESOURCE,
	TOOL,
	INGREDIENT,
	FOOD,
	QUEST
}

@export var name: String
@export var texture: Texture2D
@export var category: ItemCategory
@export var max_stack := 99

# Only for seeds
@export var crop_to_plant: Crop

func is_seed() -> bool:
	return category == ItemCategory.SEED and crop_to_plant != null
