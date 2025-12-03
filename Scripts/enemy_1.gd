extends CharacterBody3D

const SPEED: float = 1.5
const GRAVITY: float = 30.0
const STOP_DISTANCE: float = 1.3 	# Distance to player when it stops and bites

@export var player: Node3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape = $CollisionShape3D

@onready var animation_tree = $enemy1_setup/AnimationTree
@export_category("Animations")
@export var animation_blend_easing: float = 10.0

var death_blend: float

var health: int = 100
var is_dead: bool = false

func hit(damage: int) -> void:
	health -= damage

	if health <= 0 and not is_dead:
		is_dead = true
	else:
		animation_tree["parameters/Hit_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

func _process(delta: float) -> void:
	death_blend = lerp(death_blend, float(is_dead), animation_blend_easing * delta)
	animation_tree["parameters/Death_Blend/blend_amount"] = death_blend

func _physics_process(delta: float) -> void:
	if is_dead:
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
			look_at(global_transform.origin + move_dir, Vector3.UP)

			# Stop biting the air
			if animation_tree["parameters/Bite_OneShot/active"]:
				animation_tree["parameters/Bite_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		else:
			move_dir = Vector3.ZERO
			look_at(global_transform.origin + dir_to_player, Vector3.UP)

			animation_tree["parameters/Bite_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

		# Set the moving speed
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED

	move_and_slide()
