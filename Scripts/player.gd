extends CharacterBody3D

# TODO: Move to game controller
@export var gravity = 9.8
@export var mouse_sensitivity = 0.003

@onready var camera = $Camera3D
@export_category("Camera")
@export var camera_pitch_min: float = -40.0
@export var camera_pitch_max: float = 60.0

# Taskulamppu
@onready var flashlight = $Camera3D/SpotLight3D
var show_flashlight = false
@onready var flashlight_prompt_label = $CanvasLayer/Flashlight_Prompt_Label
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

@export_category("Player")
@export var default_speed: float = 3.0
@export var run_multiplier: float = 1.67
@export var crouch_multiplier: float = 0.33
@export var health_max: int = 100
@export var health_min: int = 0
@export var weapon_magazine_size: int = 8

@onready var collider = $CollisionShape3D
@export_category("Crouching")
@export var crouching_easing = 6.0
@export var crouching_ratio: float = 0.6
@export var camera_height = 1.7
@export var collider_height: float = 1.7
@export var collider_position: float = 0.85

var is_running: bool = false
var is_crouching: bool = false
var is_grounded: bool = false

var ammo_current: int = 0
var ammo_reserve: int = 0
var health: int = 0
var selected_weapon: String = ""

func weapon_deactivate_all() -> void:
	hud_weapon_bat.modulate = hud_color_unselected
	hud_weapon_knife.modulate = hud_color_unselected
	hud_weapon_gun.modulate = hud_color_unselected
	hud_ammo_current.modulate = hud_color_unselected
	hud_ammo_reserve.modulate = hud_color_unselected

func weapon_activate(weapon: String) -> void:
	match weapon:
		"bat":
			hud_weapon_bat.modulate = hud_color_selected
		"knife":
			hud_weapon_knife.modulate = hud_color_selected
		"gun":
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

	weapon_deactivate_all()
	update_ammo_label()
	update_health_label()

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
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
		var selected = ""
		if Input.is_action_just_pressed("weapon_bat") and selected_weapon != "bat":
			selected = "bat"
		elif Input.is_action_just_pressed("weapon_knife") and selected_weapon != "knife":
			selected = "knife"
		elif Input.is_action_just_pressed("weapon_gun") and selected_weapon != "gun":
			selected = "gun"
		weapon_activate(selected)
		selected_weapon = selected

	# Update health bar scale and color
	var s = float(health) / health_max
	hud_health_bar.scale.x = lerp(hud_health_bar.scale.x, s, 10.0 * delta)
	hud_health_bar.modulate.r = -s + 1
	hud_health_bar.modulate.g = s


	if 1:
		# Debug for ammo
		if Input.is_action_just_pressed("debug_ammo_use"):
			if ammo_current > 0:
				ammo_current -= 1
				update_ammo_label()
		elif Input.is_action_just_pressed("debug_ammo_reload"):
			var ammo = min(weapon_magazine_size - ammo_current, ammo_reserve)
			ammo_reserve -= ammo
			ammo_current += ammo
			update_ammo_label()
		elif Input.is_action_just_pressed("debug_ammo_add"):
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
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Apply movement
	var speed = default_speed
	if is_running:
		speed *= run_multiplier
	elif is_crouching:
		speed *= crouch_multiplier

	var input_vector = Input.get_vector("left", "right", "forward", "back")
	var direction = (camera.transform.basis * transform.basis * Vector3(input_vector.x, 0, input_vector.y)).normalized()

	if input_vector.length() > 0.0:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, 20 * delta)
		velocity.z = move_toward(velocity.z, 0, 20 * delta)

	# Apply crouching
	var camera_height_target = camera_height
	var collider_height_target = collider_height
	var collider_position_target = collider_position
	if is_crouching:
		camera_height_target *= crouching_ratio
		collider_height_target *= crouching_ratio
		collider_position_target *= crouching_ratio

	camera.position.y = lerp(camera.position.y, camera_height_target, crouching_easing * delta)
	collider.shape.height  = lerp(collider.shape.height , collider_height_target, crouching_easing * delta)
	collider.position.y = lerp(collider.position.y , collider_position_target, crouching_easing * delta)

	move_and_slide()
