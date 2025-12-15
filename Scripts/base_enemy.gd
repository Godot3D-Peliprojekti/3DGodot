extends CharacterBody3D

enum EnemyType {ZOMBIE, BRUTE }
@export var enemy_type: EnemyType

const GRAVITY: float = 9.8

@export var player: Node3D
@export var speed: float = 0.8

@export var stop_distance: float = 1.5 	# Distance to player when it stops and bites
@export var view_distance: float = 5.0	# The distance that the enemy sees and reacts
@export var reaction_time: float = 0.4	# The reaction time of the enemy
@export var health_bar: Node3D # Health_Bar_3D

@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var collision_shape = $CollisionShape3D

@export_category("Animations")
@export var animation_tree: AnimationTree
@export var animation_speed_default: float = 1.0
@export var animation_speed_walk: float = 0.75
@export var animation_speed_hit: float = 1.5
var animation_speed: float = animation_speed_default
@export var animation_blend_easing: float = 10.0

@onready var audio_zombie: AudioStreamPlayer3D = $enemy1_setup/AudioStreamPlayer3D
@onready var audio_brute: AudioStreamPlayer3D = $enemy_2_setup/AudioStreamPlayer3D
@onready var audio_death_brute: AudioStreamPlayer3D = $enemy_2_setup/AudioStreamPlayer3D2

var death_blend: float
var walk_blend: float

var health: int = 100
var is_dead: bool = false
var death_sound_played: bool = false

var time_player_in_view: float = 0.0	# The time of player in enemy's view

var has_aggro: bool = false

func play_audio() -> void:
	if is_dead:
		return

	if enemy_type == EnemyType.ZOMBIE:
		if not audio_zombie.playing:
			audio_zombie.play()
	else:
		if not audio_brute.playing:
			audio_brute.play()

func stop_audio() -> void:
	if enemy_type == EnemyType.ZOMBIE:
		if  audio_zombie.playing:
			audio_zombie.stop()
	else:
		if audio_brute.playing:
			audio_brute.stop()

func play_death_audio() -> void:
	if death_sound_played:
		return

	death_sound_played = true
	stop_audio()

	if enemy_type == EnemyType.ZOMBIE:
		if not audio_zombie.playing:
			audio_zombie.play()
	else:
		if not audio_death_brute.playing:
			audio_death_brute.play()

func hit(damage: int) -> void:
	health = max(health - damage, 0)

	if health <= 0 and not is_dead:
		is_dead = true
		has_aggro = false
		play_death_audio()
		return

	else:
		animation_tree["parameters/Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		animation_tree["parameters/Hit_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		health_bar._hit(damage)

		player.stun_time = 0.0

func _process(delta: float) -> void:
	animation_speed = animation_speed_default
	if animation_tree["parameters/Hit_OneShot/active"] and not death_blend > 0.0:
		animation_speed = animation_speed_hit
	elif walk_blend > 0.0:
		animation_speed = animation_speed_walk
	animation_tree["parameters/TimeScale/scale"] = animation_speed

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

	play_audio()

	if animation_speed == animation_speed_hit:
		velocity = Vector3.ZERO
		# var distance = (player.global_position - global_position).length()
		# velocity.z -= (200.0 / distance) * delta
	else:
		# Gravity
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		else:
			velocity.y = 0.0

		var move_dir := Vector3.ZERO
		var distance_to_player := (player.global_transform.origin - global_transform.origin).length()

		# Check if there is a player AND distance_to_player is smaller than view_distance
		if not has_aggro and player and distance_to_player < view_distance:
			time_player_in_view += delta	# Add every frame to the time variable
			has_aggro = true
		# Else keep the time at zero
		else:
			time_player_in_view = 0.0

		# Check if there is a player node nearby AND the enemy's has_aggro is true
		if player and has_aggro:
			navigation_agent_3d.target_position = player.global_transform.origin
			var next_point: Vector3 = navigation_agent_3d.get_next_path_position()

			var to_next := next_point - global_transform.origin
			to_next.y = 0

			# Straight direction towards the player
			var to_player := player.global_transform.origin - global_transform.origin
			to_player.y = 0
			var dir_to_player := to_player.normalized()

			# If the enemy has enough distance to the player
			if distance_to_player > stop_distance:
				# Check if there is a navigation path to use
				var has_path := not navigation_agent_3d.is_navigation_finished()
				var use_nav := has_path and to_next.length() > 0.05

				# If there is a path, use it
				if use_nav:
					move_dir = to_next.normalized()
				# Else: just follow the player
				else:
					move_dir = dir_to_player

				look_at(global_position + move_dir)

				# Stop biting the air
				if animation_tree["parameters/Attack_OneShot/active"]:
					animation_tree["parameters/Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
			else:
				move_dir = Vector3.ZERO
				look_at(global_transform.origin + dir_to_player)

				if not animation_tree["parameters/Attack_OneShot/active"]:
					animation_tree["parameters/Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
					player.stun_time = max(player.stun_time, 1.5)	# Stun the player
					player.hit(10)

			# Set the moving speed
			velocity.x = move_dir.x * speed
			velocity.z = move_dir.z * speed

		# Player is too far away OR reaction_time is up
		elif player:
			var to_player := player.global_transform.origin - global_transform.origin
			to_player.y = 0
			var dir_to_player := to_player.normalized()
			move_dir = Vector3.ZERO		# Stay in place
			look_at(global_transform.origin + dir_to_player)

	move_and_slide()
