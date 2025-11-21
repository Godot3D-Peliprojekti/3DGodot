extends CollisionObject3D
class_name Interactable

#Export variable declarations
@export var prompt_message = "Press F to open "
@export var animation_player: AnimationPlayer
@export var open_animation_name := ""  
@export var close_animation_name := ""
#@onready var audio_stream_player_3d: AudioStreamPlayer3D = $"../../../AudioStreamPlayer3D"

var is_open := false
	
	#General function used in interactions
func interact(body):
	print(body.name, " interacted with: ", name)
	#If open, then play the close animation and update prompt_message accordingly
	if is_open:
		prompt_message = "Press F to close "
		animation_player.play(close_animation_name)
		is_open = false
		prompt_message = "Press F to open "
	#Else, play open animation and update prompt_message accordingly
	else:
		animation_player.play(open_animation_name)
		is_open = true
		prompt_message = "Press F to close "
