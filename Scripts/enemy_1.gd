extends CharacterBody3D

const GRAVITY: float = 30.0

@export var speed: float = 0.8
const STOP_DISTANCE: float = 1.5 	# Distance to player when it stops and bites
const VIEW_DISTANCE: float = 5.0	# The distance that the enemy sees and reacts
const REACTION_TIME: float = 0.4	# The reaction time of the enemy
var time_player_in_view: float = 0.0	# The time of player in enemy's view

@export var player: Node3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape = $CollisionShape3D

@export var health_bar: Node3D # Health_Bar_3D

@export_category("Animations")
@export var animation_tree: AnimationTree
@export var animation_blend_easing: float = 10.0

var death_blend: float
var walk_blend: float

var health: int = 100
var is_dead: bool = false

func hit(damage: int) -> void:
	health = max(health - damage, 0)

	if health <= 0 and not is_dead:
		is_dead = true
	else:
		animation_tree["parameters/Hit_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		health_bar._hit(damage)

func _process(delta: float) -> void:
	walk_blend = lerp(walk_blend, clamp(velocity.length(), 0.0, 1.0), animation_blend_easing * delta)
	animation_tree["parameters/Walk_Blend/blend_amount"] = walk_blend

	health_bar.health = health
	health_bar._look_at(player.global_position)

	death_blend = lerp(death_blend, float(is_dead), animation_blend_easing * delta)
	animation_tree["parameters/Death_Blend/blend_amount"] = death_blend

func _physics_process(delta: float) -> void:
	if is_dead:
		if animation_tree["parameters/Death_Blend/blend_amount"] > 0.9999:
			health_bar.visible = false
		if collision_shape:
			collision_shape.queue_free()
		return
	# print(health)

	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var move_dir := Vector3.ZERO
	var distance_to_player := (player.global_transform.origin - global_transform.origin).length()

	# Check if there is a player AND distance_to_player is smaller than VIEW_DISTANCE
	if player and distance_to_player < VIEW_DISTANCE:
		time_player_in_view += delta	# Add every frame to the time variable
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
			look_at(global_transform.origin + move_dir, Vector3.UP)

			# Stop biting the air
			if animation_tree["parameters/Bite_OneShot/active"]:
				animation_tree["parameters/Bite_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		else:
			move_dir = Vector3.ZERO
			look_at(global_transform.origin + dir_to_player, Vector3.UP)

			if not animation_tree["parameters/Bite_OneShot/active"]:
				animation_tree["parameters/Bite_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
				player.stun_time = max(player.stun_time, 1.5)	# Stun the player
				player.hit(10)

		# Set the moving speed
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed

	# Player is too far away OR REACTION_TIME is up
	elif player:
		var to_player := player.global_transform.origin - global_transform.origin
		to_player.y = 0
		var dir_to_player := to_player.normalized()
		move_dir = Vector3.ZERO		# Stay in place
		look_at(global_transform.origin + dir_to_player, Vector3.UP)

	move_and_slide()
