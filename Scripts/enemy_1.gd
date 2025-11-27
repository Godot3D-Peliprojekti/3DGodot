extends CharacterBody3D

const SPEED: float = 1.5
const GRAVITY: float = 30.0
const STOP_DISTANCE: float = 2.0  

@export var player: Node3D
@onready var animation_player: AnimationPlayer = $enemy1_setup/AnimationPlayer

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var move_dir := Vector3.ZERO

	if player:
		var to_player := player.global_transform.origin - global_transform.origin
		to_player.y = 0

		var distance := to_player.length()

		if distance > STOP_DISTANCE:
			# Normalize to avoid zero vector glitch
			move_dir = to_player / distance
			# Play only when the animation is not playing
			#if animation_player.current_animation != "ZombieWalk" or not animation_player.is_playing():
			animation_player.play("ZombieWalk")
			look_at(global_transform.origin + move_dir, Vector3.UP)
		else:
			animation_player.queue("ZombieNeckBite")
			move_dir = Vector3.ZERO   # Keep a little distance to player
			

	velocity.x = move_dir.x * SPEED
	velocity.z = move_dir.z * SPEED

	move_and_slide()
	
	
