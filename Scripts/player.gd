extends CharacterBody3D
class_name Player

# TODO: Move to game controller
@export var gravity = 9.8
@export var mouse_sensitivity: float = 0.003

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

# Flashlight
@onready var flashlight = $Head/Camera3D/SpotLight3D
var show_flashlight = false
@onready var flashlight_prompt_label = $CanvasLayer/Control/Flashlight_Prompt_Label
var show_flashlight_prompt = true
var flashlight_prompt_timer: float = 0.0
var flashlight_prompt_timeout: float = 2.0

# HUD elements
@onready var canvas_layer = $CanvasLayer
@onready var control: Control = $CanvasLayer/Control
@onready var hud_weapon_bat = $CanvasLayer/Control/Baseball_Bat
@onready var hud_weapon_knife = $CanvasLayer/Control/Knife
@onready var hud_weapon_gun = $CanvasLayer/Control/Gun
@onready var hud_ammo_current = $CanvasLayer/Control/Ammo_Current
@onready var hud_ammo_reserve = $CanvasLayer/Control/Ammo_Reserve
@onready var hud_health_label = $CanvasLayer/Control/Health_Label
@onready var hud_health_indicator_label = $CanvasLayer/Control/Health_Indicator_Label
@onready var hud_health_bar = $CanvasLayer/Control/Health_Bar

@export_category("HUD")
@export var hud_color_selected: Color = Color(1.0, 1.0, 1.0)
@export var hud_color_selected_secondary: Color = Color(1.0, 1.0, 1.0, 0.5)
@export var hud_color_unselected: Color = Color(1.0, 1.0, 1.0, 0.1)

# Sounds
@onready var audio_stream_player: AudioStreamPlayer = $CanvasLayer/Pause_menu/AudioStreamPlayer
@onready var audio_stream_player_movement: AudioStreamPlayer3D = $AudioStreamPlayer_movement
@onready var audio_stream_player_gun_reload: AudioStreamPlayer3D = $AudioStreamPlayer_gun_reload
@onready var audio_stream_player_gunshot: AudioStreamPlayer3D = $AudioStreamPlayer_gunshot
@onready var audio_stream_player_swing: AudioStreamPlayer3D = $AudioStreamPlayer_swing
@onready var audio_stream_player_flashlight: AudioStreamPlayer3D = $AudioStreamPlayer_flashlight
@onready var audio_stream_player_knife: AudioStreamPlayer3D = $AudioStreamPlayer_knife
@onready var audio_stream_player_ammo: AudioStreamPlayer3D = $AudioStreamPlayer_ammo

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
var ammo_reserve: int = 5
var health: int = 0
var selected_weapon: int = Weapon.NONE
var should_perform_attack: bool = false
var delay_before_attack: float = 0.0

@onready var raycast = $Head/Camera3D/RayCast3D
@onready var bullet_hole_decal_scene = preload("res://Scenes/bullet_hole.tscn")

@onready var vignette = $CanvasLayer/Control/Vignette
var vignette_target: float

# Pause menu
@onready var pause_menu: Control = $CanvasLayer/Pause_menu
@onready var filter = $CanvasLayer/Greyscale_Filter
var filter_value: float = 0.0

func hit(damage: int) -> void:
	vignette_target = 0.8

	health = max(health - damage, health_min)
	update_health_label()

	hud_health_indicator_label.text = "-" + str(damage)
	hud_health_indicator_label.position.y = 33.0
	hud_health_indicator_label.modulate.a = 1.0

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
	should_perform_attack = false
	delay_before_attack = 0.0

	match weapon:
		Weapon.BAT:
			hud_weapon_bat.modulate = hud_color_selected
			hud_ammo_current.visible = false
			hud_ammo_reserve.visible = false
		Weapon.KNIFE:
			hud_weapon_knife.modulate = hud_color_selected
			hud_ammo_current.visible = false
			hud_ammo_reserve.visible = false
		Weapon.GUN:
			hud_weapon_gun.modulate = hud_color_selected
			hud_ammo_current.modulate = hud_color_selected
			hud_ammo_reserve.modulate = hud_color_selected_secondary
			hud_ammo_current.visible = true
			hud_ammo_reserve.visible = true

func weapon_hud_hide() -> void:
	hud_weapon_bat.visible = false
	hud_weapon_knife.visible = false
	hud_weapon_gun.visible = false
	hud_ammo_current.visible = false
	hud_ammo_reserve.visible = false

func weapon_pickup(id: String):
	match id:
		"bat":
			hud_weapon_bat.visible = true
		"knife":
			hud_weapon_knife.visible = true
		"gun":
			hud_weapon_gun.visible = true
		"pistol_ammo":
			ammo_reserve += 8
			update_ammo_label()
			play_ammo_pick_up()

	weapon_activate(selected_weapon)

func update_ammo_label() -> void:
	hud_ammo_current.text = str(ammo_current)
	hud_ammo_reserve.text = "/ " + str(ammo_reserve)

func update_health_label() -> void:
	hud_health_label.text = str(health)

func _ready() -> void:
	flashlight_prompt_timer = 0.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pause_menu.visible = false

	pause_menu.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	filter.material.set_shader_parameter("value", 0.0)

	health = health_max
	bone_index = skeleton.find_bone("mixamorig9_HeadTop_End")
	assert(bone_index != -1)

	weapon_hud_hide()
	weapon_deactivate_all()
	update_ammo_label()
	update_health_label()
	_setup_gunshot_reverb()

func _unhandled_input(event) -> void:
	if health == 0:
		return

	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()
		return

	if get_tree().paused:
		return

	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * mouse_sensitivity)
		camera.rotate_x(-event.relative.y * mouse_sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(camera_pitch_min), deg_to_rad(camera_pitch_max))

# Toggle pause menu
func _toggle_pause() -> void:
	if pause_menu.visible:
		control.visible = true
		pause_menu._hide()
	else:
		if not audio_stream_player.playing:
			audio_stream_player.play()

		control.visible = false
		pause_menu._show_pause()

func _process(delta: float) -> void:
	if get_tree().paused:
		return

	vignette_target = lerp(vignette_target, 0.0, 4.0 * delta)
	vignette.modulate.a = vignette_target

	if health == 0:
		filter_value = lerp(filter_value, 1.0, 4.0 * delta)
		filter.material.set_shader_parameter("value", filter_value)

		if filter_value > 0.99 and not pause_menu.visible:
			control.visible = false
			pause_menu._show_death()

		return

	if Input.is_action_just_pressed("toggle_gui"):
		canvas_layer.visible = !canvas_layer.visible

	# Hide flashlight prompt automatically after timeout
	if show_flashlight_prompt:
		flashlight_prompt_timer += delta
		if flashlight_prompt_timer >= flashlight_prompt_timeout:
			show_flashlight_prompt = false
			flashlight_prompt_label.visible = false

	hud_health_indicator_label.position.y = lerp(hud_health_indicator_label.position.y, 73.0, 2.0 * delta)
	hud_health_indicator_label.modulate.a = lerp(hud_health_indicator_label.modulate.a, 0.0, 4.0 * delta)

	if Input.is_action_just_pressed("flashlight"):
		# Allow the flashlight to turn on or off only when flashlight click audio is not playing
		if not audio_stream_player_flashlight.playing:
			audio_stream_player_flashlight.play()
			# Close the flashlight prompt if flashlight is on
			if show_flashlight_prompt:
				show_flashlight_prompt = false
				flashlight_prompt_label.visible = false
			# Otherwise just turn the flashlight on
			show_flashlight = !show_flashlight

	# Flashlight is visible when show_flashlight is true and player is not crouching
	flashlight.visible = show_flashlight

	if Input.is_action_just_pressed("crouch"):
		is_crouching = !is_crouching

	is_running = false

	if Input.is_action_pressed("sprint") and not Input.is_action_pressed("back") and not is_crouching:
		is_running = true

	if Input.is_action_just_pressed("weapon_bat") or Input.is_action_just_pressed("weapon_knife") or Input.is_action_just_pressed("weapon_gun"):
		weapon_deactivate_all()

		var selected = Weapon.NONE
		if Input.is_action_just_pressed("weapon_bat") and selected_weapon != Weapon.BAT and hud_weapon_bat.visible:
			selected = Weapon.BAT
		elif Input.is_action_just_pressed("weapon_knife") and selected_weapon != Weapon.KNIFE and hud_weapon_knife.visible:
			selected = Weapon.KNIFE
		elif Input.is_action_just_pressed("weapon_gun") and selected_weapon != Weapon.GUN and hud_weapon_gun.visible:
			selected = Weapon.GUN

		weapon_activate(selected)

		if is_reloading:
			stop_reloading(false)

	# Add debug key for testing
	if Input.is_action_just_pressed("debug_key"):
		has_key_1 = true
		has_key_2 = true
		print("Keys given")

	# Update health bar scale and color
	hud_health_bar.value = lerp(hud_health_bar.value, float(health), 10.0 * delta)
	var s = float(health) / health_max
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
			should_perform_attack = true
			play_swing()
		elif selected_weapon == Weapon.KNIFE and not animation_tree["parameters/Upper_Weapon_Knife_Attack_OneShot/active"]:
			animation_tree["parameters/Upper_Weapon_Knife_Attack_OneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			should_perform_attack = true
			play_knife_swing()

	weapon_gun_muzzle_flash.visible = false;
	if Input.is_action_just_pressed("attack") and selected_weapon == Weapon.GUN and ammo_current > 0 and not is_reloading:
		upper_weapon_gun_attack_add = 1.0
		weapon_gun_slide_offset = -4
		weapon_gun_muzzle_flash.visible = true;

		play_gunshot()
		ammo_current -= 1
		update_ammo_label()
		should_perform_attack = true

	if is_reloading and not animation_tree["parameters/Upper_Weapon_Gun_Reload_OneShot/active"]:
		stop_reloading(true)

	if selected_weapon == Weapon.GUN and Input.is_action_just_pressed("reload") and not is_reloading and ammo_current < weapon_magazine_size and ammo_reserve > 0:
		play_gun_reload()
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
			hit(1)
		elif Input.is_action_just_pressed("debug_health_sub_2"):
			hit(20)

func _physics_process(delta: float) -> void:
	# Stop all physics if game is paused
	if get_tree().paused:
		return

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Update stun timer
	if stun_time > 0.0:
		stun_time -= delta

		# Only allow movement if not stunned
		velocity = Vector3.ZERO
	else:
		# Apply movement
		var direction = (head.transform.basis * transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()
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
	if Input.is_action_pressed("attack") and selected_weapon != Weapon.NONE and should_perform_attack:
		raycast.rotation = Vector3.ZERO

		# Add some inaccuracy when moving
		if selected_weapon == Weapon.GUN:
			raycast.rotation.x = (randf() - 0.5) * velocity.length() / 10.0
			raycast.rotation.y = (randf() - 0.5) * velocity.length() / 10.0

		if selected_weapon != Weapon.GUN and delay_before_attack < 30 * delta:
			delay_before_attack += delta
		else:
			should_perform_attack = false
			delay_before_attack = 0.0

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
	if audio_stream_player_movement and velocity.length() > 0.1:
		audio_stream_player_movement.play()

func play_gun_reload() -> void:
	audio_stream_player_gun_reload.play()

func _setup_gunshot_reverb() -> void:
	# Create a new bus for gunshot
	AudioServer.add_bus()
	var bus_index := AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, "GunshotBus")

	# Make the player's gunshot audiostreamplayer use that bus
	audio_stream_player_gunshot.bus = "GunshotBus"

	# Add reverb effect
	var reverb := AudioEffectReverb.new()

	# These values should reduce the echoing
	reverb.room_size = 0.1
	reverb.damping = 1.0
	reverb.wet = 0.005
	reverb.dry = 1.0
	reverb.predelay_msec = 0.0

	AudioServer.add_bus_effect(bus_index, reverb, 0)

func play_gunshot() -> void:
	# Temporary sound player
	var shot_player := AudioStreamPlayer3D.new()
	shot_player.stream = audio_stream_player_gunshot.stream
	shot_player.bus = audio_stream_player_gunshot.bus
	shot_player.transform = audio_stream_player_gunshot.transform

	# Add the shot_player as a child inside Player node
	add_child(shot_player)

	shot_player.play()

	# When sound is played, delete the temporary player
	shot_player.finished.connect(func():
		shot_player.queue_free())

func play_swing() -> void:
	if not audio_stream_player_swing.playing:
		audio_stream_player_swing.play()

func play_knife_swing() -> void:
	if not audio_stream_player_knife.playing:
		audio_stream_player_knife.play()

func play_ammo_pick_up() -> void:
	if not audio_stream_player_ammo.playing:
		audio_stream_player_ammo.play()
