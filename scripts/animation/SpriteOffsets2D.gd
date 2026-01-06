extends AnimatedSprite2D
class_name SpriteOffsets2D

@export var offsets:Dictionary[String, Vector2]

func _ready() -> void:
	animation_changed.connect(_set_offsets)

func _set_offsets() -> void:
	if offsets.has(animation):
		offset = offsets[animation]
	else:
		offset = Vector2.ZERO
		print("Animation " + animation + " does not have offsets!")
