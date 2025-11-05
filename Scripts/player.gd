extends CharacterBody3D

@export var speed = 5.0
@export var mouse_sensitivity = 0.003

var rotation_y = 0.0
var camera_pitch = 0.0
@onready var camera = $Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -1.2, 1.2)
		rotation.y = rotation_y
		camera.rotation.x = camera_pitch

func _physics_process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	

	velocity.x = direction.x * speed 
	velocity.z = direction.z * speed 
	

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = 4.0

	move_and_slide()
