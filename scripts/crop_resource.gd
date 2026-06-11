class_name Crop
extends Resource

@export var name: String
@export var growth_phase: Global.GrowthPhase = Global.GrowthPhase.GERMINATING
@export var texture_resource: MappedTexture

@export var harvest_item: InvItem
@export var harvest_amount: int = 1

@export_group("Germination Phase", "germination_")
@export_range(.5, 4, .5, "suffix:days") var germination_duration := 0.5 

@export_group("Budding Phase", "budding_")
@export_range(.5, 4, .5, "suffix:days") var budding_duration := 0.5 

@export_group("Flowering Phase", "flowering_")
@export_range(.5, 4, .5, "suffix:days") var flowering_duration := 0.5 

@export_group("Maturation Phase", "maturation_")
@export_range(.5, 4, .5, "suffix:days") var maturation_duration := 0.5 


var texture: AtlasTexture:
	get:
		if texture_resource == null:
			return null

		return texture_resource.get_frame(growth_phase)


func is_harvestable() -> bool:
	return growth_phase == Global.GrowthPhase.MATURE


func advance_growth_phase() -> void:
	if growth_phase < Global.GrowthPhase.MATURE:
		growth_phase += 1
