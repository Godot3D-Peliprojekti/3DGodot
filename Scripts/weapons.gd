extends Interactable
class_name Weapon

@export var weapon_id: String = ""

func interact(player):
	prompt_message = "Press F to pickup"
	if player.has_method("weapon_pickup"):
		player.weapon_pickup(weapon_id)
		
	queue_free()
	
