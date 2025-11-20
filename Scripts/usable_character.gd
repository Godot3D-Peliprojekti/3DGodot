extends CharacterBody3D

@export var speed = 3.0
@export var run_speed = 5.0
@export var crouch_speed = 1.0

@export var animation_cooldown := 0.1
@export var blend_speed := 0.15   # animaatioiden pehmeys

@onready var character = $Character
@onready var anim_player = $Character/AnimationPlayer

var is_crouching := false
var current_anim := ""
var last_anim_time = 0.0

func _physics_process(delta):

	# Kyykistys
	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	# INPUT
	var input_vec = Vector2.ZERO

	# KORJATTU suunnat:
	input_vec.y = Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
	input_vec.x = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")

	var is_moving = input_vec.length() > 0.01
	var is_running = Input.is_action_pressed("sprint") and not is_crouching

	# Suuntavektorit
	var forward = -global_transform.basis.z
	var right = global_transform.basis.x
	var direction = (forward * input_vec.y + right * input_vec.x).normalized()

	# Liike
	if is_moving:
		var move_speed = crouch_speed if is_crouching else (run_speed if is_running else speed)
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, 20 * delta)
		velocity.z = move_toward(velocity.z, 0, 20 * delta)

	# Gravity 
	if not is_on_floor():
		velocity.y -= 20 * delta
	else:
		velocity.y = 0

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		anim_player.play("ManAnims/knife_slash")

	# --- Animaatiot ---
	if last_anim_time >= animation_cooldown:
		if anim_player.current_animation != "ManAnims/knife_slash":
			if is_crouching:
				anim_player.play("ManAnims/Armature|mixamo_com|Layer0 (2)")  # crouch idle
			else:
				if not is_moving:
					anim_player.play("ManAnims/Armature_004|mixamo_com|Layer0")  # idle
				elif is_running:
					anim_player.play("ManAnims/Armature_006|mixamo_com|Layer0")  # run
				else:
					anim_player.play("ManAnims/knife_walk")  # walk

		last_anim_time = 0.0

	move_and_slide()

func _update_animation(input_vec: Vector2, crouching: bool, running: bool):

	var new_anim = _get_animation_name_vec(input_vec, crouching, running)

	# Soita vain jos muuttuu
	if new_anim != current_anim:
		anim_player.play(new_anim, blend_speed)
		current_anim = new_anim

	# Animaation nopeus
	if running:
		anim_player.speed_scale = 1.1
	elif crouching:
		anim_player.speed_scale = 0.7
	elif input_vec.length() > 0.1:
		anim_player.speed_scale = 1.0
	else:
		anim_player.speed_scale = 0.9

func _get_animation_name_vec(input_vec: Vector2, crouching: bool, running: bool) -> String:

	# Idle
	if input_vec.length() < 0.1:
		return "ManAnims/Armature_004|mixamo_com|Layer0" if not crouching else "ManAnims/Armature|mixamo_com|Layer0 (2)"

	var x = input_vec.x
	var z = input_vec.y

	# --- Crouch ---
	if crouching:
		if z < 0: return "ManAnims/crouch_walk_forw"
		elif z > 0: return "ManAnims/crouch_walk_back"
		elif x > 0: return "ManAnims/crouch_walk_left"
		elif x < 0: return "ManAnims/crouch_walk_right"

	# --- Running ---
	if running:
		if z < 0: return "ManAnims/Armature_006|mixamo_com|Layer0"
		elif x > 0: return "ManAnims/run_strafe_left"
		elif x < 0: return "ManAnims/run_strafe_right"

	# --- Walking ---
	if z < 0: return "ManAnims/Armature_011|mixamo_com|Layer0"
	elif z > 0: return "ManAnims/walk_back"
	elif x > 0: return "ManAnims/walk_strafe_left"
	elif x < 0: return "ManAnims/walk_strafe_right"

	# fallback
	return "ManAnims/Armature_004|mixamo_com|Layer0"
