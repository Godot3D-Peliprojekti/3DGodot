extends StaticBody3D
class_name Key

@export var pickable := true
@export var prompt_message := "Press F to pick up"

func interact(body):
	if pickable:
		print(body.name, " picked up the key: ", name)
		queue_free()  # Poistaa avaimen maailmasta
