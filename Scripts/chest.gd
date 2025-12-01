extends StaticBody3D
class_name Chest

@export var prompt_message := "Press F to open"
@export var animation_player: AnimationPlayer
@export var open_animation_name := "open"
@export var close_animation_name := "close"

var is_open := false

func interact(body):
	print(body.name, " interacted with: ", name)
	if not animation_player:
		print("AnimationPlayer missing")
		return
	if is_open:
		if animation_player.has_animation(close_animation_name):
			animation_player.play(close_animation_name)
			is_open = false
			prompt_message = "Press F to open"
	else:
		if animation_player.has_animation(open_animation_name):
			animation_player.play(open_animation_name)
			is_open = true
			prompt_message = "Press F to close"
