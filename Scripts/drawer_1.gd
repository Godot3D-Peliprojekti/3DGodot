extends StaticBody3D

@export var prompt_message := "Press F to interact"
@export var animation_name := "drawer1_open"   # voi vaihtaa per laatikko

@onready var anim: AnimationPlayer = $"../AnimationPlayer"
#        ^^^^^^^^^^^^^^^^^^^^^^^^^ = mene yksi taso ylöspäin (Dresser) ja etsi sieltä AnimationPlayer

func interact(body):
	print(body.name, " interacted with: ", name)
	if anim and anim.has_animation(animation_name):
		anim.play(animation_name)
	else:
		print("Animation not found: ", animation_name)
