extends Control
class_name CookingUI

#@export var egg_item: InvItem
#@export var fried_egg_item: InvItem

@export var recipes: Array[Recipe] = []

@onready var recipe_list: VBoxContainer = $Panel/MarginContainer/VBoxContainer/HBoxContainer/RecipeList
@onready var selected_recipe_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DetailPanel/VBoxContainer/SelectedRecipeLabel
@onready var ingredient_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DetailPanel/VBoxContainer/IngredientLabel
#@onready var result_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DetailPanel/VBoxContainer/ResultLabel
@onready var cook_button: Button = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DetailPanel/VBoxContainer/CookButton
@onready var status_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/DetailPanel/VBoxContainer/StatusLabel

var player: Node = null
var selected_recipe: Recipe = null



func _ready() -> void:
	visible = false
	cook_button.pressed.connect(cook)
	build_recipe_buttons()
	update_ui()


func open() -> void:
	player = get_tree().get_first_node_in_group("player")
	visible = true
	update_ui()

func close() -> void:
	visible = false
	#update_ui()

		
func build_recipe_buttons() -> void:
	for child in recipe_list.get_children():
		child.queue_free()

	for recipe in recipes:
		var button := Button.new()
		button.custom_minimum_size = Vector2(120, 24)

		button.pressed.connect(
			func(): select_recipe(recipe)
		)

		var row := HBoxContainer.new()
		row.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var icon := TextureRect.new()
		icon.texture = recipe.result_item.texture
		icon.custom_minimum_size = Vector2(16, 16)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var label := Label.new()
		label.text = recipe.recipe_name
		label.add_theme_font_size_override("font_size", 8)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE

		row.add_child(icon)
		row.add_child(label)

		button.add_child(row)
		recipe_list.add_child(button)
		
func select_recipe(recipe: Recipe) -> void:
	selected_recipe = recipe
	update_ui()

func update_ui() -> void:
	if selected_recipe == null:
		selected_recipe_label.text = "Select a recipe"
		ingredient_label.text = "Needs:"
		#result_label.text = "Makes:"
		#cook_button.disabled = true
		cook_button.visible = false
		return

	selected_recipe_label.text = selected_recipe.recipe_name

	var ingredient_text := "Needs:\n"

	for ingredient in selected_recipe.ingredients:
		ingredient_text += "- %s x%d\n" % [
			ingredient.item.name,
			ingredient.quantity
		]

	ingredient_label.text = ingredient_text

	#result_label.text = "Makes: %s x%d" % [
		#selected_recipe.result_item.name,
		#selected_recipe.result_quantity
	#]

	#cook_button.disabled = false
	cook_button.visible = true


func cook() -> void:
	if selected_recipe == null:
		status_label.text = "Select a recipe first."
		return

	if player == null:
		player = get_tree().get_first_node_in_group("player")

	if player == null or player.inventory == null:
		status_label.text = "No inventory found."
		return

	if not can_cook(selected_recipe):
		status_label.text = "Missing ingredients."
		return

	remove_ingredients(selected_recipe)

	var added: bool = player.inventory.add_item(
		selected_recipe.result_item,
		selected_recipe.result_quantity
	)

	if not added:
		refund_ingredients(selected_recipe)
		status_label.text = "Inventory full."
		return

	status_label.text = "Cooked " + selected_recipe.recipe_name + "!"



func can_cook(recipe: Recipe) -> bool:
	for ingredient in recipe.ingredients:
		if not player.inventory.has_item(ingredient.item, ingredient.quantity):
			return false

	return true


func remove_ingredients(recipe: Recipe) -> void:
	for ingredient in recipe.ingredients:
		player.inventory.remove_item(ingredient.item, ingredient.quantity)


func refund_ingredients(recipe: Recipe) -> void:
	for ingredient in recipe.ingredients:
		player.inventory.add_item(ingredient.item, ingredient.quantity)
