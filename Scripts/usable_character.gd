extends CharacterBody3D

@export var speed = 5.0
@onready var character = $Character
@onready var anim_player = $Character/AnimationPlayer

func _physics_process(delta):
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_back"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	if input_dir != Vector3.ZERO:
		#anim_player.play("walk")
		# Muutetaan liike paikalliseksi ukon suunnan mukaan
		var direction = (-global_transform.basis.z * input_dir.z - global_transform.basis.x * input_dir.x).normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		#anim_player.play("idle")
		velocity.x = 0
		velocity.z = 0

	if not is_on_floor():
		velocity.y -= 9.8 * delta
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = 4.0

	move_and_slide()
