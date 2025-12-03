extends CharacterBody3D

const SPEED: float = 2.0
const GRAVITY: float = 30.0
const STOP_DISTANCE: float = 1.5 	# Distance to player when it stops and bites
const VIEW_DISTANCE: float = 10.0	# The distance that the enemy sees and reacts
const REACTION_TIME: float = 0.4	# The reaction time of the enemy

@export var player: Node3D
@onready var animation_player: AnimationPlayer = $Enemy_2_setup/AnimationPlayer
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D

var time_player_in_view: float = 0.0	# The time of player in enemy's view

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var move_dir := Vector3.ZERO
	var distance_to_player := (player.global_transform.origin - global_transform.origin).length()

	# Check if there is a player AND distance_to_player is smaller than VIEW_DISTANCE
	if player and distance_to_player < VIEW_DISTANCE:
		time_player_in_view += delta
	# Else keep the time at zero
	else:
		time_player_in_view = 0.0

	# Check if there is a player node nearby AND the time is higher or equal to REACTION_TIME
	if player and distance_to_player < VIEW_DISTANCE and time_player_in_view >= REACTION_TIME:
		navigation_agent_3d.target_position = player.global_transform.origin
		var next_point: Vector3 = navigation_agent_3d.get_next_path_position()
		
		var to_next := next_point - global_transform.origin
		to_next.y = 0
		
		# Straight direction towards the player
		var to_player := player.global_transform.origin - global_transform.origin
		to_player.y = 0
		var dir_to_player := to_player.normalized()
		var forward := -global_transform.basis.z

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
					
			if animation_player.current_animation != "Running0":
				# 0.2 blend time to make the transition to run animation smoother
				animation_player.play("Running0", 0.2)
				
			look_at(global_transform.origin + move_dir, Vector3.UP)
				
		else:
			if animation_player.current_animation != "MmaKick0" : 
				# 0.1 blend time to make the transition to kick animaation smoother
				animation_player.play("MmaKick0", 0.1)
				player.stun_time = max(player.stun_time, 1.1)	# Stun the player

			move_dir = Vector3.ZERO
			look_at(global_transform.origin + dir_to_player, Vector3.UP)

		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED

	# Player is too far away OR REACTION_TIME is up
	elif player:
		var to_player := player.global_transform.origin - global_transform.origin
		to_player.y = 0
		var dir_to_player := to_player.normalized()
		move_dir = Vector3.ZERO		# Stay in place
		animation_player.play("mixamo_com") # idle loop
		look_at(global_transform.origin + dir_to_player, Vector3.UP)

	move_and_slide()
