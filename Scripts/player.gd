extends Node3D

@export var mouse_sensitivity = 0.003
@onready var usable_character = $UsableCharacter
@onready var camera = $UsableCharacter/Camera3D
@export var camera_height_stand = 1.7
@export var camera_height_crouch = 1.0
@export var camera_smooth = 6.0
@onready var movement_script = $UsableCharacter
var rotation_y = 0.0
var camera_pitch = 0.0

@onready var prompt_label = $CanvasLayer/flashlightPromt
var prompt_active = true

# Taskulamppu
@onready var spotlight = $UsableCharacter/Camera3D/SpotLight3D
var flashlight_on = false

# HUD elements
@onready var hud_weapon_bat = $CanvasLayer/Control/Baseball_Bat
@onready var hud_weapon_knife = $CanvasLayer/Control/Knife
@onready var hud_weapon_gun = $CanvasLayer/Control/Gun
@onready var hud_ammo_current = $CanvasLayer/Control/Ammo_Current
@onready var hud_ammo_reserve = $CanvasLayer/Control/Ammo_Reserve
@onready var hud_health_label = $CanvasLayer/Control/Health_Label
@onready var hud_health_bar = $CanvasLayer/Control/Health_Bar

const HUD_WEAPON_ACTIVE = 1.0
const HUD_WEAPON_UNACTIVE = 0.1
const HUD_AMMO_RESERVE = 0.5
const GUN_MAGAZINE_SIZE = 8
const HEALTH_MAX = 100
const HEALTH_MIN = 0

var selected_weapon = ""
var ammo_current = 0
var ammo_reserve = 0
var health = HEALTH_MAX

func hud_weapon_deactivate_all():
	hud_weapon_bat.modulate.a = HUD_WEAPON_UNACTIVE
	hud_weapon_knife.modulate.a = HUD_WEAPON_UNACTIVE
	hud_weapon_gun.modulate.a = HUD_WEAPON_UNACTIVE
	hud_ammo_current.modulate.a = HUD_WEAPON_UNACTIVE
	hud_ammo_reserve.modulate.a = HUD_WEAPON_UNACTIVE
	
func hud_weapon_activate(name: String):
	match name:
		"bat":
			hud_weapon_bat.modulate.a = HUD_WEAPON_ACTIVE
		"knife":
			hud_weapon_knife.modulate.a = HUD_WEAPON_ACTIVE
		"gun":
			hud_weapon_gun.modulate.a = HUD_WEAPON_ACTIVE
			hud_ammo_current.modulate.a = HUD_WEAPON_ACTIVE
			hud_ammo_reserve.modulate.a = HUD_AMMO_RESERVE

func update_ammo_label():
	hud_ammo_current.text = str(ammo_current)
	hud_ammo_reserve.text = "/ " + str(ammo_reserve)
	
func update_health_label():
	hud_health_label.text = str(health)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hud_weapon_deactivate_all()
	update_ammo_label()
	update_health_label()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("flashlight"):
		if prompt_active:
			# Ensimmäinen painallus: sulje prompt ja sytytä taskulamppu
			prompt_active = false
			prompt_label.visible = false
			flashlight_on = true
		else:
			# Muuten vaihdetaan taskulamppu normaalisti
			flashlight_on = !flashlight_on

	elif event.is_action_pressed("weapon_bat") or event.is_action_pressed("weapon_knife") or event.is_action_pressed("weapon_gun"):
		hud_weapon_deactivate_all()
		var selected = ""
		if event.is_action_pressed("weapon_bat") and selected_weapon != "bat":
			selected = "bat"
		elif event.is_action_pressed("weapon_knife") and selected_weapon != "knife":
			selected = "knife"
		elif event.is_action_pressed("weapon_gun") and selected_weapon != "gun":
			selected = "gun"
		hud_weapon_activate(selected)
		selected_weapon = selected

	# Debug for ammo
	elif event.is_action_pressed("debug_ammo_use"):
		if ammo_current > 0:
			ammo_current -= 1
			update_ammo_label()
	elif event.is_action_pressed("debug_ammo_reload"):
		var ammo = min(GUN_MAGAZINE_SIZE - ammo_current, ammo_reserve)
		ammo_reserve -= ammo
		ammo_current += ammo
		update_ammo_label()
	elif event.is_action_pressed("debug_ammo_add"):
		ammo_reserve += 1
		update_ammo_label()

	# Debug for health
	elif event.is_action("debug_health_add"):
		if health < HEALTH_MAX:
			health += 1
			update_health_label()
	elif event.is_action_pressed("debug_health_add_2"):
		health = min(HEALTH_MAX, health + 20)
		update_health_label()
	elif event.is_action("debug_health_sub"):
			if health > HEALTH_MIN:
				health -= 1
				update_health_label()
	elif event.is_action_pressed("debug_health_sub_2"):
		health = max(HEALTH_MIN, health - 20)
		update_health_label()

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation_y -= event.relative.x * mouse_sensitivity
		camera_pitch -= event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -1.2, 1.2)
		usable_character.rotation.y = rotation_y
		camera.rotation.x = camera_pitch

func _process(delta):
	# Kamera laskeutuu kyykkyä varten
	var target_height = camera_height_stand
	#var target_forward_offset = 0.0 
	if movement_script.is_crouching:
		target_height = camera_height_crouch

	camera.transform.origin.y = lerp(
		camera.transform.origin.y,
		target_height,
		camera_smooth * delta
	)
	if prompt_active:
		spotlight.visible = false
	else:
		spotlight.visible = flashlight_on and not movement_script.is_crouching

	# Update health bar scale and color
	var scale = health / 100.0
	hud_health_bar.scale.x = scale
	hud_health_bar.modulate.r = -scale + 1
	hud_health_bar.modulate.g = scale
