extends StaticBody3D
class_name Key

@export var key_id: int = 1  # 1 = first key, 2 = second key
@export var prompt_message := "Press F to pick up"
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready():
	set_pickable(false)  # hide initially

func set_pickable(value: bool):
	visible = value
	if collision:
		collision.disabled = !value

func interact(body):
	if collision and not collision.disabled:
		if body is Player:
			match key_id:
				1:
					body.has_key_1 = true
				2:
					body.has_key_2 = true
			print(body.name, " picked up Key ", key_id, ": ", name)
			queue_free()
