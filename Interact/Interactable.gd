extends StaticBody3D
class_name Interactable

@export var key: Key
@export var prompt_message := "Press F to open"
@export var animation_player: AnimationPlayer
@export var open_animation_name := ""
@export var close_animation_name := ""

var is_open := false

func interact(_body):
	if not animation_player:
		return

	if is_open:
		animation_player.play(close_animation_name)
		is_open = false
		prompt_message = "Press F to open"
	else:
		animation_player.play(open_animation_name)
		is_open = true
		prompt_message = "Press F to close"
		if key:
			key.set_pickable(true)
