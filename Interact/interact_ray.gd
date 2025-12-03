extends RayCast3D

#Set the length of the raycast to 1.5 (how far you can reach to interact with objects)
const RAY_LENGTH := 1.5
@onready var prompt: Label = $Prompt

func _physics_process(_delta: float) -> void:
	#Getting the camera that is used in game
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		prompt.text = "No Camera3D found"
		return
		
	#Configurations to set the raycast to follow mouse
	var mouse := get_viewport().get_mouse_position()
	var from  := cam.project_ray_origin(mouse)
	var dir   := cam.project_ray_normal(mouse)
	var to    := from + dir * RAY_LENGTH

	global_transform.origin = from
	target_position = to_local(to)   
	
	#Update the collision information for the raycast immediately
	force_raycast_update()
	
	#By default the prompt text is empty, if not collided by interactable
	#When collided by interactable, prompt text is the content of prompt_message, which is changed in different states
	prompt.text = ""
	if is_colliding():
	#Set a col variable that stores the colliding object
		var col := get_collider()
		if col is Interactable or col is Chest or col is Key: 
			prompt.text = col.prompt_message #+ col.name

	#If interact_action key [F] is pressed, interact function declared in Interactable.gd is used to interact with the colliding object
			if Input.is_action_just_pressed("interact_action"):
				col.interact(owner)
