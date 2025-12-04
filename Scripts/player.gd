extends CharacterBody3D
class_name Player

# TODO: Move to game controller
@export var gravity = 9.8
@export var mouse_sensitivity = 0.003

# Weapons
enum Weapon {
	NONE,
	BAT,
	KNIFE,
	GUN,
}

@export var weapon_damage: Dictionary[int, int] = {
	Weapon.BAT: 30,
	Weapon.KNIFE: 20,
	Weapon.GUN: 40
}

@export var weapon_distance_max: Dictionary[int, int] = {
	Weapon.BAT: 3,
	Weapon.KNIFE: 2,
	Weapon.GUN: 100
}

@onready var weapon_bat = $Head/Character/Armature/Skeleton3D/BoneAttachment3D/Bat
@onready var weapon_knife = $Head/Character/Armature/Skeleton3D/BoneAttachment3D/Knife
@onready var weapon_gun = $Head/Character/Armature/Skeleton3D/BoneAttachment3D/Gun

@onready var weapon_gun_slide = $Head/Character/Armature/Skeleton3D/BoneAttachment3D/Gun/Slide
@onready var weapon_gun_muzzle_flash = $Head/Character/Armature/Skeleton3D/BoneAttachment3D/Gun/Muzzle_Flash
var weapon_gun_slide_offset: float = 0.0

# Animations
@onready var animation_tree = $Head/Character/AnimationTree
@export_category("Animations")
@export var animation_blend_easing: float = 10.0

var has_key_1: bool = false
var has_key_2: bool = false

var lower_idle_blend: float = 0.0
var lower_walk_x_blend: float = 0.0
var lower_walk_z_blend: float = 0.0
var lower_crouch_x_blend: float = 0.0
var lower_crouch_z_blend: float = 0.0
var lower_run_forward_blend: float = 0.0
var lower_run_z_blend: float = 0.0

var upper_idle_blend: float = 0.0
var upper_walk_blend: float = 0.0
var upper_crouch_blend: float = 0.0
var upper_run_blend: float = 0.0

var upper_weapon_bat_idle_blend: float = 0.0
var upper_weapon_knife_idle_blend: float = 0.0
var upper_weapon_gun_idle_aim_blend: float = 0.0
var upper_weapon_gun_attack_add: float = 0.0

# Camera
@onready var camera = $Head/Camera3D
@export_category("Camera")
@export var camera_pitch_min: float = -40.0
@export var camera_pitch_max: float = 60.0
@export var camera_offset: Vector3 = Vector3(0.0, 0.0, -0.15)
@export var camera_bobbing_multiplier: float = 1.0
@onready var skeleton = $Head/Character/Armature/Skeleton3D
var bone_index: int

# Taskulamppu
@onready var flashlight = $Head/Camera3D/SpotLight3D
var show_flashlight = false
@onready var flashlight_prompt_label = $CanvasLayer/Control/Flashlight_Prompt_Label
var show_flashlight_prompt = true

# HUD elements
@onready var hud_weapon_bat = $CanvasLayer/Control/Baseball_Bat
@onready var hud_weapon_knife = $CanvasLayer/Control/Knife
@onready var hud_weapon_gun = $CanvasLayer/Control/Gun
@onready var hud_ammo_current = $CanvasLayer/Control/Ammo_Current
@onready var hud_ammo_reserve = $CanvasLayer/Control/Ammo_Reserve
@onready var hud_health_label = $CanvasLayer/Control/Health_Label
@onready var hud_health_bar = $CanvasLayer/Control/Health_Bar

@export_category("HUD")
@export var hud_color_selected: Color = Color(1.0, 1.0, 1.0)
@export var hud_color_selected_secondary: Color = Color(1.0, 1.0, 1.0, 0.5)
@export var hud_color_unselected: Color = Color(1.0, 1.0, 1.0, 0.1)

# Sound
@onready var footstep_audio: AudioStreamPlayer3D = $AudioStreamPlayer3D


# Player
@export_category("Player")
@onready var head = $Head
@export var default_speed: float = 3.0
var speed: float
@export var run_multiplier: float = 1.67
@export var crouch_multiplier: float = 0.33
@export var health_max: int = 100
@export var health_min: int = 0
@export var weapon_magazine_size: int = 8
var input_vector: Vector2

# Crouching
@onready var collider = $CollisionShape3D
@export_category("Crouching")
@export var crouching_easing = 6.0
@export var collider_height_standing: float = 1.7
@export var collider_height_crouching: float = 1.0
@export var collider_position_standing: float = 0.85
@export var collider_position_crouching: float = 0.5

var is_running: bool = false
var is_crouching: bool = false
var is_reloading: bool = false

var ammo_current: int = 0
var ammo_reserve: int = 999
var health: int = 0
var selected_weapon: int = Weapon.NONE

@onready var raycast = $Head/Camera3D/RayCast3D
@onready var bullet_hole_decal_scene = preload("res://Scenes/bullet_hole.tscn")

func hit(damage: int) -> void:
	health = max(health - damage, health_min)
	update_health_label()

func stop_reloading(success: bool) -> void:
	if success:
		var ammo = min(weapon_magazine_size - ammo_current, ammo_reserve)
		ammo_reserve -= ammo
		ammo_current += ammo
		update_ammo_label()
	else:
		animation_tree["parameters/Upper_Weapon_Gun_Reload_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

	is_reloading = false

var stun_time: float = 0.0	# Time of player in stun

func weapon_deactivate_all() -> void:
	hud_weapon_bat.modulate = hud_color_unselected
	hud_weapon_knife.modulate = hud_color_unselected
	hud_weapon_gun.modulate = hud_color_unselected
	hud_ammo_current.modulate = hud_color_unselected
	hud_ammo_reserve.modulate = hud_color_unselected

func weapon_activate(weapon: int) -> void:
	selected_weapon = weapon

	match weapon:
		Weapon.BAT:
			hud_weapon_bat.modulate = hud_color_selected
		Weapon.KNIFE:
			hud_weapon_knife.modulate = hud_color_selected
		Weapon.GUN:
			hud_weapon_gun.modulate = hud_color_selected
			hud_ammo_current.modulate = hud_color_selected
			hud_ammo_reserve.modulate = hud_color_selected_secondary

func update_ammo_label() -> void:
	hud_ammo_current.text = str(ammo_current)
	hud_ammo_reserve.text = "/ " + str(ammo_reserve)

func update_health_label() -> void:
	hud_health_label.text = str(health)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	health = health_max
	bone_index = skeleton.find_bone("mixamorig9_HeadTop_End")
	assert(bone_index != -1)

	weapon_deactivate_all()
	update_ammo_label()
	update_health_label()

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(camera_pitch_min), deg_to_rad(camera_pitch_max))

func _process(delta: float) -> void:
	# TODO: Move to game controller
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.is_action_just_pressed("flashlight"):
		# Ensimmäinen painallus: sulje prompt ja sytytä taskulamppu
		if show_flashlight_prompt:
			show_flashlight_prompt = false
			flashlight_prompt_label.visible = false
		# Muuten vaihdetaan taskulamppu normaalisti
		show_flashlight = !show_flashlight

	# SpotLight näkyvyys: näkyy vain jos show_flashlight ja ei kyykky
	# flashlight.visible = show_flashlight and not movement_script.is_crouching
	flashlight.visible = show_flashlight

	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	is_running = false
	if Input.is_action_pressed("sprint") and not Input.is_action_pressed("back") and not is_crouching:
		is_running = true

	if Input.is_action_just_pressed("weapon_bat") or Input.is_action_just_pressed("weapon_knife") or Input.is_action_just_pressed("weapon_gun"):
		weapon_deactivate_all()

		var selected = Weapon.NONE
		if Input.is_action_just_pressed("weapon_bat") and selected_weapon != Weapon.BAT:
			selected = Weapon.BAT
		elif Input.is_action_just_pressed("weapon_knife") and selected_weapon != Weapon.KNIFE:
			selected = Weapon.KNIFE
		elif Input.is_action_just_pressed("weapon_gun") and selected_weapon != Weapon.GUN:
			selected = Weapon.GUN

		weapon_activate(selected)

		if is_reloading:
			stop_reloading(false)

	#Add debug key for testing
	if Input.is_action_just_pressed("debug_key"):
		has_key_1 = true
		has_key_2 = true
		print("Keys given")

	# Update health bar scale and color
	var s = float(health) / health_max
	hud_health_bar.scale.x = lerp(hud_health_bar.scale.x, s, 10.0 * delta)
	hud_health_bar.modulate.r = -s + 1
	hud_health_bar.modulate.g = s

	# Update animations
	input_vector = Input.get_vector("left", "right", "forward", "back")

	speed = default_speed
	if is_running:
		speed *= run_multiplier
	elif is_crouching:
		speed *= crouch_multiplier

	# Lower animations
	lower_idle_blend = lerp(lower_idle_blend, float(is_crouching), animation_blend_easing * delta)
	lower_walk_x_blend = lerp(lower_walk_x_blend, -input_vector.y, animation_blend_easing * delta)
	lower_walk_z_blend = lerp(lower_walk_z_blend, -input_vector.x, animation_blend_easing * delta)
	lower_crouch_x_blend = lerp(lower_crouch_x_blend, -input_vector.y * float(is_crouching), animation_blend_easing * delta)
	lower_crouch_z_blend = lerp(lower_crouch_z_blend, -input_vector.x * float(is_crouching), animation_blend_easing * delta)
	lower_run_forward_blend = lerp(lower_run_forward_blend, -input_vector.y * float(is_running), animation_blend_easing * delta)
	lower_run_z_blend = lerp(lower_run_z_blend, -input_vector.x * float(is_running), animation_blend_easing * delta)

	animation_tree["parameters/Lower_Idle_Blend/blend_amount"] = lower_idle_blend
	animation_tree["parameters/Lower_Walk_X_Blend/blend_amount"] = lower_walk_x_blend
	animation_tree["parameters/Lower_Walk_Z_Blend/blend_amount"] = clamp(lower_walk_z_blend, -0.5, 0.5)
	animation_tree["parameters/Lower_Crouch_X_Blend/blend_amount"] = lower_crouch_x_blend
	animation_tree["parameters/Lower_Crouch_Z_Blend/blend_amount"] = lower_crouch_z_blend
	animation_tree["parameters/Lower_Run_Forward_Blend/blend_amount"] = lower_run_forward_blend
	animation_tree["parameters/Lower_Run_Z_Blend/blend_amount"] = lower_run_z_blend

	# Upper animations
	upper_idle_blend = lerp(upper_idle_blend, float(is_crouching), animation_blend_easing * delta)
	upper_walk_blend = lerp(upper_walk_blend, input_vector.length(), animation_blend_easing * delta)
	upper_crouch_blend = lerp(upper_crouch_blend, input_vector.length() * float(is_crouching), animation_blend_easing * delta)
	upper_run_blend = lerp(upper_run_blend, input_vector.length() * float(is_running), animation_blend_easing * delta)

	animation_tree["parameters/Upper_Idle_Blend/blend_amount"] = upper_idle_blend
	animation_tree["parameters/Upper_Walk_Blend/blend_amount"] = upper_walk_blend
	animation_tree["parameters/Upper_Crouch_Blend/blend_amount"] = upper_crouch_blend
	animation_tree["parameters/Upper_Run_Blend/blend_amount"] = upper_run_blend

	# Weapon animations
	if Input.is_action_pressed("attack"):
		if selected_weapon == Weapon.BAT and not animation_tree["parameters/Upper_Weapon_Bat_Attack_OneShot/active"]:
			animation_tree["parameters/Upper_Weapon_Bat_Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		elif selected_weapon == Weapon.KNIFE and not animation_tree["parameters/Upper_Weapon_Knife_Attack_OneShot/active"]:
			animation_tree["parameters/Upper_Weapon_Knife_Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	weapon_gun_muzzle_flash.visible = false;
	if Input.is_action_just_pressed("attack") and selected_weapon == Weapon.GUN and ammo_current > 0 and not is_reloading:
		upper_weapon_gun_attack_add = 1.0
		weapon_gun_slide_offset = -4
		weapon_gun_muzzle_flash.visible = true;

		ammo_current -= 1
		update_ammo_label()

	if is_reloading and not animation_tree["parameters/Upper_Weapon_Gun_Reload_OneShot/active"]:
		stop_reloading(true)

	if selected_weapon == Weapon.GUN and Input.is_action_just_pressed("reload") and not is_reloading and ammo_current < weapon_magazine_size:
		is_reloading = true
		animation_tree["parameters/Upper_Weapon_Gun_Reload_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	upper_weapon_bat_idle_blend = lerp(upper_weapon_bat_idle_blend, float(selected_weapon == Weapon.BAT), 2.0 * animation_blend_easing * delta)
	upper_weapon_knife_idle_blend = lerp(upper_weapon_knife_idle_blend, float(selected_weapon == Weapon.KNIFE), 2.0 * animation_blend_easing * delta)
	var target = -1.0 + float(selected_weapon == Weapon.GUN) + (float(Input.is_action_pressed("attack2")) * float(selected_weapon == Weapon.GUN))
	upper_weapon_gun_idle_aim_blend = lerp(upper_weapon_gun_idle_aim_blend, target, 2.0 * animation_blend_easing * delta)
	upper_weapon_gun_attack_add = lerp(upper_weapon_gun_attack_add, 0.0, animation_blend_easing * delta)

	animation_tree["parameters/Upper_Weapon_Bat_Idle_Blend/blend_amount"] = upper_weapon_bat_idle_blend
	animation_tree["parameters/Upper_Weapon_Knife_Idle_Blend/blend_amount"] = upper_weapon_knife_idle_blend
	animation_tree["parameters/Upper_Weapon_Gun_Idle_Aim_Blend/blend_amount"] = upper_weapon_gun_idle_aim_blend
	animation_tree["parameters/Upper_Weapon_Gun_Attack_Add/add_amount"] = upper_weapon_gun_attack_add

	weapon_bat.visible = upper_weapon_bat_idle_blend > 0.5
	weapon_knife.visible = upper_weapon_knife_idle_blend > 0.5
	weapon_gun.visible = upper_weapon_gun_idle_aim_blend > 0.5 || upper_weapon_gun_idle_aim_blend > -0.5

	if ammo_current > 0:
		weapon_gun_slide_offset = lerp(weapon_gun_slide_offset, -1.5, animation_blend_easing * delta)
	else:
		weapon_gun_slide_offset = -3
	weapon_gun_slide.position.z = weapon_gun_slide_offset

	# Set camera position
	var bone_local_transform = skeleton.get_bone_global_pose(bone_index)
	var bone_global_position = skeleton.to_global(bone_local_transform.origin)

	camera.global_position = bone_global_position
	camera.position.x *= camera_bobbing_multiplier
	camera.position.y *= camera_bobbing_multiplier
	camera.position += camera_offset

	# Block the camera from clipping the walls
	collider.global_position.x = camera.global_position.x
	collider.global_position.z = camera.global_position.z

	if 1:
		# Debug for ammo
		if Input.is_action_pressed("debug_ammo_add"):
			ammo_reserve += 1
			update_ammo_label()

		# Debug for health
		if Input.is_action_pressed("debug_health_add"):
			if health < health_max:
				health += 1
				update_health_label()
		elif Input.is_action_just_pressed("debug_health_add_2"):
			health = min(health_max, health + 20)
			update_health_label()
		elif Input.is_action_pressed("debug_health_sub"):
				if health > health_min:
					health -= 1
					update_health_label()
		elif Input.is_action_just_pressed("debug_health_sub_2"):
			health = max(health_min, health - 20)
			update_health_label()

func _physics_process(delta: float) -> void:
	# Update stun timer
	if stun_time > 0.0:
		stun_time -= delta
		
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Apply movement
	var direction = (head.transform.basis * transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
	
	# Only allow movement if not stunned
	if stun_time <= 0.0:
		if input_vector.length() > 0.0:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, 20 * delta)
			velocity.z = move_toward(velocity.z, 0, 20 * delta)

	# Apply crouching
	var collider_height_target = collider_height_standing
	var collider_position_target = collider_position_standing
	if is_crouching:
		collider_height_target = collider_height_crouching
		collider_position_target = collider_position_crouching

	collider.shape.height  = lerp(collider.shape.height , collider_height_target, crouching_easing * delta)
	collider.position.y = lerp(collider.position.y , collider_position_target, crouching_easing * delta)

	# Handle attacking
	if Input.is_action_just_pressed("attack") and selected_weapon != Weapon.NONE:
		raycast.rotation = Vector3.ZERO

		if selected_weapon == Weapon.GUN:
			# Add some inaccuracy when moving
			raycast.rotation.x = (randf() - 0.5) * velocity.length() / 10.0
			raycast.rotation.y = (randf() - 0.5) * velocity.length() / 10.0

		# print((raycast.get_collider().global_position - global_position).length())

		match raycast.get_collider().collision_layer:
			1: # Wall
				if selected_weapon == Weapon.GUN and ammo_current > 0 and not is_reloading:
					var decal = bullet_hole_decal_scene.instantiate()
					raycast.get_collider().add_child(decal)
					decal.global_transform.origin = raycast.get_collision_point()
					decal.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.UP)
					decal.rotation.z = randf() * 360.0

			4: # Enemy
				if (raycast.get_collider().global_position - global_position).length() < weapon_distance_max[selected_weapon]:
					if selected_weapon == Weapon.GUN:
						if ammo_current > 0 and not is_reloading:
							raycast.get_collider().hit(weapon_damage[selected_weapon])
					else:
						raycast.get_collider().hit(weapon_damage[selected_weapon])

	move_and_slide()
func play_footstep() -> void:
		if footstep_audio and not footstep_audio.playing and velocity.length() > 0.1:
			footstep_audio.play()
	
	
	
