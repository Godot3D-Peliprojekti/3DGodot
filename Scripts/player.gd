extends CharacterBody3D

@export var speed = 4.0
@export var sprint_speed = 6.0
@export var mouse_sensitivity = 0.003

var rotation_y = 0.0
var camera_pitch = 0.0
@onready var camera = $Camera3D

#smooth animation transitions
var transition_time = 0.05  # sekunteina
var transition_timer = 0.0
var last_animation = ""

#Animaatiot 
@onready var character = $CharacterGodot
@onready var anim_player: AnimationPlayer = $CharacterGodot/AnimationPlayer

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	anim_player.play("CharacterAnims/Man_idle") # aloitusanimaatio
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		#get_tree().quit()
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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

	# Valitaan nopeus
	var current_speed = speed
	if Input.is_action_pressed("Sprint"):
		current_speed = sprint_speed

	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = 4.0

	move_and_slide()

	# Smooth rotation hahmo liikesuuntaan
	if direction != Vector3.ZERO:
		var target_angle = atan2(direction.x, direction.z)
		var current_y = character.rotation.y
		character.rotation.y = lerp_angle(current_y, target_angle, 0.1)

	# Animaatiot
	if not is_on_floor():
		pass
	elif direction.length() > 0.1:
		if Input.is_action_pressed("Sprint"):
			play_anim("CharacterAnims/Man_run")
		else:
			play_anim("CharacterAnims/Man_walk")
	else:
		play_anim("CharacterAnims/Man_idle")


func play_anim(name: String):
	if last_animation != name:
		transition_timer = transition_time
		last_animation = name
		
	if transition_timer <= 0.0:
		if anim_player.current_animation != name:
			anim_player.play(name)
	else:
		transition_timer -= get_physics_process_delta_time()
