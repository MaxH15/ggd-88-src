extends CanvasLayer
class_name UI

func _process(_delta: float) -> void:
	$Debug/Speed.text = "Speed: " + str(PlayerVariables.speed)
	$Debug/SpeedMod.text = "Speed Increase: " + str(PlayerVariables.speed_mod + PlayerVariables.speed_increase + PlayerVariables.speed_boost) + " (" + str(PlayerVariables.speed_increase) + " + " + str(PlayerVariables.speed_mod) + ")"
	$Debug/PlayerState.text = "Player State: " + PlayerVariables.player_state
	$Debug/Inventory.text = "Upgrades: " + PlayerVariables.invString
	$Debug/Damage.text = "Last Damage Taken: " + str(PlayerVariables.damageTaken)
