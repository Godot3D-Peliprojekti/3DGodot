extends CharacterBody3D

const SPEED: float = 1.5
const GRAVITY: float = 30.0
const STOP_DISTANCE: float = 1.3 	# Distance to player when it stops and bites

@export var player: Node3D
@onready var animation_player: AnimationPlayer = $Enemy_2_setup/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var move_dir := Vector3.ZERO

	# Check if there is a player node in inspector
	if player:
		navigation_agent_3d.target_position = player.global_transform.origin
		var next_point: Vector3 = navigation_agent_3d.get_next_path_position()
		
		var to_next := next_point - global_transform.origin
		to_next.y = 0
		
		var distance_to_player := (player.global_transform.origin - global_transform.origin).length()
		
		# Straight direction towards the player
		var to_player := player.global_transform.origin - global_transform.origin
		to_player.y = 0
		var dir_to_player := to_player.normalized()
		var forward := -global_transform.basis.z
		var dot := forward.dot(dir_to_player)

		# If the enemy has enough distance to the player
		if distance_to_player > STOP_DISTANCE:
			# Check if there is a navigation path to use
			var has_path := not navigation_agent_3d.is_navigation_finished()
			var use_nav := has_path and to_next.length() > 0.05
			# If there is a path, use it
			if use_nav:
				move_dir = to_next.normalized()
			# Else: just follow the player
			else:
				move_dir = dir_to_player
			animation_player.queue("Running0")
			look_at(global_transform.origin + move_dir, Vector3.UP)
		else:
			animation_player.play("MmaKick0")
			move_dir = Vector3.ZERO
			look_at(global_transform.origin + dir_to_player, Vector3.UP)
		
		# Set the moving speed
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED

	move_and_slide()
