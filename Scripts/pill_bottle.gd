extends StaticBody3D
class_name PillBottle

@export var pill_heal := 20
@export var prompt_message := "[F] Pick up"
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var mesh: MeshInstance3D = $Pill_Bottle2

func _ready():
	set_pickable(false)

func set_pickable(value: bool):
	visible = value
	mesh.visible = value
	collision.disabled = !value

func interact(player):
	if PlayerData.health >= player.health_max:
		return

	print(player.name, " picked up Pills +", pill_heal)

	if player.has_method("heal"):
		player.heal(pill_heal)

	queue_free()

func get_prompt(player):
	if PlayerData.health >= player.health_max:
		return "Health full"
	return prompt_message
