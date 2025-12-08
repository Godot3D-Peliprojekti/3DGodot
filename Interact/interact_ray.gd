extends RayCast3D

const RAY_LENGTH := 2
@onready var prompt: Label = $Prompt

func _physics_process(_delta: float) -> void:
	var cam := get_viewport().get_camera_3d()
	if cam == null:
		prompt.text = "No Camera3D found"
		return

	var mouse := get_viewport().get_mouse_position()
	var from  := cam.project_ray_origin(mouse)
	var dir   := cam.project_ray_normal(mouse)
	var to    := from + dir * RAY_LENGTH

	global_transform.origin = from
	target_position = to_local(to)
	force_raycast_update()

	prompt.text = ""

	if is_colliding():
		var col := get_collider()
		var obj = col
		while obj != null and not obj.has_method("interact"):
			obj = obj.get_parent()
		if obj != null:
			if obj.has_method("get_prompt"):
				prompt.text = obj.get_prompt(get_parent())
			else:
				prompt.text = obj.prompt_message

			# Käytetään pelaaja-nodea interact-parametrina
			if Input.is_action_just_pressed("interact_action"):
				var player = get_parent()
				if player != null:
					obj.interact(player)
