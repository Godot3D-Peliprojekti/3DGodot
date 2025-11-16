extends CharacterBody3D

@export var speed = 3.0
@export var run_speed = 5.0
@export var crouch_speed = 1.0  # kyykkyliikkeen nopeus
@export var animation_cooldown := 0.1  # sekunteina

@onready var character = $Character
@onready var anim_player = $Character/AnimationPlayer

var last_anim_time := 0.0
var is_crouching := false

func _physics_process(delta):
	last_anim_time += delta

	# ----------------------
	# Kyykistys
	# ----------------------
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	# ----------------------
	# Input
	# ----------------------
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	var is_moving = input_dir != Vector3.ZERO
	var is_running = Input.is_action_pressed("sprint") and not is_crouching

	# ----------------------
	# Liikkeen laskenta
	# ----------------------
	if is_moving:
		var direction = (
			-global_transform.basis.z * input_dir.z -
			global_transform.basis.x * input_dir.x
		).normalized()

		if is_crouching:
			velocity.x = direction.x * crouch_speed
			velocity.z = direction.z * crouch_speed
		elif is_running:
			velocity.x = direction.x * run_speed
			velocity.z = direction.z * run_speed
		else:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
	else:
		velocity.x = 0
		velocity.z = 0

	# ----------------------
	# Gravity
	# ----------------------
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		velocity.y = 0

	# ----------------------
	# Animaatiot
	# ----------------------
	if last_anim_time >= animation_cooldown:
		if is_crouching:
			anim_player.play("ManAnims/Armature|mixamo_com|Layer0 (2)")  # crouch idle
		else:
			if not is_moving:
				anim_player.play("ManAnims/Armature_004|mixamo_com|Layer0")  # idle
			else:
				if is_running:
					anim_player.play("ManAnims/Armature_006|mixamo_com|Layer0")  # run
				else:
					anim_player.play("ManAnims/Armature_011|mixamo_com|Layer0")  # walk

		last_anim_time = 0.0

	move_and_slide()
