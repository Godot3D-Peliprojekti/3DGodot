extends StaticBody3D
class_name HealthKit

@export var firstaid_heal := 50
@export var prompt_message := "[F] Pick up"
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $FirstAidKit_001

func _ready():
	set_pickable(false)

func set_pickable(value: bool):
	visible = value
	mesh.visible = value
	collision.disabled = !value

func interact(player):
	if PlayerData.health >= player.health_max:
		return # ei voi poimia jos HP täynnä

	PlayerData.health += firstaid_heal
	if PlayerData.health > player.health_max:
		PlayerData.health = player.health_max

	print(player.name, " picked up Health +", firstaid_heal)

	if player.has_method("update_health_label"):
		player.update_health_label()

	queue_free()

func get_prompt(player):
	if PlayerData.health >= player.health_max:
		return "Health full"
	return prompt_message
