extends Area2D
class_name Obstacle

@export var speed_impact:float = 40.0

func _ready() -> void:
	body_entered.connect(check_for_player)

func get_speed_impact() -> float:
	return speed_impact

func check_for_player(body:Node2D) -> void:
	if body is Player:
		body.damage(speed_impact)
		queue_free()

func get_damaged() -> void:
	queue_free()
