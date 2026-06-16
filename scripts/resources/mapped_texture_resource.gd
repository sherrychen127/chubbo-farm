class_name MappedTexture
extends Resource

@export var texture_resource: Texture2D

@export var hframes := 4
@export var vframes := 1

@export var start_frame := 0
@export var frame_count := 4


func get_frame(frame_index: int) -> AtlasTexture:
	frame_index = clamp(frame_index, 0, frame_count - 1)

	var actual_frame = start_frame + frame_index

	var frame_width = texture_resource.get_width() / hframes
	var frame_height = texture_resource.get_height() / vframes

	var x = actual_frame % hframes
	var y = actual_frame / hframes

	var region = Rect2(
		Vector2(x * frame_width, y * frame_height),
		Vector2(frame_width, frame_height)
	)

	var atlas = AtlasTexture.new()
	atlas.atlas = texture_resource
	atlas.region = region

	return atlas
