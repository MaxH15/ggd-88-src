extends Camera2D

@export var camera_distance_x:float = 400.0
const MIN_ZOOM:float = 0.75
const MAX_ZOOM:float = 1.25
const MIN_SPEED:float = 200.0
const MAX_SPEED:float = 1500.0
const ZOOM_SPEED:float = 3.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position.x = PlayerVariables.player_pos.x + camera_distance_x
